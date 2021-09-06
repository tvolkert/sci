import 'package:flutter/foundation.dart';

import 'user.dart';

mixin TrackUserAuthMixin {
  Future<void> _handleLogin() async {
    onUserAuthenticated();
  }

  /// True if this object is currently tracking user authentication state.
  ///
  /// See also:
  ///  * [startTrackingAuth]
  ///  * [stopTrackingAuth]
  bool _isTrackingAuth = false;
  bool get isTrackingAuth => _isTrackingAuth;

  /// Whether the user is currently authenticated.
  bool get isUserAuthenticated => UserBinding.instance!.isUserAuthenticated;

  /// Starts tracking the user authentication state.
  ///
  /// Attempts to call this method more than once (without first calling
  /// [stopTrackingAuth]) will fail.
  @protected
  @mustCallSuper
  void startTrackingAuth() {
    assert(!isTrackingAuth);
    UserBinding.instance!.addPostLoginCallback(_handleLogin);
    _isTrackingAuth = true;
  }

  /// Stops tracking the user authentication state.
  ///
  /// Callers should call this method before they drop their reference to this
  /// object in order to not leak memory.
  @protected
  @mustCallSuper
  void stopTrackingAuth() {
    assert(isTrackingAuth);
    UserBinding.instance!.removePostLoginCallback(_handleLogin);
    _isTrackingAuth = false;
  }

  /// Invoked when the user successfully signs in.
  ///
  /// Subclasses may override this method to have a hook into when the value
  /// of [UserBinding.isUserAuthenticated] changes.
  @protected
  @mustCallSuper
  void onUserAuthenticated() {}
}
