// @dart=2.9

import 'package:flutter/material.dart';

import 'package:payouts/ui/invoice/billable_hours_page.dart';
import 'package:payouts/ui/invoice/billable_hours_page_2.dart';
import 'package:payouts/ui/invoice/expense_reports_page.dart';
import 'package:payouts/ui/invoice/invoice_scaffold.dart';
import 'package:payouts/ui/invoice/review_page.dart';

class InvoiceHome extends StatefulWidget {
  const InvoiceHome({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InvoiceHomeState();
  }
}

class _InvoiceHomeState extends State<InvoiceHome> {
  @override
  Widget build(BuildContext context) {
    return InvoiceScaffold(
      includeDrawer: true,
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1,
        children: <Widget>[
          InvoiceSection(
            title: 'Billable Hours',
            icon: Icons.access_time,
            pageBuilder: (BuildContext context) {
              return BillableHoursPage();
            },
          ),
          InvoiceSection(
            title: 'Billable Hours 2',
            icon: Icons.access_time,
            pageBuilder: (BuildContext context) {
              return BillableHoursPage2();
            },
          ),
          InvoiceSection(
            title: 'Expense Reports',
            icon: Icons.attach_money,
            pageBuilder: (BuildContext context) {
              return ExpenseReportsPage();
            },
          ),
          InvoiceSection(
            title: 'Accomplishments',
            icon: Icons.check_box,
          ),
          InvoiceSection(
            title: 'Review & Submit',
            icon: Icons.cloud_upload,
            pageBuilder: (BuildContext context) {
              return ReviewPage();
            },
          ),
        ],
      ),
    );
  }
}

class InvoiceSection extends StatelessWidget {
  const InvoiceSection({
    Key key,
    @required this.title,
    @required this.icon,
    this.pageBuilder,
  })  : assert(title != null),
        assert(icon != null),
        super(key: key);

  final String title;
  final IconData icon;
  final WidgetBuilder pageBuilder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all()),
      child: InkWell(
        onTap: pageBuilder == null ? null : () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: pageBuilder,
            ),
          );
        },
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon),
              const SizedBox(width: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
