import 'package:flutter/foundation.dart';

import 'invoice.dart';

mixin TrackExpenseReportMixin {
  InvoiceListener? _listener;
  ExpenseReport? _expenseReport;

  bool _isTrackedExpenseReport(int index) {
    assert(isTrackingExpenseReport);
    return _expenseReport!.index == index;
  }

  void _handleExpenseInserted(int index, int expensesIndex) {
    assert(isTrackingExpenseReport);
    if (_isTrackedExpenseReport(index)) {
      onExpensesChanged();
    }
  }

  void _handleExpensesRemoved(int index, int expensesIndex, Iterable<Expense> removed) {
    assert(isTrackingExpenseReport);
    if (_isTrackedExpenseReport(index)) {
      onExpensesChanged();
    }
  }

  void _handleExpenseUpdated(int index, int expensesIndex, String key, dynamic previousValue) {
    assert(isTrackingExpenseReport);
    if (_isTrackedExpenseReport(index)) {
      onExpensesChanged();
    }
  }

  /// True if this object is currently tracking an expense report.
  bool get isTrackingExpenseReport => _expenseReport != null;

  /// The expense report currently being tracked
  ExpenseReport get expenseReport {
    assert(isTrackingExpenseReport);
    return _expenseReport!;
  }

  /// Starts tracking the specified expense report.
  ///
  /// Only one expense report may be tracked at a time.
  @protected
  @mustCallSuper
  void startTrackingExpenseReport(ExpenseReport expenseReport) {
    assert(!isTrackingExpenseReport);
    _expenseReport = expenseReport;
    _listener = InvoiceListener(
      onExpenseInserted: _handleExpenseInserted,
      onExpensesRemoved: _handleExpensesRemoved,
      onExpenseUpdated: _handleExpenseUpdated,
    );
    InvoiceBinding.instance!.addListener(_listener!);
  }

  /// Stops tracking [expenseReport].
  ///
  /// Callers should call this method before they drop their reference to this
  /// object in order to not leak memory.
  @protected
  @mustCallSuper
  void stopTrackingExpenseReport() {
    assert(isTrackingExpenseReport);
    InvoiceBinding.instance!.removeListener(_listener!);
    _listener = null;
    _expenseReport = null;
  }

  /// Invoked when the metadata associated with an expense report changed.
  /// This will not be invoked when expense data changes; for that, see the
  /// [onExpensesChanged] method.
  @protected
  @mustCallSuper
  void onExpenseReportMetadataChanged() {}

  /// Invoked when the expense data associated with an expense report changed.
  /// This could be a new or removed expense, as well as an update of the data
  /// associated with an existing expense.
  @protected
  @mustCallSuper
  void onExpensesChanged() {}
}
