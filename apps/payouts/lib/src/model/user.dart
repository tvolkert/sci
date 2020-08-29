import 'dart:convert';
import 'dart:io' show HttpStatus;
import 'dart:ui';

import 'package:http/http.dart' as http;

import 'constants.dart';
import 'http.dart';

class UserBinding {
  UserBinding._();

  /// The singleton binding instance.
  static final UserBinding instance = UserBinding._();

  /// The currently logged-in user, or null if no user is logged in.
  User _user;
  User get user => _user;

  static Map<String, String> _authHeaders(String username, String password) {
    String token = base64.encode(latin1.encode('$username:$password'));
    return <String, String>{
      'Authorization': 'Basic ${token.trim()}',
    };
  }

  /// Logs the user in from the given username and password.
  ///
  /// If this method completes successfully, then the [UserBinding.user] field
  /// will be set to the user that is returned. It is legal to call this when
  /// the [UserBinding.user] field is already set; doing so will cause the
  /// field to be replaced with the new user.
  ///
  /// If the username and password aren't correct, then a [InvalidCredentials]
  /// error will be thrown.
  ///
  /// If the HTTP request to authenticate the user takes longer than [timeout],
  /// then a [TimeoutException] error will be thrown.
  ///
  /// If an unexpected HTTP status code is returned, then a [HttpStatusException]
  /// error will be thrown.
  Future<User> login(
    String username,
    String password, {
    Duration timeout = httpTimeout,
  }) async {
    final Uri uri = Server.uri(Server.loginUrl);
    final http.Response response = await HttpBinding.instance.client
        .get(uri, headers: _authHeaders(username, password))
        .timeout(timeout);
    if (response.statusCode == HttpStatus.ok) {
      Map<String, dynamic> loginData = json.decode(response.body).cast<String, dynamic>();
      int lastInvoiceId = loginData[Keys.lastInvoiceId];
      bool passwordRequiresReset = loginData[Keys.passwordRequiresReset];
      _user = User._(username, password, lastInvoiceId, passwordRequiresReset);
      return _user;
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode, response.body);
    }
    // TODO: handle no route to host, unknown host, socket exception, conection exception
  }

  /// Updates the password of the currently logged-in user.
  ///
  /// Returns a new User with the updated password. The new user will also be
  /// set as the value of this binding's [user].
  Future<User> updatePassword(String password, {Duration timeout = httpTimeout}) async {
    assert(user != null);
    final Uri url = Server.uri(Server.passwordUrl);
    final http.Response response =
        await user.authenticate().put(url, body: password).timeout(timeout);
    if (response.statusCode == HttpStatus.ok) {
      _user = _user._withNewPassword(password);
      return _user;
    } else {
      throw HttpStatusException(response.statusCode, response.body);
    }
  }

  /// Logs the current user out.
  ///
  /// After this is called, the [UserBinding.user] field will be null. It is
  /// legal to call this method when the user is already logged out, in which
  /// case this is a no-op.
  void logout() {
    UserBinding.instance._user = null;
  }
}

class InvalidCredentials implements Exception {
  const InvalidCredentials();
}

class User {
  const User._(
    this.username,
    this._password,
    this.lastInvoiceId,
    this.passwordRequiresReset,
  )   : assert(username != null),
        assert(_password != null),
        assert(passwordRequiresReset != null);

  /// The user's login / username.
  final String username;
  final String _password;

  /// The ID of the last invoice that the user opened.
  final int lastInvoiceId;

  /// True if this user is required to reset their password upon login.
  final bool passwordRequiresReset;

  Map<String, String> get _authHeaders => UserBinding._authHeaders(username, _password);

  http.BaseClient authenticate([http.BaseClient client]) {
    return _AuthenticatedClient._(client ?? HttpBinding.instance.client, this);
  }

  User _withNewPassword(String password) {
    return User._(username, password, lastInvoiceId, false);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.username == username && other._password == _password;
  }

  @override
  int get hashCode => hashValues(username, _password);

  @override
  String toString() => '$runtimeType<$username>';
}

class _AuthenticatedClient extends http.BaseClient {
  _AuthenticatedClient._(this._delegate, this._user);

  final http.BaseClient _delegate;
  final User _user;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_user._authHeaders);
    return _delegate.send(request);
  }

  void close() => _delegate.close();
}
