import 'dart:async';
import 'dart:io';

import 'package:chicago/chicago.dart' hide TableCell, TableColumnWidth, TableRow;
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/http.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/user.dart';

typedef LoginCallback = void Function(String username, String password, bool setCookie);

typedef ChangePasswordCallback = void Function(String password, bool setCookie);

class LoginIntent extends Intent {
  const LoginIntent({this.context});

  final BuildContext? context;
}

class LoginAction extends ContextAction<LoginIntent> {
  LoginAction._();

  static final LoginAction instance = LoginAction._();

  @override
  Future<void> invoke(LoginIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString(Keys.username);
    String? savedPassword = prefs.getString(Keys.password);
    await LoginSheet.open(context: context, username: savedUsername, password: savedPassword);
  }
}

class LoginSheet extends StatefulWidget {
  const LoginSheet({
    Key? key,
    this.username,
    this.password,
  }) : super(key: key);

  /// The pre-populated value of the username field.
  final String? username;

  /// The pre-populated value of the password field.
  final String? password;

  @override
  _LoginSheetState createState() => _LoginSheetState();

  static Future<void> open({required BuildContext context, String? username, String? password}) {
    return Sheet.open<void>(
      context: context,
      barrierColor: const Color(0x00000000),
      content: LoginSheet(username: username, password: password),
    );
  }
}

enum _LoginPhase {
  idle,
  authenticating,
  initializing,
  changingPassword,
}


class _LoginSheetState extends State<LoginSheet> {
  static const String _serverHostToken = '%SERVER_HOST%';
  static const Map<int, String> _loginSpecificHttpStatusErrorMessages = <int, String>{
    HttpStatus.movedTemporarily: 'It appears that your Internet connection requires activation. '
        'Please open an Internet browser and follow the instructions to activate your connection.',
    HttpStatus.badGateway: 'Your Internet connection appears to be disconnected. Please check '
        'your connectivity and try again.',
    HttpStatus.serviceUnavailable: 'The Satellite Consulting server is not accepting network '
        'connections. Please try again later, and if the problem persists, report the problem to '
        'Keith Volkert (keith@satelliteconsulting.com).',
    HttpStatus.requestTimeout: 'We were unable to locate $_serverHostToken. Please check that you '
        'are connected to the Internet, and try again.',
    HttpStatus.forbidden: 'Invalid ID or password.',
  };

  static const String _defaultHttpStatusErrorMessage = 'The Satellite Consulting server has '
      'encountered an error. Please report this problem to Keith Volkert '
      '(keith@satelliteconsulting.com).';
  static const String _httpClientErrorMessage = 'The Payouts client has encountered an error. '
      'Please report this problem to Keith Volkert (keith@satelliteconsulting.com).';

  String? _errorText;
  String? get errorText => _errorText;
  set errorText(String? value) {
    if (value != _errorText) {
      setState(() {
        _errorText = value;
      });
    }
  }

  _LoginPhase _phase = _LoginPhase.idle;
  _LoginPhase get phase => _phase;
  set phase(_LoginPhase value) {
    if (value != _phase && mounted) {
      setState(() {
        _phase = value;
      });
    }
  }

  late bool _passwordNeedsReset;
  bool get passwordNeedsReset => _passwordNeedsReset;
  set passwordNeedsReset(bool value) {
    if (value != _passwordNeedsReset) {
      setState(() {
        _passwordNeedsReset = value;
      });
    }
  }

  late bool _setCookie;

  Future<void> _initialize() async {
    phase = _LoginPhase.initializing;
    final int? invoiceId = UserBinding.instance!.user!.lastInvoiceId;
    if (invoiceId != null) {
      await InvoiceBinding.instance!.loadInvoice(invoiceId);
    }
  }

  void _close() {
    Navigator.of(context).pop<void>();
  }

  Future<void> _handleAttemptLogin(String username, String password, bool setCookie) async {
    phase = _LoginPhase.authenticating;
    _setCookie = setCookie;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (setCookie) {
      await prefs.setString(Keys.username, username);
    } else {
      await prefs.remove(Keys.username);
      await prefs.remove(Keys.password);
    }
    try {
      final User user = await UserBinding.instance!.login(username, password);
      passwordNeedsReset = user.passwordRequiresReset;
      if (setCookie) {
        await prefs.setString(Keys.password, password);
      }
      if (user.isPostLogin) {
        _close();
      }
    } on InvalidCredentials {
      errorText = _loginSpecificHttpStatusErrorMessages[HttpStatus.forbidden];
      if (setCookie) {
        await prefs.remove(Keys.password);
      }
    } on TimeoutException {
      errorText = _loginSpecificHttpStatusErrorMessages[HttpStatus.requestTimeout]!
          .replaceAll(_serverHostToken, Server.host);
    } on HttpStatusException catch (error) {
      errorText = _loginSpecificHttpStatusErrorMessages[error.statusCode];
      errorText ??= _defaultHttpStatusErrorMessage;
    } on http.ClientException {
      errorText = _httpClientErrorMessage;
    }
    phase = _LoginPhase.idle;
  }

  Future<void> _handleAttemptChangePassword(String password, bool setCookie) async {
    assert(UserBinding.instance!.user != null);
    phase = _LoginPhase.changingPassword;
    final User user = await UserBinding.instance!.user!.updatePassword(password);
    if (setCookie) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(Keys.password, password);
    }
    if (user.isPostLogin) {
      _close();
    }
  }

  static String? _statusTextFor(_LoginPhase phase) {
    switch (phase) {
      case _LoginPhase.authenticating:
        return 'Logging In...';
      case _LoginPhase.initializing:
        return 'Initializing...';
      case _LoginPhase.changingPassword:
        return 'Setting new password...';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordNeedsReset = UserBinding.instance!.user?.passwordRequiresReset ?? false;
    _setCookie = widget.username != null;
    UserBinding.instance!.addPostLoginCallback(_initialize);
  }

  @override
  void dispose() {
    UserBinding.instance!.removePostLoginCallback(_initialize);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: _LoginPane(
        username: widget.username,
        password: widget.password,
        setCookie: _setCookie,
        activityStatusText: _statusTextFor(phase),
        errorText: errorText,
        onAttemptLogin: _handleAttemptLogin,
      ),
      secondChild: _ResetPasswordPane(
        activityStatusText: _statusTextFor(phase),
        onAttemptChangePassword: _handleAttemptChangePassword,
        setCookie: _setCookie,
      ),
      crossFadeState: passwordNeedsReset ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 400),
    );
  }
}

class _LoginPane extends StatefulWidget {
  const _LoginPane({
    Key? key,
    required this.username,
    required this.password,
    required this.setCookie,
    required this.activityStatusText,
    required this.errorText,
    required this.onAttemptLogin,
  }) : super(key: key);

  /// The pre-populated value of the username field.
  final String? username;

  /// The pre-populated value of the password field.
  final String? password;

  /// Whether to default to remembering the user's username and password.
  final bool setCookie;

  /// An optional message to display to the user indicating that an
  /// asynchronous task is pending.
  ///
  /// If this is non-null, an animated activity indicator will also be shown to
  /// the user, and the "Log In" button will be disabled.
  final String? activityStatusText;

  /// An optional error message to display to the user.
  final String? errorText;

  /// Callback to invoke when the user attempts to login.
  final LoginCallback onAttemptLogin;

  @override
  _LoginPaneState createState() => _LoginPaneState();
}

class _LoginPaneState extends State<_LoginPane> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late bool _setCookie;

  void _handleAttemptLogin() {
    widget.onAttemptLogin(_usernameController.text, _passwordController.text, _setCookie);
  }

  void _handleToggleCheckbox() {
    setState(() {
      _setCookie = !_setCookie;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _passwordController = TextEditingController(text: widget.password);
    _setCookie = widget.setCookie;
  }

  @override
  void didUpdateWidget(_LoginPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.username != oldWidget.username) {
      _usernameController.text = widget.username ?? '';
    }
    if (widget.password != oldWidget.password) {
      _passwordController.text = widget.password ?? '';
    }
    if (widget.setCookie != oldWidget.setCookie) {
      _setCookie = widget.setCookie;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultStyle = DefaultTextStyle.of(context).style;
    return SizedBox(
      width: 384,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
              border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.errorText != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ScrollPane(
                          horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
                          view: Text(
                            widget.errorText!,
                            style: defaultStyle.copyWith(color: const Color(0xffb71624)),
                          ),
                        ),
                      ),
                    ),
                  Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          const TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text('Username:'),
                            ),
                          ),
                          TextInput(
                            controller: _usernameController,
                            backgroundColor: const Color(0xfff7f5ee),
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          SizedBox(height: 10),
                          SizedBox(height: 10),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          const TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text('Password:'),
                            ),
                          ),
                          TextInput(
                            controller: _passwordController,
                            backgroundColor: const Color(0xfff7f5ee),
                            obscureText: true,
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          SizedBox(height: 10),
                          SizedBox(height: 10),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          Container(),
                          BasicCheckbox(
                            spacing: 6,
                            trailing: Text('Remember my username and password'),
                            state: _setCookie ? CheckboxState.checked : CheckboxState.unchecked,
                            onTap: _handleToggleCheckbox,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.activityStatusText != null)
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: ActivityIndicator(),
                      ),
                      SizedBox(width: 4),
                      Text(widget.activityStatusText!),
                    ],
                  ),
                ),
              CommandPushButton(
                label: 'Log In',
                onPressed: widget.activityStatusText == null ? _handleAttemptLogin : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordPane extends StatefulWidget {
  const _ResetPasswordPane({
    Key? key,
    required this.activityStatusText,
    required this.onAttemptChangePassword,
    required this.setCookie,
  }) : super(key: key);

  /// An optional message to display to the user indicating that an
  /// asynchronous task is pending.
  ///
  /// If this is non-null, an animated activity indicator will also be shown to
  /// the user, and the "Change Password" button will be disabled.
  final String? activityStatusText;

  /// Callback to invoke when the user attempts to change their password.
  final ChangePasswordCallback onAttemptChangePassword;

  /// Whether to update the saved password with the new password upon
  /// successfully updating the user's password.
  final bool setCookie;

  @override
  _ResetPasswordPaneState createState() => _ResetPasswordPaneState();
}

class _ResetPasswordPaneState extends State<_ResetPasswordPane> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String? _errorText;
  String? get errorText => _errorText;
  set errorText(String? value) {
    if (value != _errorText) {
      setState(() {
        _errorText = value;
      });
    }
  }

  void _handleResetPassword() {
    if (_passwordController.text.isEmpty) {
      errorText = 'Your new password cannot be blank.';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      errorText = 'Your new password entries do not match.';
    } else {
      widget.onAttemptChangePassword(_passwordController.text, widget.setCookie);
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultStyle = DefaultTextStyle.of(context).style;
    return SizedBox(
      width: 384,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
              border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  errorText != null
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 200),
                            child: ScrollPane(
                              horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
                              view: Text(
                                errorText!,
                                style: defaultStyle.copyWith(color: const Color(0xffb71624)),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('Your current password was set automatically for you and is '
                              'thus not secure.  Please choose a new secret password below.'),
                        ),
                  Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          const TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text('New password:'),
                            ),
                          ),
                          TextInput(
                            controller: _passwordController,
                            backgroundColor: const Color(0xfff7f5ee),
                            obscureText: true,
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          SizedBox(height: 10),
                          SizedBox(height: 10),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          const TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text('Confirm new password:'),
                            ),
                          ),
                          TextInput(
                            controller: _confirmPasswordController,
                            backgroundColor: const Color(0xfff7f5ee),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.activityStatusText != null)
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: ActivityIndicator(),
                      ),
                      SizedBox(width: 4),
                      Text(widget.activityStatusText!),
                    ],
                  ),
                ),
              CommandPushButton(
                label: 'OK',
                onPressed: widget.activityStatusText == null ? _handleResetPassword : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
