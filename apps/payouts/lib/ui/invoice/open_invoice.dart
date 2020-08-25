import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/user.dart';
import 'package:payouts/ui/loading.dart';
import 'package:payouts/ui/auth/user_binding.dart' as ub;

class OpenInvoicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OpenInvoicePageState();
  }
}

class _OpenInvoicePageState extends State<OpenInvoicePage> {
  bool initialized = false;
  List<_BasicInvoice> invoices;
  int selectedIndex;

  _BasicInvoice get invoice => selectedIndex == null ? null : invoices[selectedIndex];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) {
      // We only load the invoice list once.
      return;
    }
    initialized = true;

    User user = ub.UserBinding.of(context);
    assert(user != null, 'User not logged in');

    Uri uri = Uri(
      scheme: 'https',
      host: 'www.satelliteconsulting.com',
      path: 'invoices',
    );
    Future<http.Response> response = user.authenticate().get(uri);
    response.then<http.Response>((http.Response response) {
      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> rawInvoices = json.decode(response.body);
          invoices = rawInvoices
              .cast<Map<String, dynamic>>()
              .map<_BasicInvoice>(_BasicInvoice.fromRaw)
              .toList();
          invoices.sort();
        });
      }
    }).catchError((dynamic error, StackTrace stackTrace) {
      // TODO: notify the user?
      debugPrint('$error\n$stackTrace');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open existing invoice'),
      ),
      body: invoices == null
          ? Loading('Loading')
          : SafeArea(
              child: ListView.builder(
                itemCount: invoices.length,
                itemExtent: 30,
                itemBuilder: (BuildContext context, int index) {
                  _BasicInvoice invoice = invoices[index];
                  return ListTile(
                    title: Text(invoice.invoiceNumber),
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    selected: index == selectedIndex,
                  );
                },
              ),
            ),
      persistentFooterButtons: <Widget>[
        RaisedButton(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 80,
            ),
            child: Text('OK'),
          ),
          textColor: Colors.white,
          onPressed: selectedIndex == null ? null : () => Navigator.pop(context, invoice.invoiceId),
        ),
        RaisedButton(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 80,
            ),
            child: Text('Cancel'),
          ),
          textColor: Colors.white,
          onPressed: !Navigator.canPop(context) ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _BasicInvoice implements Comparable<_BasicInvoice> {
  const _BasicInvoice(
    this.invoiceId,
    this.invoiceNumber,
    this.billingStart,
  );

  final int invoiceId;
  final String invoiceNumber;
  final DateTime billingStart;

  static _BasicInvoice fromRaw(Map<String, dynamic> raw) {
    return _BasicInvoice(
      raw['invoice_id'],
      raw['invoice_number'],
      DateTime.parse(raw['billing_start']),
    );
  }

  @override
  int compareTo(_BasicInvoice other) {
    return other.billingStart.compareTo(billingStart);
  }
}
