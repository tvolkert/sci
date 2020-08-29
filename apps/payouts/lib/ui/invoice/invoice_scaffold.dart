import 'package:flutter/material.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/common/payouts_drawer.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart' as ib;

class InvoiceScaffold extends StatefulWidget {
  InvoiceScaffold({
    Key key,
    @required this.body,
    this.floatingActionButton,
    this.includeDrawer = false,
  })  : assert(body != null),
        assert(includeDrawer != null),
        super(key: key);

  final Widget body;
  final Widget floatingActionButton;
  final bool includeDrawer;

  @override
  State<StatefulWidget> createState() {
    return _InvoiceScaffoldState();
  }
}

class _InvoiceScaffoldState extends State<InvoiceScaffold> {
  @override
  Widget build(BuildContext context) {
    Invoice invoice = ib.InvoiceBinding.of(context).invoice;
    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
      ),
      drawer: widget.includeDrawer ? PayoutsDrawer() : null,
      body: SafeArea(child: widget.body),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
