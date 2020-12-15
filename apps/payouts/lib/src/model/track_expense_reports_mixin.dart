import 'package:flutter/foundation.dart';

import 'invoice.dart';

mixin TrackExpenseReportsMixin {
  late InvoiceListener _listener;
  Invoice? _invoice;

  void _handleInvoiceChanged(Invoice? previousInvoice) {
    _invoice = InvoiceBinding.instance!.invoice;
    onExpenseReportsChanged();
  }

  void _handleExpenseReportInserted(int expenseReportsIndex) {
    onExpenseReportInserted();
  }

  void _handleExpenseReportsRemoved(int expenseReportsIndex, Iterable<ExpenseReport> removed) {
    onExpenseReportsRemoved();
  }

  /// Whether there is at least one expense report associated with the current
  /// invoice.
  @protected
  bool get hasExpenseReports => _invoice != null && _invoice!.expenseReports.isNotEmpty;

  /// The list of expense reports.
  ///
  /// This will be non-null if and only if [hasExpenseReports] is true.
  @protected
  ExpenseReports? get expenseReports => hasExpenseReports ? _invoice!.expenseReports : null;

  /// Initializes this instance.
  ///
  /// Concrete implementations should call this method in their constructor
  /// body.
  @protected
  @mustCallSuper
  void initInstance() {
    _listener = InvoiceListener(
      onExpenseReportInserted: _handleExpenseReportInserted,
      onExpenseReportsRemoved: _handleExpenseReportsRemoved,
      onInvoiceOpened: _handleInvoiceChanged,
      onInvoiceClosed: _handleInvoiceChanged,
    );
    InvoiceBinding.instance!.addListener(_listener);
    _invoice = InvoiceBinding.instance!.invoice;
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
