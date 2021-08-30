import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/ui/common/task_monitor.dart';

class SaveInvoiceIntent extends Intent {
  const SaveInvoiceIntent({this.context});

  final BuildContext? context;
}

class SaveInvoiceAction extends ContextAction<SaveInvoiceIntent> with TrackInvoiceMixin {
  SaveInvoiceAction._() {
    startTrackingInvoiceActivity();
  }

  static final SaveInvoiceAction instance = SaveInvoiceAction._();

  @override
  @protected
  void onInvoiceOpenedChanged() {
    super.onInvoiceOpenedChanged();
    notifyActionListeners();
  }

  @override
  @protected
  void onInvoiceDirtyChanged() {
    super.onInvoiceDirtyChanged();
    notifyActionListeners();
  }

  @override
  bool isEnabled(SaveInvoiceIntent intent) {
    return isInvoiceOpened && isInvoiceDirty;
  }

  @override
  Future<void> invoke(SaveInvoiceIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await TaskMonitor.of(context).monitor<void>(
      future: openedInvoice.save(),
      inProgressMessage: 'Saving invoice...',
      completedMessage: 'Invoice saved',
    );
  }
}
