import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/model/user.dart';

class ExportInvoiceIntent extends Intent {
  const ExportInvoiceIntent({this.context});

  final BuildContext? context;
}

class ExportInvoiceAction extends ContextAction<ExportInvoiceIntent> with TrackInvoiceMixin {
  ExportInvoiceAction._() {
    startTrackingInvoiceActivity();
  }

  static final ExportInvoiceAction instance = ExportInvoiceAction._();

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
  bool isEnabled(ExportInvoiceIntent intent) {
    return isInvoiceOpened && !isInvoiceDirty;
  }

  @override
  Future<void> invoke(ExportInvoiceIntent intent, [BuildContext? context]) async {
    final Uri url = Server.uri(Server.invoicePdfUrl, query: <String, String>{
      QueryParameters.invoiceId: openedInvoice.id.toString(),
    });
    await UserBinding.instance!.user!.launchAuthenticatedUri(url);
  }
}
