// @dart=2.9

import 'package:flutter/foundation.dart';

import 'invoice.dart';

mixin TrackInvoiceOpenedMixin {
  InvoiceListener _listener;
  bool _isInvoiceOpened;

  void _updateIsInvoiceOpened() {
    final bool isOpened = InvoiceBinding.instance.invoice != null;
    if (isOpened != _isInvoiceOpened) {
      _isInvoiceOpened = isOpened;
      onInvoiceOpenedChanged();
    }
  }

  void _handleInvoiceChanged(Invoice previousInvoice) {
    _updateIsInvoiceOpened();
    onInvoiceChanged();
  }

  /// Whether the user currently has an invoice open.
  @protected
  bool get isInvoiceOpened => _isInvoiceOpened;

  /// Initializes this instance.
  ///
  /// Concrete implementations should call this method in their constructor
  /// body.
  @protected
  @mustCallSuper
  void initInstance() {
    _listener = InvoiceListener(onInvoiceChanged: _handleInvoiceChanged);
    InvoiceBinding.instance.addListener(_listener);
    _updateIsInvoiceOpened();
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
    InvoiceBinding.instance.removeListener(_listener);
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
}
