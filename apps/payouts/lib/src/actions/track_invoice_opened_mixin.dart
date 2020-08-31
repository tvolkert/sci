import 'package:flutter/foundation.dart';
import 'package:payouts/src/model/invoice.dart';

mixin TrackInvoiceOpenedMixin {
  bool _isInvoiceOpened;
  bool get isInvoiceOpened => _isInvoiceOpened;
  @protected
  set isInvoiceOpened(bool value) {
    final bool previousValue = _isInvoiceOpened;
    if (value != previousValue) {
      _isInvoiceOpened = value;
      onInvoiceOpenedChanged();
    }
  }

  @protected
  void initInvoiceOpened() {
    isInvoiceOpened = InvoiceBinding.instance.invoice != null;
  }

  @protected
  @mustCallSuper
  void onInvoiceOpenedChanged() {}

  @protected
  @mustCallSuper
  void handleInvoiceChanged(Invoice previousInvoice) {
    initInvoiceOpened();
  }
}
