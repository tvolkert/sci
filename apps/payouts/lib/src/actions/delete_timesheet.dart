import 'package:chicago/chicago.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';

class DeleteTimesheetIntent extends Intent {
  const DeleteTimesheetIntent(this.timesheet);

  final Timesheet timesheet;
}

class DeleteTimesheetAction extends ContextAction<DeleteTimesheetIntent> with TrackInvoiceMixin {
  DeleteTimesheetAction._() {
    startTrackingInvoiceActivity();
  }

  static final DeleteTimesheetAction instance = DeleteTimesheetAction._();

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
  bool isEnabled(DeleteTimesheetIntent intent) {
    return isInvoiceOpened && !openedInvoice.isSubmitted;
  }

  @override
  Future<void> invoke(DeleteTimesheetIntent intent, [BuildContext? context]) async {
    context ??= primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    int selectedOption = await Prompt.open(
      context: context,
      messageType: MessageType.question,
      message: 'Remove Line Item?',
      body: Text(
        'Are you sure you want to remove the specified hours line item?',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(height: 1.25),
      ),
      options: ['OK', 'Cancel'],
    );

    if (selectedOption == 0) {
      openedInvoice.timesheets.removeAt(intent.timesheet.index);
    }
  }
}
