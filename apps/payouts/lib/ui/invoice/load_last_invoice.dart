import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:sci/model/user.dart';
import 'package:sci/ui/loading.dart';
import 'package:sci/ui/auth/user_binding.dart';
import 'package:sci/ui/invoice/invoice_binding.dart';

class LoadLastInvoice extends StatefulWidget {
  LoadLastInvoice({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _LoadLastInvoiceState();
  }
}

class _LoadLastInvoiceState extends State<LoadLastInvoice> {
  bool loaded = false;
  Future<http.Response> pendingInvoice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded || pendingInvoice != null) {
      return;
    }

    User user = UserBinding.of(context);

    if (user.lastInvoiceId != null) {
      Uri uri = Uri(
        scheme: 'https',
        host: 'www.satelliteconsulting.com',
        path: 'invoice',
        queryParameters: <String, String>{
          'invoiceId': '${user.lastInvoiceId}',
        },
      );
      pendingInvoice = http.get(
        uri,
        headers: user.authHeaders,
      ).then<http.Response>((http.Response response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> invoice = json.decode(response.body).cast<String, dynamic>();
          InvoiceBinding.update(context, user.lastInvoiceId, invoice);
        }

        // TODO: ask if this `mounted` check is a smell.
        if (mounted) {
          setState(() {
            loaded = true;
            pendingInvoice = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loaded ? widget.child : Loading('Initializing');
  }
}
