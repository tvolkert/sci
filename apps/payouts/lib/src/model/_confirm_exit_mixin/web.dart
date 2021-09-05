import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart' hide binarySearch;

import '../invoice.dart';

const String _beforeUnload = 'beforeunload';

mixin ConfirmExitMixin on InvoiceBinding {
  @override
  @protected
  @mustCallSuper
  void initInstances() {
    super.initInstances();
    _onBeforeUnload = _handleBeforeUnload;
  }

  // This ensures that when we refer to the tearoff in JavaScript, it refers to
  // the exact same function. Referring to `_handleBeforeUnload` directly
  // causes the JavaScript code to refer to a new function reference every
  // time, thus causing the `removeEventListener()` to not remove the listener.
  late html.EventListener _onBeforeUnload;
  bool _isRegistered = false;

  bool get _requiresRegistration => invoice != null && invoice!.isDirty;

  void _handleBeforeUnload(html.Event rawEvent) {
    assert(rawEvent is html.BeforeUnloadEvent);
    assert(_isRegistered);
    html.BeforeUnloadEvent event = rawEvent as html.BeforeUnloadEvent;
    event.preventDefault();
    event.returnValue = '';
  }

  void _updateRegistration() {
    if (_requiresRegistration) {
      if (!_isRegistered) {
        _isRegistered = true;
        html.window.addEventListener(_beforeUnload, _onBeforeUnload, true);
      }
    } else if (_isRegistered) {
      _isRegistered = false;
      html.window.removeEventListener(_beforeUnload, _onBeforeUnload, true);
    }
  }

  @override
  void onInvoiceDirtyChanged() {
    super.onInvoiceDirtyChanged();
    _updateRegistration();
  }

  @override
  void onInvoiceOpened(Invoice? oldInvoice) {
    super.onInvoiceOpened(oldInvoice);
    _updateRegistration();
  }

  @override
  void onInvoiceClosed(Invoice? oldInvoice) {
    super.onInvoiceClosed(oldInvoice);
    _updateRegistration();
  }

  @override
  void onSubmitted() {
    super.onSubmitted();
    _updateRegistration();
  }
}
