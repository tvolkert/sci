import 'package:flutter/foundation.dart';

import 'constants.dart';
import 'invoice.dart';

@immutable
class ExpenseReportsSummaryData {
  ExpenseReportsSummaryData._(this.invoice, this.dates, this.reports) {
    for (ExpenseReportSummaryData report in reports) {
      report._owner = this;
    }
  }

  final Invoice invoice;
  final List<DateTime?> dates;
  final List<ExpenseReportSummaryData> reports;

  static ExpenseReportsSummaryData build(ExpenseReports expenseReports) {
    final Set<DateTime?> uniqueDates = Set<DateTime?>.of(expenseReports.invoice.billingPeriod);
    expenseReports
        .expand<Expense>((ExpenseReport expenseReport) => expenseReport.expenses)
        .map<DateTime>((Expense expense) => expense.date)
        .forEach(uniqueDates.add);
    final List<DateTime?> orderedDates = uniqueDates.toList()..sort();
    final Map<DateTime, int> dateIndexes = <DateTime, int>{};
    for (int i = 0; i < orderedDates.length; i++) {
      assert(orderedDates[i] != null);
      dateIndexes[orderedDates[i]!] = i;
      if (i < orderedDates.length - 1) {
        assert(orderedDates[i + 1] != null);
        final Duration difference = orderedDates[i + 1]!.difference(orderedDates[i]!);
        if (difference > Dates.approximatelyOneDay) {
          orderedDates.insert(i + 1, null);
          i++;
        }
      }
    }
    final List<ExpenseReportSummaryData> reports =
        expenseReports.map<ExpenseReportSummaryData>((ExpenseReport expenseReport) {
      return ExpenseReportSummaryData._build(expenseReport, orderedDates, dateIndexes);
    }).toList();
    return ExpenseReportsSummaryData._(expenseReports.invoice, orderedDates, reports..sort());
  }
}

@immutable
class ExpenseReportSummaryData implements Comparable<ExpenseReportSummaryData> {
  ExpenseReportSummaryData._(this.name, this.isFlagged, this.rows) {
    for (ExpenseTypeSummaryData row in rows) {
      row._owner = this;
    }
  }

  final String name;
  final bool isFlagged;
  final List<ExpenseTypeSummaryData> rows;

  late final ExpenseReportsSummaryData _owner;
  ExpenseReportsSummaryData get owner => _owner;

  static ExpenseReportSummaryData _build(
    ExpenseReport expenseReport,
    List<DateTime?> orderedDates,
    Map<DateTime, int> dateIndexes,
  ) {
    bool isFlagged = false;
    final int span = orderedDates.length;
    final Map<int, ExpenseTypeSummaryData> lookup = <int, ExpenseTypeSummaryData>{};
    for (Expense expense in expenseReport.expenses) {
      final int id = expense.type.expenseTypeId;
      final ExpenseTypeSummaryData row = lookup.putIfAbsent(id, () {
        return ExpenseTypeSummaryData._(expense.type.name, List<double>.filled(span, 0));
      });
      final DateRange billingPeriod = expenseReport.invoice.billingPeriod;
      if (billingPeriod.start.difference(expense.date) > Dates.approximatelyOneDay ||
          expense.date.difference(billingPeriod.end) > Dates.approximatelyOneDay) {
        isFlagged = true;
      }
      final int index = dateIndexes[expense.date]!;
      row.expenses[index] += expense.amount;
    }
    final List<ExpenseTypeSummaryData> rows = lookup.values.toList()..sort();
    return ExpenseReportSummaryData._(expenseReport.name, isFlagged, rows);
  }

  @override
  int compareTo(ExpenseReportSummaryData other) => name.compareTo(other.name);
}

@immutable
class ExpenseTypeSummaryData implements Comparable<ExpenseTypeSummaryData> {
  ExpenseTypeSummaryData._(this.name, this.expenses);

  final String name;
  final List<double> expenses;

  late final ExpenseReportSummaryData _owner;
  ExpenseReportSummaryData get owner => _owner;

  @override
  int compareTo(ExpenseTypeSummaryData other) => name.compareTo(other.name);
}
