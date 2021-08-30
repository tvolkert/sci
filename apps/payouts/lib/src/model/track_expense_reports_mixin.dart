import 'package:flutter/foundation.dart';

import 'invoice.dart';

mixin TrackExpenseReportsMixin {
  InvoiceListener? _listener;

  void _handleInvoiceChanged(Invoice? previousInvoice) {
    assert(isTrackingExpenseReports);
    onExpenseReportsChanged();
  }

  void _handleExpenseReportInserted(int expenseReportsIndex) {
    assert(isTrackingExpenseReports);
    onExpenseReportInserted();
  }

  void _handleExpenseReportsRemoved(int expenseReportsIndex, Iterable<ExpenseReport> removed) {
    assert(isTrackingExpenseReports);
    onExpenseReportsRemoved();
  }

  /// The currently opened invoice, or null if there is no open invoice.
  Invoice? get invoice {
    assert(isTrackingExpenseReports);
    return InvoiceBinding.instance!.invoice;
  }

  /// True if this object is currently tracking the list of expense reports.
  ///
  /// See also:
  ///  * [startTrackingExpenseReports]
  ///  * [stopTrackingExpenseReports]
  bool get isTrackingExpenseReports => _listener != null;

  /// Whether there is at least one expense report associated with the current
  /// invoice.
  bool get hasExpenseReports => invoice != null && invoice!.expenseReports.isNotEmpty;

  /// The list of expense reports.
  ///
  /// This will be non-null if and only if [hasExpenseReports] is true.
  ExpenseReports? get expenseReports => hasExpenseReports ? invoice!.expenseReports : null;

  /// Starts tracking the list of expense reports.
  ///
  /// Attempts to call this method more than once (without first calling
  /// [stopTrackingExpenseReports]) will fail.
  @protected
  @mustCallSuper
  void startTrackingExpenseReports() {
    assert(!isTrackingExpenseReports);
    _listener = InvoiceListener(
      onExpenseReportInserted: _handleExpenseReportInserted,
      onExpenseReportsRemoved: _handleExpenseReportsRemoved,
      onInvoiceOpened: _handleInvoiceChanged,
      onInvoiceClosed: _handleInvoiceChanged,
    );
    InvoiceBinding.instance!.addListener(_listener!);
  }

  /// Stops tracking the list of expense reports.
  ///
  /// Callers should call this method before they drop their reference to this
  /// object in order to not leak memory.
  @protected
  @mustCallSuper
  void stopTrackingExpenseReports() {
    assert(isTrackingExpenseReports);
    InvoiceBinding.instance!.removeListener(_listener!);
    _listener = null;
  }

  /// Invoked when an expense report has been added to the list of reports
  /// associated with the currently open invoice.
  @protected
  @mustCallSuper
  void onExpenseReportInserted() {}

  /// Invoked when one or more expense reports has been removed from the list
  /// of reports associated with the currently open invoice.
  @protected
  @mustCallSuper
  void onExpenseReportsRemoved() {}

  /// Invoked when the list of expense reports for the currently open invoice
  /// has been replaced.
  @protected
  @mustCallSuper
  void onExpenseReportsChanged() {}
}
