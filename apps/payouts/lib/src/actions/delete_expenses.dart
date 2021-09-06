import 'package:chicago/chicago.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';

typedef RangeProvider = Iterable<Span> Function();

class DeleteExpensesIntent extends Intent {
  const DeleteExpensesIntent({
    this.context,
    required this.expenseReport,
    required this.deleteRangeProvider,
  });

  final BuildContext? context;
  final ExpenseReport expenseReport;
  final RangeProvider deleteRangeProvider;
}

class DeleteExpensesAction extends ContextAction<DeleteExpensesIntent> with TrackInvoiceMixin {
  DeleteExpensesAction._() {
    startTrackingInvoiceActivity();
  }

  static final DeleteExpensesAction instance = DeleteExpensesAction._();

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
  bool isEnabled(DeleteExpensesIntent intent) {
    assert(intent.expenseReport.invoice == invoice);
    return isInvoiceOpened && !isInvoiceSubmitted && intent.deleteRangeProvider().isNotEmpty;
  }

  @override
  Future<void> invoke(DeleteExpensesIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    Iterable<Span> deleteRanges = intent.deleteRangeProvider();
    assert(deleteRanges.isNotEmpty);
    final int length = deleteRanges
        .map<int>((Span span) => span.length)
        .reduce((int total, int value) => total + value);
    final String expenseStrCap = length == 1 ? 'Expense' : 'Expenses';
    final String expenseStrLower = length == 1 ? 'expense' : 'expenses';

    int selectedOption = await Prompt.open(
      context: context,
      messageType: MessageType.question,
      message: 'Delete $expenseStrCap?',
      body: Text(
        'Are you sure you want to delete the selected $expenseStrLower?',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(height: 1.25),
      ),
      options: ['OK', 'Cancel'],
    );

    if (selectedOption == 0) {
      intent.expenseReport.expenses.remove(deleteRanges);
    }
  }
}
