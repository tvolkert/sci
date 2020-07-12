import 'package:flutter/material.dart';

import 'package:payouts/model/user.dart';
import 'package:payouts/ui/auth/login_page.dart';
import 'package:payouts/ui/auth/user_binding.dart';

class RequireUser extends StatefulWidget {
  const RequireUser({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _RequireUserState createState() => _RequireUserState();
}

class _RequireUserState extends State<RequireUser> {
  @override
  void initState() {
    super.initState();
    debugPrint('RequireUser.initState()');
  }

  @override
  Widget build(BuildContext context) {
    User user = UserBinding.of(context);
    return user == null ? const LoginPage() : widget.child;
  }
}