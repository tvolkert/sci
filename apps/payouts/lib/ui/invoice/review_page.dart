import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/invoice/expense_report_page.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_scaffold.dart';
import 'package:payouts/ui/invoice/timesheet_page.dart';

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
