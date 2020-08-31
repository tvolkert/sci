import 'package:flutter/material.dart';
import 'package:payouts/src/model/invoice.dart';

import 'package:payouts/ui/common/task_monitor.dart';

class SaveInvoiceIntent extends Intent {
  const SaveInvoiceIntent({this.context});

  final BuildContext context;
}

class SaveInvoiceAction extends ContextAction<SaveInvoiceIntent> {
  SaveInvoiceAction._() {
    _listener = InvoiceListener(
      onInvoiceChanged: _handleInvoiceChanged,
      onInvoiceDirtyChanged: _handleInvoiceDirtyChanged,
    );
    InvoiceBinding.instance.addListener(_listener);
    final Invoice invoice = InvoiceBinding.instance.invoice;
    _isInvoiceOpened = invoice != null;
    _isInvoiceDirty = invoice?.isDirty ?? false;
  }

  static final SaveInvoiceAction instance = SaveInvoiceAction._();

  InvoiceListener _listener;

  bool _isInvoiceOpened;
  bool get isInvoiceOpened => _isInvoiceOpened;
  set isInvoiceOpened(bool value) {
    final bool previousValue = _isInvoiceOpened;
    if (value != previousValue) {
      _isInvoiceOpened = value;
      notifyActionListeners();
    }
  }

  bool _isInvoiceDirty;
  bool get isInvoiceDirty => _isInvoiceDirty;
  set isInvoiceDirty(bool value) {
    if (value != _isInvoiceDirty) {
      _isInvoiceDirty = value;
      notifyActionListeners();
    }
  }

  void _handleInvoiceChanged(Invoice previousInvoice) {
    isInvoiceOpened = InvoiceBinding.instance.invoice != null;
    isInvoiceDirty = InvoiceBinding.instance.invoice?.isDirty ?? false;
  }

  void _handleInvoiceDirtyChanged() {
    isInvoiceDirty = InvoiceBinding.instance.invoice.isDirty;
  }

  @override
  bool isEnabled(SaveInvoiceIntent intent) {
    return isInvoiceOpened && isInvoiceDirty;
  }

  @override
  Future<void> invoke(SaveInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await TaskMonitor.of(context).monitor<void>(
      future: InvoiceBinding.instance.save(),
      inProgressMessage: 'Saving invoice...',
      completedMessage: 'Invoice saved',
    );
  }
}
