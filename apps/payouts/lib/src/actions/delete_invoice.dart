import 'dart:async';

import 'package:flutter/material.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class DeleteInvoiceIntent extends Intent {
  const DeleteInvoiceIntent({this.context});

  final BuildContext context;
}

class DeleteInvoiceAction extends Action<DeleteInvoiceIntent> {
  @override
  Future<void> invoke(DeleteInvoiceIntent intent) async {
    BuildContext context = intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    int selectedOption = await pivot.Prompt.open(
      context: context,
      messageType: pivot.MessageType.warning,
      message: 'Permanently Delete Invoice?',
      body: Text(
        'Are you sure you want to delete this invoice? Invoices cannot be recovered after they are deleted.',
        style: Theme.of(context).textTheme.bodyText2.copyWith(height: 1.25),
      ),
      options: ['OK', 'Cancel'],
    );

    if (selectedOption == 0) {
      print('TODO: delete invoice');
    }
  }
}
