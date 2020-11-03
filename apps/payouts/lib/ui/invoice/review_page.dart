// @dart=2.9

import 'package:flutter/material.dart';

import 'package:payouts/ui/invoice/invoice_scaffold.dart';

class ReviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReviewPageState();
  }
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return InvoiceScaffold(
      body: Table(
        children: <TableRow>[
          TableRow(
            children: <TableCell>[
              TableCell(child: Text('1')),
            ],
          ),
        ],
      ),
    );
  }
}
