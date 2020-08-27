import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/user.dart';
import 'package:payouts/src/actions.dart';

class RequireUser extends StatefulWidget {
  const RequireUser({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _RequireUserState createState() => _RequireUserState();
}

class _RequireUserState extends State<RequireUser> {
  bool _isLoginDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    if (UserBinding.instance.user == null) {
      if (!_isLoginDialogOpen) {
        _isLoginDialogOpen = true;
        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
          Future<void> loginResult = Actions.invoke(context, LoginIntent(context: context));
          loginResult.then((void _) => setState(() {
            _isLoginDialogOpen = false;
          }));
        });
      }
      return Container();
    }
    return widget.child;
  }
}
