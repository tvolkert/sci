import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_opened_mixin.dart';
import 'package:payouts/src/pivot.dart' as pivot;

class DeleteTimesheetIntent extends Intent {
  const DeleteTimesheetIntent(this.timesheet);

  final Timesheet timesheet;
}

class DeleteTimesheetAction extends ContextAction<DeleteTimesheetIntent> with TrackInvoiceOpenedMixin {
  DeleteTimesheetAction._();

  static final DeleteTimesheetAction instance = DeleteTimesheetAction._();

  @override
  @protected
  void onInvoiceChanged() {
    super.onInvoiceChanged();
    notifyActionListeners();
  }

  @override
  bool isEnabled(DeleteTimesheetIntent intent) {
    return isInvoiceOpened && !InvoiceBinding.instance!.invoice!.isSubmitted;
  }

  @override
  Future<void> invoke(DeleteTimesheetIntent intent, [BuildContext? context]) async {
    context ??= primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    int selectedOption = await pivot.Prompt.open(
      context: context,
      messageType: pivot.MessageType.question,
      message: 'Remove Line Item?',
      body: Text(
        'Are you sure you want to remove the specified hours line item?',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(height: 1.25),
      ),
      options: ['OK', 'Cancel'],
    );

    if (selectedOption == 0) {
      InvoiceBinding.instance!.invoice!.timesheets.removeAt(intent.timesheet.index);
    }
  }
}
