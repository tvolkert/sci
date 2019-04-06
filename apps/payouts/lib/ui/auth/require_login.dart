import 'package:flutter/material.dart';

import 'package:payouts/model/user.dart';
import 'package:payouts/ui/auth/login_page.dart';
import 'package:payouts/ui/auth/user_binding.dart';

class RequireLogin extends StatefulWidget {
  RequireLogin({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _RequireLoginState createState() => _RequireLoginState();
}

class _RequireLoginState extends State<RequireLogin> {
  @override
  Widget build(BuildContext context) {
    User user = UserBinding.of(context);
    return user != null ? widget.child : LoginPage();
  }
}
