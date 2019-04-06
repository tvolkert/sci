import 'dart:convert';
import 'dart:ui';

class User {
  const User(
    this.username,
    this.password,
    this.lastInvoiceId,
    this.passwordRequiresReset,
  )   : assert(username != null),
        assert(password != null),
        assert(passwordRequiresReset != null);

  final String username;
  final String password;
  final int lastInvoiceId;
  final bool passwordRequiresReset;

  Map<String, String> get authHeaders {
    String token = base64.encode(latin1.encode('$username:$password'));
    return <String, String>{
      'Authorization': 'Basic ${token.trim()}',
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other == null) {
      return false;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    User user = other;
    return user.username == username && user.password == password;
  }

  @override
  int get hashCode => hashValues(username, password);

  @override
  String toString() => '$username:$password';
}
