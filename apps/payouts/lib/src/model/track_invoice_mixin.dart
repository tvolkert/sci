import 'package:flutter/foundation.dart';

import 'invoice.dart';

mixin TrackInvoiceMixin {
  late InvoiceListener _listener;
  Invoice? _invoice;

  void _handleInvoiceChanged(Invoice? previousInvoice) {
    _invoice = InvoiceBinding.instance!.invoice;
    onInvoiceChanged();
    if (_invoice == null || previousInvoice == null) {
      onInvoiceOpenedChanged();
    }
    if (isInvoiceDirty && (previousInvoice == null || !previousInvoice.isDirty)) {
      onInvoiceDirtyChanged();
    } else if (!isInvoiceDirty && (previousInvoice != null && previousInvoice.isDirty)) {
      onInvoiceDirtyChanged();
    }
    if (isInvoiceSubmitted && (previousInvoice == null || !previousInvoice.isSubmitted)) {
      onInvoiceSubmittedChanged();
    } else if (!isInvoiceSubmitted && (previousInvoice != null && previousInvoice.isSubmitted)) {
      onInvoiceSubmittedChanged();
    }
  }

  /// Whether the user currently has an invoice open.
  @protected
  bool get isInvoiceOpened => _invoice != null;

  /// The currently opened invoice. Only valid if [isInvoiceOpened] is true.
  @protected
  Invoice get invoice => _invoice!;

  @protected
  bool get isInvoiceDirty => isInvoiceOpened && invoice.isDirty;

  @protected
  bool get isInvoiceSubmitted => isInvoiceOpened && invoice.isSubmitted;

  /// Initializes this instance.
  ///
  /// Concrete implementations should call this method in their constructor
  /// body.
  @protected
  @mustCallSuper
  void initInstance() {
    _listener = InvoiceListener(
      onInvoiceOpened: _handleInvoiceChanged,
      onInvoiceClosed: _handleInvoiceChanged,
      onInvoiceDirtyChanged: onInvoiceDirtyChanged,
      onSubmitted: onInvoiceSubmittedChanged,
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

  /// Invoked when the currently open invoice (if any) changed.
  ///
  /// Subclasses may override this method to have a hook into when the value
  /// of [InvoiceBinding.invoice] changes.
  @protected
  @mustCallSuper
  void onInvoiceChanged() {}

  /// Invoked when the value of [isInvoiceOpened] has changed.
  ///
  /// Subclasses may override this method to have a hook into when the value
  /// of the [isInvoiceOpened] property changes.
  @protected
  @mustCallSuper
  void onInvoiceOpenedChanged() {}

  /// Invoked when the value of [isInvoiceDirty] has changed.
  ///
  /// Subclasses may override this method to have a hook into when the value
  /// of the [isInvoiceDirty] property changes.
  @protected
  @mustCallSuper
  void onInvoiceDirtyChanged() {}

  /// Invoked when the value of [isInvoiceSubmitted] has changed.
  ///
  /// Subclasses may override this method to have a hook into when the value
  /// of the [isInvoiceSubmitted] property changes.
  @protected
  @mustCallSuper
  void onInvoiceSubmittedChanged() {}
}
