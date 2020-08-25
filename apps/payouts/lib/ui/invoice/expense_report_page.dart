import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_scaffold.dart';
import 'package:payouts/ui/invoice/timesheet_page.dart';

class ExpenseReportPage extends StatefulWidget {
  ExpenseReportPage({Key key, this.expenseReport}) : super(key: key);

  final Map<String, dynamic> expenseReport;

  @override
  State<StatefulWidget> createState() {
    return _ExpenseReportPageState();
  }
}

class _ExpenseReportPageState extends State<ExpenseReportPage> {
  Set<int> _selectedOrdinals = Set<int>();

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> expenses = widget.expenseReport['expenses'].cast<Map<String, dynamic>>();
    NumberFormat currencyFormat = NumberFormat.currency(symbol: r'$');

    DataRow toDataRow(Map<String, dynamic> expense) {
      Map<String, dynamic> type = expense['expense_type'].cast<String, dynamic>();
      return DataRow(
        selected: _selectedOrdinals.contains(expense['ordinal']),
        onSelectChanged: (bool selected) {
          setState(() {
            if (selected) {
              _selectedOrdinals.add(expense['ordinal']);
            } else {
              _selectedOrdinals.remove(expense['ordinal']);
            }
          });
        },
        cells: <DataCell>[
          DataCell(Text(expense['date'])),
          DataCell(Text(type['name'])),
          DataCell(Text(currencyFormat.format(expense['amount']))),
          DataCell(Text(expense['description'])),
        ],
      );
    }

    List<DataRow> rows = expenses.map<DataRow>(toDataRow).toList();

    List<Widget> buttons = <Widget>[
      FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add expense',
        onPressed: null,
      ),
    ];

    if (_selectedOrdinals.isNotEmpty) {
      buttons.insertAll(
        0,
        <Widget>[
          FloatingActionButton(
            child: Icon(Icons.delete),
            tooltip: 'Delete selected expense${_selectedOrdinals.length == 1 ? '' : 's'}',
            onPressed: null,
          ),
          SizedBox(width: 10),
        ],
      );
    }

    if (_selectedOrdinals.length == 1) {
      buttons.insertAll(
        0,
        <Widget>[
          FloatingActionButton(
            child: Icon(Icons.edit),
            tooltip: 'Edit selected expense',
            onPressed: null,
          ),
          SizedBox(width: 10),
        ],
      );
    }

    return InvoiceScaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: buttons,
      ),
      body: SizedBox.expand(
        child: DataTable(
          rows: rows,
          columns: <DataColumn>[
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Description')),
          ],
        ),
      ),
    );
  }
}
