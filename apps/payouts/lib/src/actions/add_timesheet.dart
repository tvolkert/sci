import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:payouts/src/model/invoice.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class AddTimesheetIntent extends Intent {
  const AddTimesheetIntent({this.context});

  final BuildContext context;
}

class AddTimesheetAction extends ContextAction<AddTimesheetIntent> {
  AddTimesheetAction._();

  static final AddTimesheetAction instance = AddTimesheetAction._();

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
  List<Program> _assignments;

  Widget _buildProgram({BuildContext context, Program item}) {
    return pivot.ListButton.defaultBuilder(
      context: context,
      item: item == null ? '' : item.name,
    );
  }

  Widget _buildProgramItem({
    BuildContext context,
    Program item,
    bool isSelected,
    bool isHighlighted,
    bool isDisabled,
  }) {
    return pivot.ListButton.defaultItemBuilder(
      context: context,
      item: item.name,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
      isDisabled: isDisabled,
    );
  }

  @override
  void initState() {
    super.initState();
    _assignments = AssignmentsBinding.instance.assignments;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pivot.Border(
            backgroundColor: const Color(0xffffffff),
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: pivot.Form(
                children: [
                  pivot.FormField(
                    label: 'Program',
                    child: pivot.ListButton<Program>(
                      width: pivot.ExpandedListButtonWidth(),
                      items: _assignments,
                      builder: _buildProgram,
                      itemBuilder: _buildProgramItem,
                    ),
                  ),
                  pivot.FormField(
                    label: 'Charge Number',
                    child: pivot.TextInput(
                      backgroundColor: const Color(0xfff7f5ee),
                    ),
                  ),
                  pivot.FormField(
                    label: 'Requestor (Client)',
                    child: pivot.TextInput(
                      backgroundColor: const Color(0xfff7f5ee),
                    ),
                  ),
                  pivot.FormField(
                    label: 'Task',
                    child: Row(
                      children: [
                        Expanded(
                          child: pivot.TextInput(
                            backgroundColor: const Color(0xfff7f5ee),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text('(optional)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 6),
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
