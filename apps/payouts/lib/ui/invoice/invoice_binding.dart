import 'package:flutter/widgets.dart';

import 'package:payouts/model/invoice.dart';

class InvoiceBinding extends StatefulWidget {
  const InvoiceBinding({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _InvoiceBindingState();
  }

  static Invoice of(BuildContext context) {
    _InvoiceBindingScope scope = context.inheritFromWidgetOfExactType(_InvoiceBindingScope);
    return scope.invoiceBindingState.invoice;
  }

  static void update(
    BuildContext context,
    int id,
    Map<String, dynamic> invoice) {
    _InvoiceBindingScope scope = context.inheritFromWidgetOfExactType(_InvoiceBindingScope);
    scope.invoiceBindingState._updateInvoice(Invoice(id, invoice));
  }
}

class _InvoiceBindingState extends State<InvoiceBinding> {
  Invoice invoice;

  void _updateInvoice(Invoice newInvoice) {
    if (invoice != newInvoice) {
      setState(() {
        invoice = newInvoice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InvoiceBindingScope(invoiceBindingState: this, child: widget.child);
  }
}

class _InvoiceBindingScope extends InheritedWidget {
  const _InvoiceBindingScope({
    Key key,
    this.invoiceBindingState,
    Widget child,
  }) : super(key: key, child: child);

  final _InvoiceBindingState invoiceBindingState;

  @override
  bool updateShouldNotify(_InvoiceBindingScope old) {
    // TODO figure out why the old scope getting passed here has the new credentials
    //return userBindingState.user != old.userBindingState.user;
    return true;
  }
}
