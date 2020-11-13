import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/pivot.dart' as pivot;

import 'add_timesheet.dart';

class EditTimesheetIntent extends Intent {
  const EditTimesheetIntent(this.timesheet);

  final Timesheet timesheet;
}

class EditTimesheetAction extends ContextAction<EditTimesheetIntent> {
  EditTimesheetAction._();

  static final EditTimesheetAction instance = EditTimesheetAction._();

  @override
  Future<void> invoke(EditTimesheetIntent intent, [BuildContext? context]) async {
    context ??= primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final InvoiceEntryMetadata? metadata = await EditTimesheetSheet.open(
      context: context,
      timesheet: intent.timesheet,
    );
    if (metadata != null) {
      intent.timesheet.update(
        chargeNumber: metadata.chargeNumber,
        requestor: metadata.requestor,
        taskDescription: metadata.task,
      );
    }
  }
}

class EditTimesheetSheet extends TimesheetMetadataSheet {
  const EditTimesheetSheet({
    Key? key,
    required this.timesheet,
  }) : super(key: key);

  final Timesheet timesheet;

  @override
  _EditTimesheetSheetState createState() => _EditTimesheetSheetState();

  static Future<InvoiceEntryMetadata?> open({
    required BuildContext context,
    required Timesheet timesheet,
  }) {
    return pivot.Sheet.open<InvoiceEntryMetadata>(
      context: context,
      content: EditTimesheetSheet(timesheet: timesheet),
      barrierDismissible: true,
    );
  }
}

class _EditTimesheetSheetState extends TimesheetMetadataSheetState<EditTimesheetSheet> {
  @override
  @protected
  void onLoad() {
    super.onLoad();
    final Program program = widget.timesheet.program;
    final int selectedIndex = AssignmentsBinding.instance!.assignments!.indexOf(program);
    programSelectionController.selectedIndex = selectedIndex;
    chargeNumberController.text = widget.timesheet.chargeNumber;
    requestorController.text = widget.timesheet.requestor;
    taskController.text = widget.timesheet.task;
    programIsReadOnly = true;
  }

  @override
  @protected
  bool validateMetadata(InvoiceEntryMetadata metadata) {
    bool isInputValid = true;

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
