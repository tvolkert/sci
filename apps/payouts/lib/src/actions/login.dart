import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:payouts/src/model/http.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/user.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class LoginIntent extends Intent {
  const LoginIntent({this.context});

  final BuildContext context;
}

class LoginAction extends ContextAction<LoginIntent> {
  @override
  Future<void> invoke(LoginIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    // TODO: really fetch saved username
    String savedUsername = 'tvolkert';
    await LoginSheet.open(context: context, username: savedUsername);
  }
}

class LoginSheet extends StatefulWidget {
  const LoginSheet({Key key, this.username}) : super(key: key);

  /// The pre-populated value of the username field.
  final String username;

  @override
  _LoginSheetState createState() => _LoginSheetState();

  static Future<void> open({BuildContext context, String username}) {
    return pivot.Sheet.open<void>(
      context: context,
      barrierColor: const Color(0x00000000),
      content: LoginSheet(username: username),
    );
  }
}

enum _LoginPhase {
  idle,
  authenticating,
  loadingInvoice,
}

class _LoginSheetState extends State<LoginSheet> with SingleTickerProviderStateMixin {
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  String _errorText;
  String get errorText => _errorText;
  set errorText(String value) {
    if (value != _errorText) {
      setState(() {
        _errorText = value;
      });
    }
  }

  _LoginPhase _phase = _LoginPhase.idle;
  _LoginPhase get phase => _phase;
  set phase(_LoginPhase value) {
    if (value != _phase) {
      setState(() {
        _phase = value;
      });
    }
  }

  Future<void> _handleAttemptLogin() async {
    phase = _LoginPhase.authenticating;
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    try {
      final User user = await UserBinding.instance.login(username, password);
      if (user.passwordRequiresReset) {
        // TODO: handle reset password
      } else {
        final int invoiceId = user.lastInvoiceId;
        if (invoiceId != null) {
          phase = _LoginPhase.loadingInvoice;
          await InvoiceBinding.instance.openInvoice(invoiceId);
        }
        Navigator.of(context).pop<void>();
        return;
      }
    } on InvalidCredentials {
      errorText = 'Invalid ID or password.';
    } on TimeoutException {
      errorText = 'TODO Timeout';
    } on HttpStatusException catch (error) {
      StringBuffer buf = StringBuffer()
        ..writeAll(<dynamic>[
          'HTTP ',
          error.statusCode,
          if (error.statusMessage != null) ' (${error.statusMessage})',
          if (error.message != null) '\n\n${error.message}',
        ]);
      errorText = buf.toString();
    }
    phase = _LoginPhase.idle;
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultStyle = DefaultTextStyle.of(context).style;
    return SizedBox(
      width: 385,
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (errorText != null)
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: pivot.ScrollPane(
                          horizontalScrollBarPolicy: pivot.ScrollBarPolicy.stretch,
                          view: Text(
                            errorText,
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
                              padding: EdgeInsets.all(5),
                              child: Text('Username:'),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: TextField(
                              controller: _usernameController,
                              cursorWidth: 1,
                              cursorColor: Colors.black,
                              style: TextStyle(fontFamily: 'Verdana', fontSize: 11),
                              decoration: const InputDecoration(
                                fillColor: Color(0xfff7f5ee),
                                hoverColor: Color(0xfff7f5ee),
                                filled: true,
                                contentPadding: EdgeInsets.fromLTRB(3, 13, 0, 4),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff999999)),
                                  borderRadius: BorderRadius.zero,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff999999)),
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          const TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Password:'),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: TextField(
                              obscureText: true,
                              controller: _passwordController,
                              cursorWidth: 1,
                              cursorColor: Colors.black,
                              style: TextStyle(fontFamily: 'Verdana', fontSize: 11),
                              decoration: const InputDecoration(
                                fillColor: Color(0xfff7f5ee),
                                hoverColor: Color(0xfff7f5ee),
                                filled: true,
                                contentPadding: EdgeInsets.fromLTRB(3, 13, 0, 4),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff999999)),
                                  borderRadius: BorderRadius.zero,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff999999)),
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          Container(),
                          Row(
                            children: <Widget>[
                              Checkbox(
                                visualDensity: VisualDensity.compact,
                                value: false,
                                onChanged: (bool value) {},
                              ),
                              Text('Remember my username and password'),
                            ],
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
              if (_phase != _LoginPhase.idle)
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: pivot.ActivityIndicator(),
                      ),
                      SizedBox(width: 4),
                      Text(_phase == _LoginPhase.authenticating ? 'Logging In...' : 'Initializing...'),
                    ],
                  ),
                ),
              pivot.CommandPushButton(
                label: 'Log In',
                onPressed: _phase == _LoginPhase.idle ? _handleAttemptLogin : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
