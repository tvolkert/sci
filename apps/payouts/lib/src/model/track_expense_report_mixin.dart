import 'package:flutter/foundation.dart';

import 'invoice.dart';

mixin TrackExpenseReportMixin {
  late InvoiceListener _listener;
  late ExpenseReport _expenseReport;

  bool _isTrackedExpenseReport(int index) {
    return _expenseReport.invoice.expenseReports.indexOf(_expenseReport) == index;
  }

  void _handleExpenseInserted(int index, int expensesIndex) {
    if (_isTrackedExpenseReport(index)) {
      onExpensesChanged();
    }
  }

  void _handleExpensesRemoved(int index, int expensesIndex, Iterable<Expense> removed) {
    if (_isTrackedExpenseReport(index)) {
      onExpensesChanged();
    }
  }

  void _handleExpenseUpdated(int index, int expensesIndex, String key, dynamic previousValue) {
    if (_isTrackedExpenseReport(index)) {
      onExpensesChanged();
    }
  }

  /// Initializes this instance.
  ///
  /// Concrete implementations should call this method in their constructor
  /// body.
  @protected
  @mustCallSuper
  void initInstance(ExpenseReport expenseReport) {
    _expenseReport = expenseReport;
    _listener = InvoiceListener(
      onExpenseInserted: _handleExpenseInserted,
      onExpensesRemoved: _handleExpensesRemoved,
      onExpenseUpdated: _handleExpenseUpdated,
    );
    InvoiceBinding.instance!.addListener(_listener);
  }

  /// Releases any resources retained by this object.
  ///
  /// Subclasses should override this method to release any resources retained
  /// by this object before calling `super.dispose()`.
  ///
  /// Callers should call this method before they drop their reference to this
  /// object.
  @mustCallSuper
  destroy() {
    InvoiceBinding.instance!.removeListener(_listener);
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
