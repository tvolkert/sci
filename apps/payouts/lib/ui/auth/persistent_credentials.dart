import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart' as path;

import 'package:payouts/ui/loading.dart';

const String _usernameKey = 'username';
const String _passwordKey = 'password';
const String _filename = 'credentials';

abstract class CredentialsProvider {
  String get username;

  String get password;
}

class PersistentCredentials extends StatefulWidget {
  PersistentCredentials({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _CredentialsState();
  }

  static CredentialsProvider of(BuildContext context) {
    _CredentialsScope scope = context.inheritFromWidgetOfExactType(_CredentialsScope);
    return scope.credentialsState;
  }

  static void update(BuildContext context, String username, String password) {
    _CredentialsScope scope = context.inheritFromWidgetOfExactType(_CredentialsScope);
    scope.credentialsState._update(username, password);
  }
}

class _CredentialsState extends State<PersistentCredentials> implements CredentialsProvider {
  bool loaded = false;
  String username;
  String password;

  void _update(String username, String password) {
    setState(() {
      this.username = username;
      this.password = password;
    });

    // Fire and forget; if this doesn't finish successfully, meh.
    path.getApplicationDocumentsDirectory().then((Directory directory) async {
      Map<String, String> data = <String, String>{
        _usernameKey: username,
        _passwordKey: password,
      };
      String content = json.encode(data);

      File credentials = File('${directory.path}/$_filename');
      await credentials.writeAsString(content);
    });
  }

  @override
  void initState() {
    super.initState();
    path.getApplicationDocumentsDirectory().then((Directory directory) async {
      File credentials = File('${directory.path}/$_filename');

      if (credentials.existsSync()) {
        String content = await credentials.readAsString();
        Map<String, String> data = json.decode(content).cast<String, String>();
        setState(() {
          username = data[_usernameKey];
          password = data[_passwordKey];
          loaded = true;
        });
      } else {
        setState(() {
          loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loaded
        ? _CredentialsScope(credentialsState: this, child: widget.child)
        : const Loading('Loading');
  }
}

class _CredentialsScope extends InheritedWidget {
  const _CredentialsScope({
    Key key,
    this.credentialsState,
    Widget child,
  }) : super(key: key, child: child);

  final _CredentialsState credentialsState;

  @override
  bool updateShouldNotify(_CredentialsScope old) => false;
}
