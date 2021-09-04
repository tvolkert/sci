import 'dart:async';

import 'package:chicago/chicago.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/ui/invoice_entry_editor.dart';

class AddTimesheetIntent extends Intent {
  const AddTimesheetIntent({this.context});

  final BuildContext? context;
}

class AddTimesheetAction extends ContextAction<AddTimesheetIntent> with TrackInvoiceMixin {
  AddTimesheetAction._() {
    startTrackingInvoiceActivity();
  }

  static final AddTimesheetAction instance = AddTimesheetAction._();

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
  bool isEnabled(AddTimesheetIntent intent) {
    return isInvoiceOpened && !openedInvoice.isSubmitted;
  }

  @override
  Future<void> invoke(AddTimesheetIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final InvoiceEntryMetadata? metadata = await AddTimesheetSheet.open(context: context);
    if (metadata != null) {
      openedInvoice.timesheets.add(metadata);
    }
  }
}

abstract class TimesheetEditor extends InvoiceEntryEditor {
  const TimesheetEditor({Key? key}) : super(key: key);

  @override
  @protected
  TimesheetEditorState<TimesheetEditor> createState();
}

abstract class TimesheetEditorState<T extends TimesheetEditor> extends InvoiceEntryEditorState<T> {
  @protected
  bool validateMetadata(InvoiceEntryMetadata metadata);

  @override
  @protected
  @nonVirtual
  List<FormPaneField> buildFormFields() {
    return <FormPaneField>[
      buildProgramFormField(),
      if (requiresChargeNumber) buildChargeNumberFormField(),
      if (requiresRequestor) buildRequestorFormField(),
      buildTaskFormField(),
    ];
  }

  @override
  @protected
  @nonVirtual
  void handleOk() {
    bool isInputValid = true;

    final Program? selectedProgram = program.selectedValue;
    final String chargeNumberValue = chargeNumber.controller.text.trim();
    final String requestorValue = requestor.controller.text.trim();
    final String taskValue = task.controller.text.trim();

    if (selectedProgram == null) {
      isInputValid = false;
      program.flag = flagFromMessage('TODO');
    } else {
      program.flag = null;
    }

    if (isInputValid) {
      final InvoiceEntryMetadata metadata = InvoiceEntryMetadata(
        program: selectedProgram!,
        chargeNumber: chargeNumberValue,
        requestor: requestorValue,
        task: taskValue,
      );

      isInputValid = validateMetadata(metadata);
      if (isInputValid) {
        Navigator.of(context).pop<InvoiceEntryMetadata>(metadata);
      }
    }

    if (!isInputValid) {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}

class AddTimesheetSheet extends TimesheetEditor {
  const AddTimesheetSheet({Key? key}) : super(key: key);

  @override
  _AddTimesheetSheetState createState() => _AddTimesheetSheetState();

  static Future<InvoiceEntryMetadata?> open({required BuildContext context}) {
    return Sheet.open<InvoiceEntryMetadata>(
      context: context,
      content: AddTimesheetSheet(),
      barrierDismissible: true,
    );
  }
}

class _AddTimesheetSheetState extends TimesheetEditorState<AddTimesheetSheet> {
  @override
  @protected
  bool validateMetadata(InvoiceEntryMetadata metadata) {
    bool isInputValid = true;

    if (InvoiceBinding.instance!.invoice!.timesheets.indexOf(metadata) >= 0) {
      program.flag = flagFromMessage('A timesheet already exists for this program');
      isInputValid = false;
    }

    if (metadata.program.requiresChargeNumber) {
      isInputValid &= validateRequiredField(chargeNumber);
    }

    if (metadata.program.requiresRequestor) {
      isInputValid &= validateRequiredField(requestor);
    }

    return isInputValid;
  }
}
