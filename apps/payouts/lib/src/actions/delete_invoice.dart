import 'package:chicago/chicago.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/model/track_user_auth_mixin.dart';
import 'package:payouts/ui/common/task_monitor.dart';

class DeleteInvoiceIntent extends Intent {
  const DeleteInvoiceIntent({this.context});

  final BuildContext? context;
}

class DeleteInvoiceAction extends ContextAction<DeleteInvoiceIntent>
    with TrackInvoiceMixin, TrackUserAuthMixin {
  DeleteInvoiceAction._() {
    startTrackingInvoiceActivity();
    startTrackingAuth();
  }

  static final DeleteInvoiceAction instance = DeleteInvoiceAction._();

  @override
  void onUserAuthenticated() {
    super.onUserAuthenticated();
    notifyActionListeners();
  }

  @override
  void onInvoiceOpenedChanged() {
    super.onInvoiceOpenedChanged();
    notifyActionListeners();
  }

  @override
  void onInvoiceSubmittedChanged() {
    super.onInvoiceSubmittedChanged();
    notifyActionListeners();
  }

  @override
  bool isEnabled(DeleteInvoiceIntent intent) {
    return isUserAuthenticated && isInvoiceOpened && !openedInvoice.isSubmitted;
  }

  @override
  Future<void> invoke(DeleteInvoiceIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    int selectedOption = await Prompt.open(
      context: context,
      messageType: MessageType.warning,
      message: 'Permanently Delete Invoice?',
      body: Text(
        'Are you sure you want to delete this invoice? Invoices cannot be recovered after they are deleted.',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(height: 1.25),
      ),
      options: ['OK', 'Cancel'],
    );

    if (selectedOption == 0) {
      await TaskMonitor.of(context).monitor<void>(
        future: openedInvoice.delete(),
        inProgressMessage: 'Deleting invoice...',
        completedMessage: 'Invoice deleted',
      );
    }
  }
}
