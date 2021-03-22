import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:chicago/chicago.dart' as chicago;
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
  late chicago.CalendarSelectionController _fromDateController;
  late chicago.CalendarSelectionController _toDateController;
  late chicago.CalendarDate _lastAvailableDay;

  void _handleFromDateChanged(chicago.CalendarDate date) {
    if (date > _toDateController.value!) {
      _toDateController.value = date;
    }
  }

  void _handleToDateChanged(chicago.CalendarDate date) {
    if (date < _fromDateController.value!) {
      _fromDateController.value = date;
    }
  }

  bool _isDisabled(chicago.CalendarDate date) => date > _lastAvailableDay;

  @override
  void initState() {
    super.initState();
    final chicago.CalendarDate today = chicago.CalendarDate.fromDateTime(DateTime.now());
    final DateRange billingPeriod = InvoiceBinding.instance!.invoice!.billingPeriod;
    final chicago.CalendarDate billingStart = chicago.CalendarDate.fromDateTime(billingPeriod.start);
    final chicago.CalendarDate billingEnd = chicago.CalendarDate.fromDateTime(billingPeriod.end);
    _lastAvailableDay = billingEnd < today ? today : billingEnd;
    _travelPurposeController = TextEditingController();
    _travelDestinationController = TextEditingController();
    _travelPartiesController = TextEditingController();
    _fromDateController = chicago.CalendarSelectionController(billingStart);
    _toDateController = chicago.CalendarSelectionController(billingEnd);
  }

  @override
  void dispose() {
    _travelPurposeController.dispose();
    _travelDestinationController.dispose();
    _travelPartiesController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  List<chicago.FormField> buildFormFields() {
    return <chicago.FormField>[
      buildProgramFormField(),
      if (requiresChargeNumber) buildChargeNumberFormField(),
      if (requiresRequestor) buildRequestorFormField(),
      buildTaskFormField(),
      chicago.FormField(
        label: 'Dates',
        child: Row(
          children: [
            chicago.CalendarButton(
              disabledDateFilter: _isDisabled,
              selectionController: _fromDateController,
              onDateChanged: _handleFromDateChanged,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to')),
            chicago.CalendarButton(
              disabledDateFilter: _isDisabled,
              selectionController: _toDateController,
              onDateChanged: _handleToDateChanged,
            ),
          ],
        ),
      ),
      chicago.FormField(
        label: 'Purpose of travel',
        flag: _travelPurposeFlag,
        child: chicago.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelPurposeController,
        ),
      ),
      chicago.FormField(
        label: 'Destination (city)',
        flag: _travelDestinationFlag,
        child: chicago.TextInput(
          backgroundColor: const Color(0xfff7f5ee),
          controller: _travelDestinationController,
        ),
      ),
      chicago.FormField(
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

    final Program? selectedProgram = this.selectedProgram;
    final String chargeNumber = chargeNumberController.text.trim();
    final String requestor = requestorController.text.trim();
    final String task = taskController.text.trim();
    final DateRange period = DateRange.fromStartEnd(
      _fromDateController.value!.toDateTime(),
      _toDateController.value!.toDateTime(),
    );
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
