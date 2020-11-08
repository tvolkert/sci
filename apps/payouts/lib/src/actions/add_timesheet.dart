import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:payouts/src/model/invoice.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class AddTimesheetIntent extends Intent {
  const AddTimesheetIntent({this.context});

  final BuildContext? context;
}

class AddTimesheetAction extends ContextAction<AddTimesheetIntent> {
  AddTimesheetAction._();

  static final AddTimesheetAction instance = AddTimesheetAction._();

  @override
  Future<void> invoke(AddTimesheetIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final _TimesheetMetadata? metadata = await AddTimesheetSheet.open(context: context);
    if (metadata != null) {
      InvoiceBinding.instance!.invoice!.timesheets.add(
        program: metadata.program,
        chargeNumber: metadata.chargeNumber,
        requestor: metadata.requestor,
        task: metadata.task,
      );
    }
  }
}

class AddTimesheetSheet extends StatefulWidget {
  const AddTimesheetSheet({Key? key}) : super(key: key);

  @override
  _AddTimesheetSheetState createState() => _AddTimesheetSheetState();

  static Future<_TimesheetMetadata?> open({required BuildContext context}) {
    return pivot.Sheet.open<_TimesheetMetadata>(
      context: context,
      content: AddTimesheetSheet(),
    );
  }
}

class _AddTimesheetSheetState extends State<AddTimesheetSheet> {
  late List<Program> _assignments;
  bool _requiresChargeNumber = false;
  bool _requiresRequestor = false;
  pivot.Flag? _programFlag;
  pivot.Flag? _chargeNumberFlag;
  pivot.Flag? _requestorFlag;
  late pivot.ListViewSelectionController _programSelectionController;
  late TextEditingController _chargeNumberController;
  late TextEditingController _requestorController;
  late TextEditingController _taskController;

  Widget _buildProgram({required BuildContext context, required Program? item}) {
    return pivot.ListButton.defaultBuilder(
      context: context,
      item: item == null ? '' : item.name,
    );
  }

  Widget _buildProgramItem({
    required BuildContext context,
    required Program item,
    required bool isSelected,
    required bool isHighlighted,
    required bool isDisabled,
  }) {
    return pivot.ListButton.defaultItemBuilder(
      context: context,
      item: item.name,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
      isDisabled: isDisabled,
    );
  }

  Program? get _selectedProgram {
    return _programSelectionController.selectedIndex >= 0
        ? _assignments[_programSelectionController.selectedIndex]
        : null;
  }

  void _handleProgramSelected() {
    final Program selectedProgram = _selectedProgram!;
    setState(() {
      _requiresChargeNumber = selectedProgram.requiresChargeNumber;
      _requiresRequestor = selectedProgram.requiresRequestor;
    });
  }

  void _handleOk() {
    bool isInputValid = true;

    final Program? selectedProgram = _selectedProgram;
    final String chargeNumber = _chargeNumberController.text.trim();
    final String requestor = _requestorController.text.trim();
    final String task = _taskController.text.trim();

    if (selectedProgram == null) {
      isInputValid = false;
      setState(() {
        _programFlag = pivot.Flag(
          messageType: pivot.MessageType.warning,
          message: 'TODO',
        );
      });
    } else {
      setState(() {
        _programFlag = null;
      });
    }

    if (_requiresChargeNumber && chargeNumber.isEmpty) {
      isInputValid = false;
      setState(() {
        _chargeNumberFlag = pivot.Flag(
          messageType: pivot.MessageType.warning,
          message: 'TODO',
        );
      });
    } else {
      setState(() {
        _chargeNumberFlag = null;
      });
    }

    if (_requiresRequestor && requestor.isEmpty) {
      isInputValid = false;
      setState(() {
        _requestorFlag = pivot.Flag(
          messageType: pivot.MessageType.warning,
          message: 'TODO',
        );
      });
    } else {
      setState(() {
        _requestorFlag = null;
      });
    }

    if (isInputValid) {
      final _TimesheetMetadata metadata = _TimesheetMetadata(
        program: selectedProgram!,
        chargeNumber: chargeNumber,
        requestor: requestor,
        task: task,
      );
      Navigator.of(context)!.pop<_TimesheetMetadata>(metadata);
    }
  }

  @override
  void initState() {
    super.initState();
    _assignments = AssignmentsBinding.instance!.assignments!;
    _programSelectionController = pivot.ListViewSelectionController();
    _programSelectionController.addListener(_handleProgramSelected);
    _chargeNumberController = TextEditingController();
    _requestorController = TextEditingController();
    _taskController = TextEditingController();
  }

  @override
  void dispose() {
    _programSelectionController.removeListener(_handleProgramSelected);
    _programSelectionController.dispose();
    _chargeNumberController.dispose();
    _requestorController.dispose();
    _taskController.dispose();
    super.dispose();
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
                    flag: _programFlag,
                    child: pivot.ListButton<Program>(
                      width: pivot.ExpandedListButtonWidth(),
                      items: _assignments,
                      selectionController: _programSelectionController,
                      builder: _buildProgram,
                      itemBuilder: _buildProgramItem,
                    ),
                  ),
                  if (_requiresChargeNumber)
                    pivot.FormField(
                      label: 'Charge Number',
                      flag: _chargeNumberFlag,
                      child: pivot.TextInput(
                        backgroundColor: const Color(0xfff7f5ee),
                        controller: _chargeNumberController,
                      ),
                    ),
                  if (_requiresRequestor)
                    pivot.FormField(
                      label: 'Requestor (Client)',
                      flag: _requestorFlag,
                      child: pivot.TextInput(
                        backgroundColor: const Color(0xfff7f5ee),
                        controller: _requestorController,
                      ),
                    ),
                  pivot.FormField(
                    label: 'Task',
                    child: Row(
                      children: [
                        Expanded(
                          child: pivot.TextInput(
                            backgroundColor: const Color(0xfff7f5ee),
                            controller: _taskController,
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
                onPressed: _handleOk,
              ),
              SizedBox(width: 6),
              pivot.CommandPushButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context)!.pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@immutable
class _TimesheetMetadata {
  const _TimesheetMetadata({
    required this.program,
    required this.chargeNumber,
    required this.requestor,
    required this.task,
  });

  final Program program;
  final String chargeNumber;
  final String requestor;
  final String task;
}
