import 'dart:async';

import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    return chicago.Sheet.open<ExpenseReportMetadata>(
      context: context,
      content: AddExpenseReportSheet(),
      barrierDismissible: true,
    );
  }
}

class AddExpenseReportSheetState extends InvoiceEntryEditorState<AddExpenseReportSheet> {
  chicago.Flag? _travelPurposeFlag;
  chicago.Flag? _travelDestinationFlag;
  chicago.Flag? _travelPartiesFlag;
  late TextEditingController _travelPurposeController;
  late TextEditingController _travelDestinationController;
  late TextEditingController _travelPartiesController;

  @override
  void initState() {
    super.initState();
    _travelPurposeController = TextEditingController();
    _travelDestinationController = TextEditingController();
    _travelPartiesController = TextEditingController();
  }

  @override
  void dispose() {
    _travelPurposeController.dispose();
    _travelDestinationController.dispose();
    _travelPartiesController.dispose();
    super.dispose();
  }

  @override
  List<chicago.FormPaneField> buildFormFields() {
    return <chicago.FormPaneField>[
      buildProgramFormField(),
      if (requiresChargeNumber) buildChargeNumberFormField(),
      if (requiresRequestor) buildRequestorFormField(),
      buildTaskFormField(),
      chicago.FormPaneField(
        label: 'Purpose of travel',
        flag: _travelPurposeFlag,
        child: chicago.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelPurposeController,
        ),
      ),
      chicago.FormPaneField(
        label: 'Destination (city)',
        flag: _travelDestinationFlag,
        child: chicago.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelDestinationController,
        ),
      ),
      chicago.FormPaneField(
        label: 'Party or parties visited',
        flag: _travelPartiesFlag,
        child: chicago.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelPartiesController,
        ),
      ),
    ];
  }

  @override
  void handleOk() {
    bool isInputValid = true;

    final Invoice invoice = InvoiceBinding.instance!.invoice!;
    final Program? selectedProgram = this.selectedProgram;
    final String chargeNumber = chargeNumberController.text.trim();
    final String requestor = requestorController.text.trim();
    final String task = taskController.text.trim();
    final DateRange period = invoice.billingPeriod;
    final String travelPurpose = _travelPurposeController.text.trim();
    final String travelDestination = _travelDestinationController.text.trim();
    final String travelParties = _travelPartiesController.text.trim();

    if (selectedProgram == null) {
      isInputValid = false;
      programFlag = flagFromMessage('TODO');
    } else {
      programFlag = null;
    }

    if (isInputValid) {
      final ExpenseReportMetadata metadata = ExpenseReportMetadata(
        program: selectedProgram!,
        chargeNumber: chargeNumber,
        requestor: requestor,
        task: task,
        period: period,
        travelPurpose: travelPurpose,
        travelDestination: travelDestination,
        travelParties: travelParties,
      );

      if (invoice.expenseReports.indexOf(metadata) >= 0) {
        programFlag = flagFromMessage('An expense report already exists for this program');
        isInputValid = false;
      }

      if (metadata.program.requiresChargeNumber && metadata.chargeNumber!.isEmpty) {
        chargeNumberFlag = flagFromMessage('TODO');
        isInputValid = false;
      } else {
        chargeNumberFlag = null;
      }

      if (metadata.program.requiresRequestor && metadata.requestor!.isEmpty) {
        requestorFlag = flagFromMessage('TODO');
        isInputValid = false;
      } else {
        requestorFlag = null;
      }

      if (isInputValid) {
        Navigator.of(context).pop<ExpenseReportMetadata>(metadata);
      }
    }

    if (!isInputValid) {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
