import 'package:flutter/material.dart';

import 'package:sci/ui/auth/persistent_credentials.dart';
import 'package:sci/ui/auth/require_login.dart';
import 'package:sci/ui/auth/user_binding.dart';
import 'package:sci/ui/invoice/invoice_binding.dart';
import 'package:sci/ui/invoice/invoice_scaffold.dart';
import 'package:sci/ui/invoice/load_last_invoice.dart';

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
