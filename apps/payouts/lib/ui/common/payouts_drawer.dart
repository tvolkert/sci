// @dart=2.9

import 'package:flutter/material.dart';

import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/open_invoice.dart';

class PayoutsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: new ListView(
        children: <Widget>[
          // Drawer header.
          new DrawerHeader(
            child: new Center(
              child: new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Column(
                  children: <Widget>[
                    SizedBox(
                      height: 80,
                      child: Image.asset('assets/logo.png'),
                    ),
                    Text(
                      'SCI Payouts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0x2f, 0x4e, 0x6f),
                        letterSpacing: 2.0,
                        fontFamily: 'AF Battersea',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          new ListTile(
            leading: new Icon(Icons.add_circle),
            title: new Text('Create a new invoice'),
            onTap: () {},
          ),
          new ListTile(
            leading: new Icon(Icons.open_in_new),
            title: new Text('Open an existing invoice'),
            onTap: () {
              NavigatorState navigator = Navigator.of(context);
              InvoiceContext invoiceContext = InvoiceBinding.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute<int>(
                  builder: (BuildContext context) {
                    return OpenInvoicePage();
                  },
                ),
              ).then((int invoiceId) {
                if (invoiceId != null) {
                  invoiceContext.invoiceId = invoiceId;
//                  navigator.pushReplacement(MaterialPageRoute(
//                    builder: (BuildContext context) {
//                      return InvoiceHome();
//                    },
//                  ));
                }
              });
            },
          ),
          new ListTile(
            leading: new Icon(Icons.delete),
            title: new Text('Delete this invoice'),
            onTap: () {},
          ),
          new ListTile(
            leading: new Icon(Icons.exit_to_app),
            title: new Text('Sign out'),
            onTap: () {
              PersistentCredentials.clear(context);
              UserBinding.clear(context);
            },
          ),
        ],
      ),
    );
  }
}
