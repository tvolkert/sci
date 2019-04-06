import 'package:flutter/material.dart';

import 'package:payouts/model/invoice.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';

class InvoiceScaffold extends StatelessWidget {
  const InvoiceScaffold({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Invoice invoice = InvoiceBinding.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${invoice.id}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {},
          ),
        ],
      ),
      drawer: PayoutsDrawer(),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}

class PayoutsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: new ListView(children: <Widget>[
        // Drawer header.
        new DrawerHeader(
          child: new Center(
            child: new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  new Text('Payouts'),
                  new Text(" "),
                  new Text('link'),
                ],
              ),
            ),
          ),
        ),

        // Performance overlay toggle.
        new ListTile(
          leading: new Icon(Icons.assessment),
          title: new Text('Performance Overlay'),
          onTap: () {},
          selected: false,
          trailing: new Checkbox(
            value: false,
            onChanged: (bool value) {},
          ),
        ),
      ]),
    );
  }
}
