import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_opened_mixin.dart';
import 'package:payouts/src/pivot.dart' as pivot;

class AddTimesheetIntent extends Intent {
  const AddTimesheetIntent({this.context});

  final BuildContext? context;
}

class AddTimesheetAction extends ContextAction<AddTimesheetIntent> with TrackInvoiceOpenedMixin {
  AddTimesheetAction._() {
    initInstance();
  }

  static final AddTimesheetAction instance = AddTimesheetAction._();

  @override
  @protected
  void onInvoiceChanged() {
    super.onInvoiceChanged();
    notifyActionListeners();
  }

  @override
  bool isEnabled(AddTimesheetIntent intent) {
    return isInvoiceOpened && !InvoiceBinding.instance!.invoice!.isSubmitted;
  }

  @override
  Future<void> invoke(AddTimesheetIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final InvoiceEntryMetadata? metadata = await AddTimesheetSheet.open(context: context);
    if (metadata != null) {
      InvoiceBinding.instance!.invoice!.timesheets.add(metadata);
    }
  }
}

enum TimesheetField {
  program,
  chargeNumber,
  requestor,
}

abstract class TimesheetMetadataSheet extends StatefulWidget {
  const TimesheetMetadataSheet({Key? key}) : super(key: key);

  @override
  TimesheetMetadataSheetState createState();
}

abstract class TimesheetMetadataSheetState<T extends TimesheetMetadataSheet> extends State<T> {
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
  bool _programIsReadOnly = false;

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
      setErrorFlag(TimesheetField.program, 'TODO');
    } else {
      setErrorFlag(TimesheetField.program, null);
    }

    if (isInputValid) {
      final InvoiceEntryMetadata metadata = InvoiceEntryMetadata(
        program: selectedProgram!,
        chargeNumber: chargeNumber,
        requestor: requestor,
        task: task,
      );

      isInputValid = validateMetadata(metadata);
      if (isInputValid) {
        Navigator.of(context)!.pop<InvoiceEntryMetadata>(metadata);
      }
    }

    if (!isInputValid) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @protected
  bool validateMetadata(InvoiceEntryMetadata metadata);

  @protected
  @mustCallSuper
  void onLoad() {
  }

  @protected
  @nonVirtual
  void setErrorFlag(TimesheetField field, String? message) {
    final pivot.Flag? flag = message == null ? null : pivot.Flag(
      messageType: pivot.MessageType.error,
      message: message,
    );
    setState(() {
      switch (field) {
        case TimesheetField.program:
          _programFlag = flag;
          break;
        case TimesheetField.chargeNumber:
          _chargeNumberFlag = flag;
          break;
        case TimesheetField.requestor:
          _requestorFlag = flag;
          break;
      }
    });
  }

  @protected
  @nonVirtual
  set programIsReadOnly(bool value) {
    if (value != _programIsReadOnly) {
      setState(() {
        _programIsReadOnly = value;
      });
    }
  }

  @protected
  @nonVirtual
  pivot.ListViewSelectionController get programSelectionController => _programSelectionController;

  @protected
  @nonVirtual
  TextEditingController get chargeNumberController => _chargeNumberController;

  @protected
  @nonVirtual
  TextEditingController get requestorController => _requestorController;

  @protected
  @nonVirtual
  TextEditingController get taskController => _taskController;

  @override
  @protected
  void initState() {
    super.initState();
    _assignments = AssignmentsBinding.instance!.assignments!;
    _programSelectionController = pivot.ListViewSelectionController();
    _programSelectionController.addListener(_handleProgramSelected);
    _chargeNumberController = TextEditingController();
    _requestorController = TextEditingController();
    _taskController = TextEditingController();
    onLoad();
  }

  @override
  @protected
  void dispose() {
    _programSelectionController.removeListener(_handleProgramSelected);
    _programSelectionController.dispose();
    _chargeNumberController.dispose();
    _requestorController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  @protected
  @nonVirtual
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
                      isEnabled: !_programIsReadOnly,
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

class AddTimesheetSheet extends TimesheetMetadataSheet {
  const AddTimesheetSheet({Key? key}) : super(key: key);

  @override
  _AddTimesheetSheetState createState() => _AddTimesheetSheetState();

  static Future<InvoiceEntryMetadata?> open({required BuildContext context}) {
    return pivot.Sheet.open<InvoiceEntryMetadata>(
      context: context,
      content: AddTimesheetSheet(),
      barrierDismissible: true,
    );
  }
}

class _AddTimesheetSheetState extends TimesheetMetadataSheetState<AddTimesheetSheet> {
  @override
  @protected
  bool validateMetadata(InvoiceEntryMetadata metadata) {
    bool isInputValid = true;

    if (InvoiceBinding.instance!.invoice!.timesheets.indexOf(metadata) >= 0) {
      setErrorFlag(TimesheetField.program, 'A timesheet already exists for this program');
      isInputValid = false;
    }

    if (metadata.program.requiresChargeNumber && metadata.chargeNumber!.isEmpty) {
      isInputValid = false;
      setErrorFlag(TimesheetField.chargeNumber, 'TODO');
    } else {
      setErrorFlag(TimesheetField.chargeNumber, null);
    }

    if (metadata.program.requiresRequestor && metadata.requestor!.isEmpty) {
      isInputValid = false;
      setErrorFlag(TimesheetField.requestor, 'TODO');
    } else {
      setErrorFlag(TimesheetField.requestor, null);
    }

    return isInputValid;
  }
}
