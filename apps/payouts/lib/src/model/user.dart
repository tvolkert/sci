import 'dart:convert';
import 'dart:io' show HttpStatus;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as url;

import 'binding.dart';
import 'constants.dart';
import 'http.dart';

mixin UserBinding on AppBindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The singleton instance of this object.
  static UserBinding? _instance;
  static UserBinding? get instance => _instance;

  /// The currently logged-in user, or null if no user is logged in.
  User? _user;
  User? get user => _user;

  /// Whether the user is signed in.
  bool get isUserAuthenticated => user != null;

  List<AsyncCallback> _postLoginCallbacks = <AsyncCallback>[];

  /// Registers the specified async callback to be run after the user logs in.
  ///
  /// Post-login callbacks are run either after a user logs in (via [login])
  /// when the user's password is valid (doesn't require reset), or after the
  /// user resets their password (via [updatePassword]). In both of these
  /// cases, the future returned by the method will not complete until all
  /// futures returned by the post-login callbacks have completed.
  ///
  /// Registered callbacks may rely on the [user] property being non-null.
  void addPostLoginCallback(AsyncCallback callback) {
    _postLoginCallbacks.add(callback);
  }

  /// Removes a previously-registered post-login callback.
  ///
  /// If the callback cannot be found in the list of registered callbacks, this
  /// is a no-op.
  void removePostLoginCallback(AsyncCallback callback) {
    _postLoginCallbacks.remove(callback);
  }

  static Map<String, String> _authHeaders(String username, String password) {
    String token = base64.encode(latin1.encode('$username:$password'));
    return <String, String>{
      'Authorization': 'Basic ${token.trim()}',
    };
  }

  Future<void> _runPostLoginCallbacks() async {
    List<Future<void>> postLoginFutures = <Future<void>>[];
    for (AsyncCallback callback in List<AsyncCallback>.of(_postLoginCallbacks)) {
      postLoginFutures.add(callback());
    }
    await Future.wait(postLoginFutures);
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
  /// If upon a successful login, the user's [User.isPostLogin] property is
  /// true, then post-login callbacks will be run as well, and the returned
  /// future will complete only once all corresponding futures have completed.
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
    final Uri uri = Server.uri(Server.loginUrl, query: <String, String>{
      Keys.username: username,
    });
    try {
      final http.Response response = await HttpBinding.instance!.client
          .get(uri, headers: _authHeaders(username, password))
          .timeout(timeout);
      if (response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> loginData = json.decode(response.body).cast<String, dynamic>();
        int? lastInvoiceId = loginData[Keys.lastInvoiceId];
        bool passwordRequiresReset = loginData[Keys.passwordRequiresReset];
        final User user = User._(username, password, lastInvoiceId, passwordRequiresReset);
        _user = user;
        if (user.isPostLogin) {
          await _runPostLoginCallbacks();
        }
        return user;
      } else if (response.statusCode == HttpStatus.forbidden) {
        throw const InvalidCredentials();
      } else {
        throw HttpStatusException(response.statusCode, response.body);
      }
    } on http.ClientException catch (error, stackTrace) {
      // Unexpected error, so ensure it gets logged to the console.
      print('$error\n$stackTrace');
      rethrow;
    }
  }

  /// Logs the current user out.
  ///
  /// After this is called, the [UserBinding.user] field will be null. It is
  /// legal to call this method when the user is already logged out, in which
  /// case this is a no-op.
  void logout() {
    UserBinding.instance!._user = null;
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
  );

  /// The user's login / username.
  final String username;
  final String _password;

  /// The ID of the last invoice that the user opened.
  final int? lastInvoiceId;

  /// True if this user is required to reset their password upon login.
  final bool passwordRequiresReset;

  Map<String, String> get _authHeaders => UserBinding._authHeaders(username, _password);

  bool get isPostLogin => !passwordRequiresReset;

  http.BaseClient authenticate() {
    return authenticateClient(HttpBinding.instance!.client);
  }

  Future<bool> launchAuthenticatedUri(Uri uri, {Duration timeout = httpTimeout}) async {
    assert(uri.scheme == 'https');
    final Uri tokenUrl = Server.uri(Server.tokenUrl, query: <String, String>{
      Keys.username: username,
    });
    final http.Response tokenResponse = await authenticate().get(tokenUrl).timeout(timeout);
    if (tokenResponse.statusCode == HttpStatus.ok) {
      // Token is valid for 5 minutes.
      final String token = json.decode(tokenResponse.body);
      uri = uri.replace(queryParameters: <String, String>{
        ...uri.queryParameters,
        QueryParameters.token: token,
      });
      return url.launch(uri.toString());
    } else {
      throw HttpStatusException(tokenResponse.statusCode, tokenResponse.body);
    }
  }

  @visibleForTesting
  http.BaseClient authenticateClient(http.BaseClient client) {
    return _AuthenticatedClient._(client, this);
  }

  /// Updates the user's password.
  ///
  /// Returns a new User with the updated password. The new user will also be
  /// set as the value of [UserBinding.user].
  ///
  /// If [isPostLogin] was false before calling this method, and the new user's
  /// [isPostLogin] property is true, then this will also run all post-login
  /// callbacks that have been registered via [UserBinding.addPostLoginCallback],
  /// and the future returned by this method will only complete after all
  /// corresponding futures have completed.
  Future<User> updatePassword(String password, {Duration timeout = httpTimeout}) async {
    final bool wasPostLogin = isPostLogin;
    final Uri url = Server.uri(Server.passwordUrl);
    final http.Response response = await authenticate().put(url, body: password).timeout(timeout);
    if (response.statusCode == HttpStatus.ok) {
      final User newUser = User._(username, password, lastInvoiceId, false);
      UserBinding.instance!._user = newUser;
      if (!wasPostLogin && newUser.isPostLogin) {
        await UserBinding.instance!._runPostLoginCallbacks();
      }
      return newUser;
    } else {
      throw HttpStatusException(response.statusCode, response.body);
    }
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
