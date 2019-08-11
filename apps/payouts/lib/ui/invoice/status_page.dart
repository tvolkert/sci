import 'package:flutter/material.dart';

import 'package:payouts/model/invoice.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';

class StatusPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StatusPageState();
  }
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    Invoice invoice = InvoiceBinding.of(context).invoice;
    return Text('${invoice.data["tasks"]}');
  }
}
