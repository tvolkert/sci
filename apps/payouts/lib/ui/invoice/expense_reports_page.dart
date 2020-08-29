import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/invoice/expense_report_page.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart' as ib;
import 'package:payouts/ui/invoice/invoice_scaffold.dart';

class ExpenseReportsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpenseReportsPageState();
  }
}

class _ExpenseReportsPageState extends State<ExpenseReportsPage> {
  @override
  Widget build(BuildContext context) {
    Invoice invoice = ib.InvoiceBinding.of(context).invoice;
    ExpenseReports expenseReports = invoice.expenseReports;

    return InvoiceScaffold(
      body: ListView.builder(
        itemCount: expenseReports.length,
        itemBuilder: (BuildContext context, int index) {
          ExpenseReport expenseReport = expenseReports[index];
          Program program = expenseReport.program;
          bool requiresChargeNumber = program.requiresChargeNumber;
          String chargeNumber = expenseReport.chargeNumber;
          String taskDescription = expenseReport.task;
          Expenses expenses = expenseReport.expenses;
          double totalExpenses = expenses
              .map<double>((Expense expense) => expense.amount)
              .fold<double>(0.0, (double previousValue, double element) => previousValue + element);
          NumberFormat currencyFormat = NumberFormat.currency(symbol: r'$');
          return ListTile(
            title: Row(
              children: <Widget>[
                Text(program.name),
                Expanded(child: Container()),
                DefaultTextStyle(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 14,
                        //color: Color.fromARGB(0x8a, 0, 0, 0),
                      ),
                  child: Row(
                    children: <Widget>[
                      requiresChargeNumber ? Text('($chargeNumber)') : Text(''),
                      taskDescription.isNotEmpty ? Text(' ($taskDescription)') : Text(''),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Text('${currencyFormat.format(totalExpenses)}'),
            trailing: IconButton(icon: Icon(Icons.chevron_right), onPressed: null),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return ExpenseReportPage(expenseReport: expenseReport);
                },
              ));
            },
          );
        },
      ),
    );
  }
}
