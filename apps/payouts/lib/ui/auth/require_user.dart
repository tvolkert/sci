import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/user.dart';
import 'package:payouts/src/actions.dart';

class RequireUser extends StatefulWidget {
  const RequireUser({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _RequireUserState createState() => _RequireUserState();
}

class _RequireUserState extends State<RequireUser> {
  bool _isLoginDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final User? user = UserBinding.instance!.user;
    if (user == null || _isLoginDialogOpen || user.passwordRequiresReset) {
      if (!_isLoginDialogOpen) {
        _isLoginDialogOpen = true;
        SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          Future<void> loginResult =
              Actions.invoke(context, LoginIntent(context: context)) as Future<void>;
          loginResult.then((void _) {
            setState(() {
              _isLoginDialogOpen = false;
            });
          });
        });
      }
      return ColoredBox(color: const Color(0xffc8c8bb));
    }
    return widget.child;
  }
}
