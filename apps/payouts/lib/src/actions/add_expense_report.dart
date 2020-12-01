import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/src/ui/invoice_entry_editor.dart';

class AddExpenseReportIntent extends Intent {
  const AddExpenseReportIntent({this.context});

  final BuildContext? context;
}

class AddExpenseReportAction extends ContextAction<AddExpenseReportIntent> with TrackInvoiceMixin {
  AddExpenseReportAction._() {
    initInstance();
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
    return isInvoiceOpened && !invoice.isSubmitted;
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
    return pivot.Sheet.open<ExpenseReportMetadata>(
      context: context,
      content: AddExpenseReportSheet(),
      barrierDismissible: true,
    );
  }
}

class AddExpenseReportSheetState extends InvoiceEntryEditorState<AddExpenseReportSheet> {
  pivot.Flag? _travelPurposeFlag;
  pivot.Flag? _travelDestinationFlag;
  pivot.Flag? _travelPartiesFlag;
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
  List<pivot.FormField> buildFormFields() {
    return <pivot.FormField>[
      buildProgramFormField(),
      if (requiresChargeNumber) buildChargeNumberFormField(),
      if (requiresRequestor) buildRequestorFormField(),
      buildTaskFormField(),
      pivot.FormField(
        label: 'Purpose of travel',
        flag: _travelPurposeFlag,
        child: pivot.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelPurposeController,
        ),
      ),
      pivot.FormField(
        label: 'Destination (city)',
        flag: _travelDestinationFlag,
        child: pivot.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelDestinationController,
        ),
      ),
      pivot.FormField(
        label: 'Party or parties visited',
        flag: _travelPartiesFlag,
        child: pivot.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelPartiesController,
        ),
      ),
    ];
  }

  @override
  void handleOk() {
    bool isInputValid = true;

    final Program? selectedProgram = this.selectedProgram;
    final String chargeNumber = chargeNumberController.text.trim();
    final String requestor = requestorController.text.trim();
    final String task = taskController.text.trim();
    final DateRange period = DateRange.fromStartEnd(DateTime(2019), DateTime(2020)); // TODO real dates
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

      if (InvoiceBinding.instance!.invoice!.expenseReports.indexOf(metadata) >= 0) {
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
