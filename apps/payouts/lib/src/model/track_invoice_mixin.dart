import 'package:flutter/foundation.dart';

import 'invoice.dart';

mixin TrackInvoiceMixin {
  InvoiceListener? _listener;

  void _handleInvoiceChanged(Invoice? previousInvoice) {
    assert(isTrackingInvoiceActivity);
    onInvoiceChanged();
    if (invoice == null || previousInvoice == null) {
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

  /// True if this object is currently tracking invoice activity.
  ///
  /// See also:
  ///  * [startTrackingInvoiceActivity]
  ///  * [stopTrackingInvoiceActivity]
  bool get isTrackingInvoiceActivity => _listener != null;

  /// The currently opened invoice, or null if there is no open invoice.
  Invoice? get invoice {
    assert(isTrackingInvoiceActivity);
    return InvoiceBinding.instance!.invoice;
  }

  /// Whether the user currently has an invoice open.
  bool get isInvoiceOpened {
    assert(isTrackingInvoiceActivity);
    return invoice != null;
  }

  /// The currently opened invoice. Only valid if [isInvoiceOpened] is true.
  Invoice get openedInvoice => invoice!;

  /// True if an invoice is open and has unsaved changes.
  bool get isInvoiceDirty => isInvoiceOpened && openedInvoice.isDirty;

  /// True if an invoice is open and submitted.
  bool get isInvoiceSubmitted => isInvoiceOpened && openedInvoice.isSubmitted;

  /// Starts tracking invoice activity.
  ///
  /// Attempts to call this method more than once (without first calling
  /// [stopTrackingInvoiceActivity]) will fail.
  @protected
  @mustCallSuper
  void startTrackingInvoiceActivity() {
    assert(!isTrackingInvoiceActivity);
    _listener = InvoiceListener(
      onInvoiceOpened: _handleInvoiceChanged,
      onInvoiceClosed: _handleInvoiceChanged,
      onInvoiceDirtyChanged: onInvoiceDirtyChanged,
      onSubmitted: onInvoiceSubmittedChanged,
    );
    InvoiceBinding.instance!.addListener(_listener!);
  }

  /// Stops tracking invoice activity.
  ///
  /// Callers should call this method before they drop their reference to this
  /// object in order to not leak memory.
  @protected
  @mustCallSuper
  stopTrackingInvoiceActivity() {
    assert(isTrackingInvoiceActivity);
    InvoiceBinding.instance!.removeListener(_listener!);
    _listener = null;
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
