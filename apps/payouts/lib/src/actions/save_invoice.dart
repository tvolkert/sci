import 'package:flutter/material.dart';
import 'package:payouts/src/model/invoice.dart';

import 'package:payouts/ui/common/task_monitor.dart';

import 'track_invoice_dirty_mixin.dart';
import 'track_invoice_opened_mixin.dart';

class SaveInvoiceIntent extends Intent {
  const SaveInvoiceIntent({this.context});

  final BuildContext context;
}

class SaveInvoiceAction extends ContextAction<SaveInvoiceIntent>
    with TrackInvoiceOpenedMixin, TrackInvoiceDirtyMixin {
  SaveInvoiceAction._() {
    _listener = InvoiceListener(
      onInvoiceChanged: handleInvoiceChanged,
      onInvoiceDirtyChanged: handleInvoiceDirtyChanged,
    );
    InvoiceBinding.instance.addListener(_listener);
    initInvoiceOpened();
    initInvoiceDirty();
  }

  static final SaveInvoiceAction instance = SaveInvoiceAction._();

  InvoiceListener _listener;

  @override
  @protected
  void handleInvoiceChanged(Invoice previousInvoice) {
    super.handleInvoiceChanged(previousInvoice);
    initInvoiceDirty();
  }

  @override
  @protected
  void onInvoiceOpenedChanged() {
    super.onInvoiceOpenedChanged();
    notifyActionListeners();
  }

  @override
  void onInvoiceDirtyChanged() {
    super.onInvoiceDirtyChanged();
    notifyActionListeners();
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
