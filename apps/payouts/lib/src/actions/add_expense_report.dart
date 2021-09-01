import 'dart:async';

import 'package:chicago/chicago.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/ui/invoice_entry_editor.dart';

class AddExpenseReportIntent extends Intent {
  const AddExpenseReportIntent({this.context});

  final BuildContext? context;
}

class AddExpenseReportAction extends ContextAction<AddExpenseReportIntent> with TrackInvoiceMixin {
  AddExpenseReportAction._() {
    startTrackingInvoiceActivity();
  }

  static final AddExpenseReportAction instance = AddExpenseReportAction._();

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
  bool isEnabled(AddExpenseReportIntent intent) {
    return isInvoiceOpened && !openedInvoice.isSubmitted;
  }

  @override
  Future<void> invoke(AddExpenseReportIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final ExpenseReportMetadata? metadata = await AddExpenseReportSheet.open(context: context);
    if (metadata != null) {
      InvoiceBinding.instance!.invoice!.expenseReports.add(metadata);
    }
  }
}

class AddExpenseReportSheet extends InvoiceEntryEditor {
  const AddExpenseReportSheet({Key? key}) : super(key: key);

  @override
  InvoiceEntryEditorState<InvoiceEntryEditor> createState() => AddExpenseReportSheetState();

  static Future<ExpenseReportMetadata?> open({required BuildContext context}) {
    return Sheet.open<ExpenseReportMetadata>(
      context: context,
      content: AddExpenseReportSheet(),
      barrierDismissible: true,
    );
  }
}

class AddExpenseReportSheetState extends InvoiceEntryEditorState<AddExpenseReportSheet> {
  late InvoiceEntryTextField _purpose;
  late InvoiceEntryTextField _destination;
  late InvoiceEntryTextField _parties;
  bool _programIsBillable = false;

  @override
  void initState() {
    super.initState();
    _purpose = InvoiceEntryTextField();
    _destination = InvoiceEntryTextField();
    _parties = InvoiceEntryTextField();
  }

  @override
  void dispose() {
    _purpose.dispose();
    _destination.dispose();
    _parties.dispose();
    super.dispose();
  }

  @override
  List<FormPaneField> buildFormFields() {
    return <FormPaneField>[
      buildProgramFormField(),
      if (requiresChargeNumber) buildChargeNumberFormField(),
      if (requiresRequestor) buildRequestorFormField(),
      buildTaskFormField(),
      if (_programIsBillable) buildTextFormField(_purpose, 'Purpose of travel'),
      if (_programIsBillable) buildTextFormField(_destination, 'Destination (city)'),
      if (_programIsBillable) buildTextFormField(_parties, 'Party or parties visited'),
    ];
  }

  @override
  handleProgramSelected() {
    super.handleProgramSelected();
    setState(() {
      _programIsBillable = selectedProgram!.isBillable;
    });
  }

  @override
  void handleOk() {
    bool isInputValid = true;

    final Invoice invoice = InvoiceBinding.instance!.invoice!;
    final Program? selectedProgram = this.selectedProgram;
    final String chargeNumberValue = chargeNumber.controller.text.trim();
    final String requestorValue = requestor.controller.text.trim();
    final String taskValue = task.controller.text.trim();
    final DateRange period = invoice.billingPeriod;
    final String travelPurpose = _purpose.controller.text.trim();
    final String travelDestination = _destination.controller.text.trim();
    final String travelParties = _parties.controller.text.trim();

    if (selectedProgram == null) {
      isInputValid = false;
      programFlag = flagFromMessage('TODO');
    } else {
      programFlag = null;
    }

    if (isInputValid) {
      if (selectedProgram!.isBillable) {
        isInputValid &= validateRequiredField(_parties);
        isInputValid &= validateRequiredField(_destination);
        isInputValid &= validateRequiredField(_purpose);
      }

      if (selectedProgram.requiresRequestor) {
        isInputValid &= validateRequiredField(requestor);
      }

      if (selectedProgram.requiresChargeNumber) {
        isInputValid &= validateRequiredField(chargeNumber);
      }

      if (isInputValid) {
        final ExpenseReportMetadata metadata = ExpenseReportMetadata(
          program: selectedProgram,
          chargeNumber: chargeNumberValue,
          requestor: requestorValue,
          task: taskValue,
          period: period,
          travelPurpose: travelPurpose,
          travelDestination: travelDestination,
          travelParties: travelParties,
        );

        if (invoice.expenseReports.indexOf(metadata) >= 0) {
          programFlag = flagFromMessage('An expense report already exists for this program');
          isInputValid = false;
        }

        if (isInputValid) {
          Navigator.of(context).pop<ExpenseReportMetadata>(metadata);
        }
      }
    }

    if (!isInputValid) {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
