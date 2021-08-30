import 'dart:async';

import 'package:chicago/chicago.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/ui/common/task_monitor.dart';

class SubmitInvoiceIntent extends Intent {
  const SubmitInvoiceIntent({this.context});

  final BuildContext? context;
}

class SubmitInvoiceAction extends ContextAction<SubmitInvoiceIntent> with TrackInvoiceMixin {
  SubmitInvoiceAction._() {
    initInstance();
  }

  static final SubmitInvoiceAction instance = SubmitInvoiceAction._();

  bool _certified = false;
  bool get certified => _certified;
  set certified(bool value) {
    if (value != _certified) {
      _certified = value;
      notifyActionListeners();
    }
  }

  @override
  void onInvoiceChanged() {
    super.onInvoiceChanged();
    certified = false;
  }

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
  bool isEnabled(SubmitInvoiceIntent intent) {
    return certified && isInvoiceOpened && !invoice.isSubmitted;
  }

  @override
  Future<void> invoke(SubmitInvoiceIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    int selectedOption = await Prompt.open(
      context: context,
      messageType: MessageType.question,
      message: 'Submit Invoice?',
      body: Text(
        'Are you sure you want to submit this invoice? Once an invoice is submitted, '
        'it cannot be modified.',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(height: 1.25),
      ),
      options: ['Submit', 'Cancel'],
    );

    if (selectedOption == 0) {
      await TaskMonitor.of(context).monitor<void>(
        future: invoice.save(markAsSubmitted: true),
        inProgressMessage: 'Submitting invoice...',
        completedMessage: 'Invoice Submitted',
      );
      if (invoice.expenseReports.isNotEmpty) {
        await Prompt.open(
          context: context,
          messageType: MessageType.info,
          message: 'Submit Receipts',
          body: Text(
            'Since your invoice contains expenses, please remember to submit your '
                'receipts to Satellite Consulting, Inc.',
            style: Theme
                .of(context)
                .textTheme
                .bodyText2!
                .copyWith(height: 1.25),
          ),
          options: ['OK'],
        );
      }
    }
  }
}
