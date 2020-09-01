import 'package:flutter/foundation.dart';

import 'invoice.dart';
import 'track_invoice_opened_mixin.dart';

mixin TrackInvoiceDirtyMixin on TrackInvoiceOpenedMixin {
  InvoiceListener _listener;
  bool _isInvoiceDirty;

  void _updateIsInvoiceDirty() {
    final bool isDirty = InvoiceBinding.instance.invoice?.isDirty ?? false;
    if (isDirty != _isInvoiceDirty) {
      _isInvoiceDirty = isDirty;
      onInvoiceDirtyChanged();
    }
  }

  void _handleInvoiceDirtyChanged() {
    _updateIsInvoiceDirty();
  }

  @override
  @protected
  void initInstance() {
    super.initInstance();
    _listener = InvoiceListener(onInvoiceDirtyChanged: _handleInvoiceDirtyChanged);
    InvoiceBinding.instance.addListener(_listener);
    _updateIsInvoiceDirty();
  }

  @override
  destroy() {
    InvoiceBinding.instance.removeListener(_listener);
    super.destroy();
  }

  @override
  @protected
  void onInvoiceChanged() {
    super.onInvoiceChanged();
    _updateIsInvoiceDirty();
  }

  /// Whether the currently open invoice has unsaved changes.
  ///
  /// If there's no open invoice, then this value will be false.
  @protected
  bool get isInvoiceDirty => _isInvoiceDirty;

  /// Invoked when the value of [isInvoiceDirty] has changed.
  ///
  /// Subclasses may override this method to have a hook into when the value
  /// of the [isInvoiceDirty] property changes.
  @protected
  @mustCallSuper
  void onInvoiceDirtyChanged() {}
}
