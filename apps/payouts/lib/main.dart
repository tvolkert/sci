import 'package:flutter/material.dart';

import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/require_login.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_scaffold.dart';
import 'package:payouts/ui/invoice/load_last_invoice.dart';

void main() => runApp(Payouts());

class Payouts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payouts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserBinding(
        child: PersistentCredentials(
          child: RequireLogin(
            child: InvoiceBinding(
              child: LoadLastInvoice(
                child: new InvoiceScaffold(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
