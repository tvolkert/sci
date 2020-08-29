import 'package:flutter/material.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart' as ib;

class StatusPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StatusPageState();
  }
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    Invoice invoice = ib.InvoiceBinding.of(context).invoice;
    return Text('${invoice.accomplishments}');
  }
}
