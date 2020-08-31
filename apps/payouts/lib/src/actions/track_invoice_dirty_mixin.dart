import 'package:flutter/foundation.dart';
import 'package:payouts/src/model/invoice.dart';

import 'track_invoice_opened_mixin.dart';

mixin TrackInvoiceDirtyMixin on TrackInvoiceOpenedMixin {
  bool _isInvoiceDirty;
  bool get isInvoiceDirty => _isInvoiceDirty;
  @protected
  set isInvoiceDirty(bool value) {
    final bool previousValue = _isInvoiceDirty;
    if (value != previousValue) {
      _isInvoiceDirty = value;
      onInvoiceDirtyChanged();
    }
  }

  @protected
  void initInvoiceDirty() {
    isInvoiceDirty = InvoiceBinding.instance.invoice?.isDirty ?? false;
  }

  @protected
  @mustCallSuper
  void onInvoiceDirtyChanged() {}

  @protected
  @mustCallSuper
  void handleInvoiceDirtyChanged() {
    initInvoiceDirty();
  }
}
