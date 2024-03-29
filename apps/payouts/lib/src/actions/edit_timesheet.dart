import 'package:chicago/chicago.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';

import 'add_timesheet.dart';

class EditTimesheetIntent extends Intent {
  const EditTimesheetIntent(this.timesheet);

  final Timesheet timesheet;
}

class EditTimesheetAction extends ContextAction<EditTimesheetIntent> with TrackInvoiceMixin {
  EditTimesheetAction._() {
    startTrackingInvoiceActivity();
  }

  static final EditTimesheetAction instance = EditTimesheetAction._();

  @override
  void onInvoiceOpenedChanged() {
    super.onInvoiceOpenedChanged();
    notifyActionListeners();
  }

  @override
  void onInvoiceSubmittedChanged() {
    super.onInvoiceSubmittedChanged();
    notifyActionListeners();
  }

  @override
  bool isEnabled(EditTimesheetIntent intent) {
    return isInvoiceOpened && !openedInvoice.isSubmitted;
  }

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

class EditTimesheetSheet extends TimesheetEditor {
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
    return Sheet.open<InvoiceEntryMetadata>(
      context: context,
      content: EditTimesheetSheet(timesheet: timesheet),
      barrierDismissible: true,
    );
  }
}

class _EditTimesheetSheetState extends TimesheetEditorState<EditTimesheetSheet> {
  @override
  @protected
  void initState() {
    super.initState();
    final Program timesheetProgram = widget.timesheet.program;
    final int selectedIndex = program.data.indexOf(timesheetProgram);
    program.controller.selectedIndex = selectedIndex;
    chargeNumber.controller.text = widget.timesheet.chargeNumber;
    requestor.controller.text = widget.timesheet.requestor;
    task.controller.text = widget.timesheet.task;
    program.isReadOnly = true;
  }

  @override
  @protected
  bool validateMetadata(InvoiceEntryMetadata metadata) {
    bool isInputValid = true;

    if (metadata.program.requiresChargeNumber) {
      isInputValid &= validateRequiredField(chargeNumber);
    }

    if (metadata.program.requiresRequestor) {
      isInputValid &= validateRequiredField(requestor);
    }

    return isInputValid;
  }
}
