import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class ActionTracker<I extends Intent> extends StatefulWidget {
  const ActionTracker({Key? key, required this.intent}) : super(key: key);

  final I intent;

  @override
  @protected
  ActionTrackerStateMixin<I, ActionTracker<I>> createState();
}

mixin ActionTrackerStateMixin<I extends Intent, T extends ActionTracker<I>> on State<T> {
  Action<I>? _action;
  bool _enabled = false;

  void _attachToAction() {
    setState(() {
      _action = Actions.find<I>(context);
      _enabled = _action!.isEnabled(widget.intent);
    });
    _action!.addActionListener(_actionUpdated as void Function(Action<Intent>));
  }

  void _detachFromAction() {
    if (_action != null) {
      _action!.removeActionListener(_actionUpdated as void Function(Action<Intent>));
      setState(() {
        _action = null;
        _enabled = false;
      });
    }
  }

  void _actionUpdated(Action<I> action) {
    setState(() {
      _enabled = action.isEnabled(widget.intent);
    });
  }

  @protected
  @nonVirtual
  bool get isEnabled => _enabled;

  @protected
  @nonVirtual
  void invokeAction() {
    assert(_action != null);
    assert(_enabled);
    assert(_action!.isEnabled(widget.intent));
    Actions.of(context).invokeAction(_action!, widget.intent, context);
  }

  @override
  @protected
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detachFromAction();
    _attachToAction();
  }
}
