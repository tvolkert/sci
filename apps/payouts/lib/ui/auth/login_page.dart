import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:payouts/ui/loading.dart';
import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_route.dart';
import 'package:payouts/ui/invoice/invoice_home.dart';

const String _authUrl = 'https://www.satelliteconsulting.com/payoutsLogin';

const String _lastInvoiceIdKey = 'last_invoice_id';
const String _passwordRequiresResetKey = 'password_temporary';

const Map<int, String> _httpStatusCodes = <int, String>{
  400: 'bad request',
  401: 'unauthorized',
  404: 'not found',
  500: 'internal server error',
  501: 'not implemented',
  502: 'bad gateway',
  503: 'service unavailable',
  504: 'gateway timeout',
};

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String username;
  String password;
  Future<http.Response> pendingLogin;
  String errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (UserBinding.of(context) != null) {
      // No need to log-in; the user is already logged in.
      return;
    }

    CredentialsProvider credentials = PersistentCredentials.of(context);
    username = credentials.username;
    password = credentials.password;
    if (username != null && password != null) {
      _doLogin(username, password);
    }
  }

  void _doLogin(String username, String password) {
    if (pendingLogin != null) {
      return;
    }

    String token = base64.encode(latin1.encode('$username:$password'));
    try {
      pendingLogin = http.get(
        _authUrl,
        headers: <String, String>{
          'Authorization': 'Basic ${token.trim()}',
        },
      ).then<http.Response>((http.Response response) {
        setState(() {
          pendingLogin = null;
          errorMessage = null;

          if (response.statusCode == 200) {
            Map<String, dynamic> loginData = json.decode(response.body).cast<String, dynamic>();
            int lastInvoiceId = loginData[_lastInvoiceIdKey];
            bool passwordRequiresReset = loginData[_passwordRequiresResetKey];

            PersistentCredentials.update(context, username, password);
            UserBinding.update(
              context,
              username,
              password,
              lastInvoiceId: lastInvoiceId,
              passwordRequiresReset: passwordRequiresReset,
            );

            if (lastInvoiceId != null) {
              InvoiceBinding.of(context).invoiceId = lastInvoiceId;
            }
          } else if (response.statusCode == 403) {
            errorMessage = 'Invalid username or password';
          } else {
            errorMessage = '${response.statusCode} ${_httpStatusCodes[response.statusCode]}';
          }
        });

        return response;
      }).catchError((dynamic error, StackTrace stackTrace) {
        debugPrint('$error\n$stackTrace');
        setState(() {
          pendingLogin = null;
          errorMessage = '$error';
        });
      }).timeout(const Duration(seconds: 5), onTimeout: () {
        setState(() {
          pendingLogin = null;
          errorMessage = 'Timeout while trying to log in';
        });
      });
    } catch (error, stackTrace) {
      debugPrint('$error\n$stackTrace');
    }
  }

  void _login(String username, String password) {
    setState(() => _doLogin(username, password));
  }

  @override
  Widget build(BuildContext context) {
    if (pendingLogin != null) {
      return Loading('Logging In');
    }

    MediaQueryData mediaQuery = MediaQuery.of(context);
    EdgeInsets minInsets = mediaQuery.padding.copyWith(bottom: mediaQuery.viewInsets.bottom);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        print('${viewportConstraints.maxHeight + minInsets.bottom}');
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight + minInsets.bottom,
            ),
            child: Material(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      child: Image.asset('assets/logo.png'),
                    ),
                    Text(
                      'SCI Payouts',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0x2f, 0x4e, 0x6f),
                        letterSpacing: 2.0,
                        fontFamily: 'AF Battersea',
                      ),
                    ),
                    SizedBox(height: 24),
                    errorMessage == null ? Container() : Text(errorMessage, style: TextStyle(color: Colors.red)),
                    /*Expanded(
                      child: */Form(
                        key: _formKey,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TextFormField(
                                initialValue: username,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  filled: true,
                                  icon: Icon(Icons.person),
                                  labelText: 'Username',
                                ),
                                onSaved: (String value) => username = value,
                                validator: (String input) {
                                  if (RegExp(r'^[a-zA-Z]+$').hasMatch(input)) {
                                    return null;
                                  }
                                  return 'Invalid username';
                                },
                              ),
                              SizedBox(height: 24),
                              TextFormField(
                                initialValue: password,
                                obscureText: true,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  filled: true,
                                  icon: Icon(Icons.verified_user),
                                  labelText: 'Password',
                                ),
                                onSaved: (String value) => password = value,
                                validator: null,
                              ),
                              SizedBox(height: 24),
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 40),
                                  RaisedButton(
                                    child: Text('Log In'),
                                    onPressed: () {
                                      final FormState form = _formKey.currentState;
                                      form.save();
                                      _login(username, password);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    //),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: Image.asset('assets/logo.png'),
                  ),
                  Text(
                    'SCI Payouts',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0x2f, 0x4e, 0x6f),
                      letterSpacing: 2.0,
                      fontFamily: 'AF Battersea',
                    ),
                  ),
                  SizedBox(height: 24),
                  errorMessage == null ? Container() : Text(errorMessage, style: TextStyle(color: Colors.red)),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextFormField(
                              initialValue: username,
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                icon: Icon(Icons.person),
                                labelText: 'Username',
                              ),
                              onSaved: (String value) => username = value,
                              validator: (String input) {
                                if (RegExp(r'^[a-zA-Z]+$').hasMatch(input)) {
                                  return null;
                                }
                                return 'Invalid username';
                              },
                            ),
                            SizedBox(height: 24),
                            TextFormField(
                              initialValue: password,
                              obscureText: true,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                icon: Icon(Icons.verified_user),
                                labelText: 'Password',
                              ),
                              onSaved: (String value) => password = value,
                              validator: null,
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 40),
                                RaisedButton(
                                  child: Text('Log In'),
                                  onPressed: () {
                                    final FormState form = _formKey.currentState;
                                    form.save();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
