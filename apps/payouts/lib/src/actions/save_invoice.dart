import 'package:flutter/material.dart';

import 'package:payouts/ui/common/task_monitor.dart';

class SaveInvoiceIntent extends Intent {
  const SaveInvoiceIntent({this.context});

  final BuildContext context;
}

class SaveInvoiceAction extends ContextAction<SaveInvoiceIntent> {
  @override
  bool isEnabled(SaveInvoiceIntent intent) {
    // TODO: switch enabled based on whether invoice needs saving.
    return super.isEnabled(intent);
  }

  @override
  Future<void> invoke(SaveInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await TaskMonitor.of(context).monitor<void>(
      future: saveInvoice(),
      inProgressMessage: 'Saving invoice...',
      completedMessage: 'Invoice saved',
    );
  }

  Future<void> saveInvoice() async {
    // TODO: save invoice
    return Future<void>.delayed(const Duration(seconds: 2));
  }
}
