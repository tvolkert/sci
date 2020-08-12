import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class AddTimesheetIntent extends Intent {
  const AddTimesheetIntent({this.context});

  final BuildContext context;
}

class AddTimesheetAction extends ContextAction<AddTimesheetIntent> {
  @override
  Future<void> invoke(AddTimesheetIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await AddTimesheetSheet.open(context: context);
    print('TODO: add timesheet');
  }
}

class AddTimesheetSheet extends StatefulWidget {
  const AddTimesheetSheet({Key key}) : super(key: key);

  @override
  _AddTimesheetSheetState createState() => _AddTimesheetSheetState();

  static Future<void> open({BuildContext context}) {
    return pivot.Sheet.open<void>(
      context: context,
      content: AddTimesheetSheet(),
    );
  }
}

class _AddTimesheetSheetState extends State<AddTimesheetSheet> {
  @override
  void initState() {
    super.initState();
    // TODO: Really fetch billing periods
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 4),
              pivot.CommandPushButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
