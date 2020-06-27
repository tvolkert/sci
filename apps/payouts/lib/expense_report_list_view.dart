import 'package:flutter/material.dart';

import 'expense_report_list_tile.dart';

class ExpenseReportData {
  const ExpenseReportData({
    this.title,
    this.amount,
});
  final String title;
  final double amount;
}

class ExpenseReportListView extends StatefulWidget {
  @override
  _ExpenseReportListViewState createState() => _ExpenseReportListViewState();
}

class _ExpenseReportListViewState extends State<ExpenseReportListView> {
  int selectedIndex = 1;

  static const List<ExpenseReportData> expenseReports = <ExpenseReportData>[
    ExpenseReportData(title: 'SCI - Overhead', amount: 0),
    ExpenseReportData(title: 'Orbital Sciences (123)', amount: 3136.63),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: use ink?
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF999999)),
      ),
      child: ListView.builder(
        itemExtent: 18,
        shrinkWrap: true,
        itemCount: expenseReports.length,
        itemBuilder: (BuildContext context, int index) {
          final ExpenseReportData data = expenseReports[index];
          return ExpenseReportListTile(
            title: data.title,
            amount: data.amount,
            hoverColor: Color(0xffdddcd5),
            selected: index == selectedIndex,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}
