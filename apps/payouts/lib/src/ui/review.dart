import 'dart:math' as math;

import 'package:chicago/chicago.dart' hide TableColumnWidth, TableRow;
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';

import 'accomplishments_view.dart';
import 'rotated_text.dart';

const _coloredRowDecoration = BoxDecoration(
  color: Color(0xffffffff),
);

class _ExpenseAggregation implements Comparable<_ExpenseAggregation> {
  _ExpenseAggregation(this.name, this.expenses);

  final String name;
  final List<double> expenses;
  double before = 0;
  double after = 0;

  @override
  int compareTo(_ExpenseAggregation other) => name.compareTo(other.name);
}

class ReviewAndSubmit extends StatelessWidget {
  const ReviewAndSubmit({Key? key}) : super(key: key);

  List<Widget> _buildHeaderBlock() {
    final Invoice invoice = InvoiceBinding.instance!.invoice!;
    final String startDate = DateFormats.mdyyyy.format(invoice.billingPeriod.start);
    final String endDate = DateFormats.mdyyyy.format(invoice.billingPeriod.end);
    final String total = NumberFormats.currency.format(invoice.total);
    return <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Text(invoice.vendor, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Text('Invoice #${invoice.invoiceNumber}'),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Text('$startDate - $endDate'),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Text(total),
      ),
    ];
  }

  List<TableRow> _buildTimesheetRowHeaderCells() {
    final Timesheets timesheets = InvoiceBinding.instance!.invoice!.timesheets;
    bool colorRow = true;
    return <TableRow>[
      ...timesheets.map<TableRow>((Timesheet timesheet) {
        final Decoration? decoration = colorRow ? _coloredRowDecoration : null;
        colorRow = !colorRow;
        return TableRow(
          decoration: decoration,
          children: <Widget>[SummaryRowHeader(label: timesheet.name)],
        );
      }),
      TableRow(
        decoration: BoxDecoration(
          color: Color(0xffedead9),
        ),
        children: [SummaryRowHeader(label: 'Daily Totals', isAggregate: true)],
      ),
    ];
  }

  Widget _buildDateHeading(DateTime date) {
    return SummaryDateHeading(DateFormats.md.format(date));
  }

  List<TableRow> _buildTimesheetEntryRows() {
    final Timesheets timesheets = InvoiceBinding.instance!.invoice!.timesheets;
    bool colorRow = true;
    double weeklyAggregateTotal = 0;
    List<double> dailyTotals = List<double>.filled(14, 0);
    int dayIndex = 0;
    Widget buildHours(
      double amount, {
      bool isWeekend = false,
      bool isAggregate = false,
      bool isWeeklyTotal = false,
    }) {
      if (!isAggregate) {
        dailyTotals[dayIndex++] += amount;
      }
      return DailyTotalHours(
        amount: amount,
        isWeekend: isWeekend,
        isAggregate: isAggregate,
        isWeeklyTotal: isWeeklyTotal,
      );
    }

    Widget buildWeekdayHours(double amount) => buildHours(amount);
    Widget buildWeekendHours(double amount) => buildHours(amount, isWeekend: true);
    Widget buildAggregateHours(double amount, {bool isWeeklyTotal = false}) {
      if (isWeeklyTotal) {
        weeklyAggregateTotal = 0;
      } else {
        weeklyAggregateTotal += amount;
      }
      return buildHours(amount, isAggregate: true, isWeeklyTotal: isWeeklyTotal);
    }

    return <TableRow>[
      ...timesheets.map<TableRow>((Timesheet timesheet) {
        dayIndex = 0;
        final Decoration? decoration = colorRow ? _coloredRowDecoration : null;
        colorRow = !colorRow;
        return TableRow(
          decoration: decoration,
          children: <Widget>[
            ...timesheet.hours.take(5).map<Widget>(buildWeekdayHours),
            ...timesheet.hours.skip(5).take(2).map<Widget>(buildWeekendHours),
            buildAggregateHours(0),
            ...timesheet.hours.skip(7).take(5).map<Widget>(buildWeekdayHours),
            ...timesheet.hours.skip(12).take(2).map<Widget>(buildWeekendHours),
            buildAggregateHours(0),
            Container(),
          ],
        );
      }),
      TableRow(
        decoration: const BoxDecoration(
          color: Color(0xffedead9),
        ),
        children: <Widget>[
          ...dailyTotals.take(7).map<Widget>(buildAggregateHours),
          buildAggregateHours(weeklyAggregateTotal, isWeeklyTotal: true),
          ...dailyTotals.skip(7).take(7).map<Widget>(buildAggregateHours),
          buildAggregateHours(weeklyAggregateTotal, isWeeklyTotal: true),
          Container(),
        ],
      ),
    ];
  }

  List<Widget> _buildTimesheetBlock() {
    final Invoice invoice = InvoiceBinding.instance!.invoice!;
    final Timesheets timesheets = invoice.timesheets;
    final String total = NumberFormats.currency.format(timesheets.computeTotal());
    return <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 27),
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                style: TextStyle(fontWeight: FontWeight.bold),
                child: Text('Billable Hours'),
              ),
            ),
            Text(total),
          ],
        ),
      ),
      DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffb3b3b3))),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 1),
          child: ScrollPane(
            horizontalScrollBarPolicy: ScrollBarPolicy.expand,
            topLeftCorner: Container(),
            bottomLeftCorner: const DecoratedBox(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xffb3b3b3))),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 1),
                child: ColoredBox(
                  color: Color(0xfff0ece7),
                ),
              ),
            ),
            rowHeader: Container(
              foregroundDecoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xffb3b3b3)),
                  left: BorderSide(color: Color(0xffb3b3b3)),
                  right: BorderSide(color: Color(0xffb3b3b3)),
                ),
              ),
              child: Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                border: TestBorder(
                  lastRowIsAggregate: true,
                ),
                children: _buildTimesheetRowHeaderCells(),
              ),
            ),
            columnHeader: Table(
              defaultColumnWidth: FixedColumnWidth(34),
              columnWidths: <int, TableColumnWidth>{
                16: FlexColumnWidth(),
              },
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    ...invoice.billingPeriod.take(7).map<Widget>(_buildDateHeading),
                    Container(),
                    ...invoice.billingPeriod.skip(7).take(7).map<Widget>(_buildDateHeading),
                    Container(),
                    Container(),
                  ],
                ),
              ],
            ),
            view: Container(
              foregroundDecoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xffb3b3b3)),
                  right: BorderSide(color: Color(0xffb3b3b3)),
                ),
              ),
              child: Table(
                defaultColumnWidth: FixedColumnWidth(34),
                columnWidths: <int, TableColumnWidth>{
                  16: FlexColumnWidth(),
                },
                border: TestBorder(
                  aggregateColumns: <int>[7, 15],
                  lastRowIsAggregate: true,
                ),
                children: _buildTimesheetEntryRows(),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<_ExpenseAggregation> _buildExpenseRows(ExpenseReport expenseReport) {
    final int duration = expenseReport.invoice.billingPeriod.length;
    final Map<int, _ExpenseAggregation> lookup = <int, _ExpenseAggregation>{};
    for (Expense expense in expenseReport.expenses) {
      final int id = expense.type.expenseTypeId;
      final _ExpenseAggregation row = lookup.putIfAbsent(id, () {
        return _ExpenseAggregation(expense.type.name, List<double>.filled(duration, 0));
      });
      final int index = expense.date.difference(expenseReport.invoice.billingPeriod.start).inDays;
      if (index < 0) {
        row.before += expense.amount;
      } else if (index >= row.expenses.length) {
        row.after += expense.amount;
      } else {
        row.expenses[index] += expense.amount;
      }
    }
    return lookup.values.toList()..sort();
  }

  Widget _buildWeekdayExpenseCell(double amount) {
    return DailyTotalDollars(amount: amount);
  }

  Widget _buildWeekendExpenseCell(double amount) {
    return DailyTotalDollars(amount: amount, isWeekend: true);
  }

  Widget _buildExpenseReport(ExpenseReport expenseReport) {
    final List<_ExpenseAggregation> rows = _buildExpenseRows(expenseReport);
    bool colorRow = true;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffb3b3b3))),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 1, top: 14),
        child: ScrollPane(
          horizontalScrollBarPolicy: ScrollBarPolicy.expand,
          topLeftCorner: Align(
            alignment: Alignment.bottomLeft,
            child: Text(expenseReport.name, maxLines: 1),
          ),
          bottomLeftCorner: const DecoratedBox(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xffb3b3b3))),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 1),
              child: ColoredBox(
                color: Color(0xfff0ece7),
              ),
            ),
          ),
          rowHeader: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 200),
            child: Container(
              foregroundDecoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xffb3b3b3)),
                  left: BorderSide(color: Color(0xffb3b3b3)),
                  right: BorderSide(color: Color(0xffb3b3b3)),
                ),
              ),
              child: Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                border: TestBorder(),
                children: <TableRow>[
                  ...rows.map<TableRow>((_ExpenseAggregation row) {
                    final Decoration? decoration = colorRow ? _coloredRowDecoration : null;
                    colorRow = !colorRow;
                    return TableRow(
                      decoration: decoration,
                      children: [SummaryRowHeader(label: row.name)],
                    );
                  }),
                ],
              ),
            ),
          ),
          columnHeader: Table(
            defaultColumnWidth: FixedColumnWidth(34),
            columnWidths: <int, TableColumnWidth>{
              16: FlexColumnWidth(),
            },
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  SummaryDateHeading('...'),
                  ...expenseReport.invoice.billingPeriod.map((DateTime date) {
                    return SummaryDateHeading(DateFormats.md.format(date));
                  }),
                  SummaryDateHeading('...'),
                  Container(),
                ],
              ),
            ],
          ),
          view: Container(
            foregroundDecoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xffb3b3b3)),
                right: BorderSide(color: Color(0xffb3b3b3)),
              ),
            ),
            child: Table(
              defaultColumnWidth: FixedColumnWidth(34),
              columnWidths: <int, TableColumnWidth>{
                16: FlexColumnWidth(),
              },
              border: const TestBorder(aggregateColumns: <int>[0, 15, 16]),
              children: <TableRow>[
                ...(){colorRow = true; return [];}(),
                ...rows.map<TableRow>((_ExpenseAggregation row) {
                  final Decoration? decoration = colorRow ? _coloredRowDecoration : null;
                  colorRow = !colorRow;
                  return TableRow(
                    decoration: decoration,
                    children: <Widget>[
                      _buildWeekdayExpenseCell(row.before),
                      ...row.expenses.take(5).map<Widget>(_buildWeekdayExpenseCell),
                      ...row.expenses.skip(5).take(2).map<Widget>(_buildWeekendExpenseCell),
                      ...row.expenses.skip(7).take(5).map<Widget>(_buildWeekdayExpenseCell),
                      ...row.expenses.skip(12).take(2).map<Widget>(_buildWeekendExpenseCell),
                      _buildWeekdayExpenseCell(row.after),
                      Container(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpenseReportBlock() {
    final ExpenseReports expenseReports = InvoiceBinding.instance!.invoice!.expenseReports;
    final String total = NumberFormats.currency.format(expenseReports.computeTotal());
    return <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 30),
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                style: TextStyle(fontWeight: FontWeight.bold),
                child: Text('Expense Reports'),
              ),
            ),
            Text(total),
          ],
        ),
      ),
      ...expenseReports.map<Widget>(_buildExpenseReport),
    ];
  }

  List<Widget> _buildAccomplishmentBlock() {
    return <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 30),
        child: Row(
          children: [
            DefaultTextStyle.merge(
              style: TextStyle(fontWeight: FontWeight.bold),
              child: Text('Accomplishments'),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(5, 16, 0, 5),
        child: Row(
          children: [
            Text('BSS, NNV8-913197 (COSC)'),
          ],
        ),
      ),
      AccomplishmentsEntryField(
        accomplishment: InvoiceBinding.instance!.invoice!.accomplishments.first,
        isReadOnly: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: ScrollPane(
        horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
        view: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ..._buildHeaderBlock(),
              ..._buildTimesheetBlock(),
              ..._buildExpenseReportBlock(),
              ..._buildAccomplishmentBlock(),
              Padding(
                padding: EdgeInsets.only(top: 22),
                child: CertifyAndSubmit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryDateHeading extends StatelessWidget {
  const SummaryDateHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return RotatedText(
      offset: const Offset(-6, 0.5),
      angle: math.pi / 2 - 1,
      text: text,
    );
  }
}

class SummaryRowHeader extends StatelessWidget {
  const SummaryRowHeader({
    Key? key,
    required this.label,
    this.isAggregate = false,
  }) : super(key: key);

  final String label;
  final bool isAggregate;

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;
    double height = 19;
    if (isAggregate) {
      style = style.copyWith(fontStyle: FontStyle.italic);
      height = 20;
    }

    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(3, 4, 15, 0),
        child: Text(label, maxLines: 1, style: style),
      ),
    );
  }
}

class CertifyAndSubmit extends StatefulWidget {
  @override
  _CertifyAndSubmitState createState() => _CertifyAndSubmitState();
}

class _CertifyAndSubmitState extends State<CertifyAndSubmit> {
  bool certified = false;

  void _handleSubmit() {}

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PushButton(
          icon: 'assets/lock.png',
          label: 'Submit Invoice',
          onPressed: certified ? _handleSubmit : null,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 3, 0),
          child: TerraCheckbox(
            value: certified,
            onChanged: (bool value) {
              setState(() {
                certified = value;
              });
            },
          ),
        ),
        Expanded(
          child: Text(
            'I certify that I have worked the above hours as described.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class DailyTotalHours extends StatelessWidget {
  const DailyTotalHours({
    required this.amount,
    this.isWeekend = false,
    this.isAggregate = false,
    this.isWeeklyTotal = false,
    Key? key,
  }) : super(key: key);

  final double amount;
  final bool isWeekend;
  final bool isAggregate;
  final bool isWeeklyTotal;

  @override
  Widget build(BuildContext context) {
    return DailyTotal(
      amount: amount,
      isWeekend: isWeekend,
      isAggregate: isAggregate,
      isWeeklyTotal: isWeeklyTotal,
      cautionIfExceeded: 12,
    );
  }
}

class DailyTotalDollars extends StatelessWidget {
  const DailyTotalDollars({
    required this.amount,
    this.isWeekend = false,
    this.isAggregate = false,
    this.isWeeklyTotal = false,
    Key? key,
  }) : super(key: key);

  final double amount;
  final bool isWeekend;
  final bool isAggregate;
  final bool isWeeklyTotal;

  @override
  Widget build(BuildContext context) {
    return DailyTotal(
      amount: amount,
      isWeekend: isWeekend,
      isAggregate: isAggregate,
      isWeeklyTotal: isWeeklyTotal,
    );
  }
}

class DailyTotal extends StatelessWidget {
  const DailyTotal({
    required this.amount,
    this.isWeekend = false,
    this.isAggregate = false,
    this.isWeeklyTotal = false,
    this.cautionIfExceeded,
    Key? key,
  }) : super(key: key);

  final double amount;
  final bool isWeekend;
  final bool isAggregate;
  final bool isWeeklyTotal;
  final double? cautionIfExceeded;

  static final intl.NumberFormat numberFormat = intl.NumberFormat('#.#');

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;
    if (isAggregate) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    if (isWeeklyTotal) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }
    if (cautionIfExceeded != null && amount > cautionIfExceeded! && !isWeeklyTotal) {
      style = style.copyWith(color: const Color(0xffb71c28));
    }

    final String value = amount > 0 ? numberFormat.format(amount) : '';
    Widget result = Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 3, 0),
      child: Text(value, style: style, textAlign: TextAlign.right),
    );

    if (isAggregate || isWeekend) {
      final Color color = isAggregate ? const Color(0xffedead9) : const Color(0xffeeeeee);
      result = SizedBox(
        height: 19,
        child: ColoredBox(
          color: color,
          child: result,
        ),
      );
    }

    return result;
  }
}

class TestBorder extends TableBorder {
  const TestBorder({
    this.aggregateColumns = const <int>[],
    this.lastRowIsAggregate = false,
  }) : super(
          top: _outsideBorder,
          right: _outsideBorder,
          bottom: _outsideBorder,
          left: _outsideBorder,
        );

  final List<int> aggregateColumns;
  final bool lastRowIsAggregate;

  static const BorderSide _outsideBorder = BorderSide(
    color: Color(0xffb3b3b3),
  );

  static List<int> _cellIndicesToBorderIndices(List<int> cellIndices) {
    return List.generate(cellIndices.length * 2, (int index) {
      int borderIndex = index ~/ 2;
      int offset = 1 - (index % 2);
      return cellIndices[borderIndex] - offset;
    });
  }

  @override
  TableBorder scale(double t) {
    throw UnsupportedError('scale');
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    required Iterable<double> rows,
    required Iterable<double> columns,
  }) {
    assert(rows.isEmpty || (rows.first >= 0.0 && rows.last <= rect.height));
    assert(columns.isEmpty ||
        (columns.first >= 0.0 &&
            rect.width - columns.last >= -Tolerance.defaultTolerance.distance));

    final List<double> rowsList = List<double>.from(rows, growable: false);
    final List<double> columnsList = List<double>.from(columns, growable: false);

    if (columnsList.isNotEmpty || rowsList.isNotEmpty) {
      final Paint paint = Paint();
      final Path path = Path();

      if (columnsList.isNotEmpty) {
        paint
          ..color = const Color(0xfff8f5ee)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        path.reset();
        for (final double x in columnsList) {
          path.moveTo(rect.left + x + 0.5, rect.top);
          path.lineTo(rect.left + x + 0.5, rect.bottom);
        }
        canvas.drawPath(path, paint);
      }

      if (rowsList.isNotEmpty) {
        paint
          ..color = const Color(0xfff8f5ee)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        path.reset();
        for (final double y in rowsList) {
          path.moveTo(rect.left, rect.top + y + 0.5);
          path.lineTo(rect.right, rect.top + y + 0.5);
        }
        canvas.drawPath(path, paint);
      }

      for (int columnIndex in _cellIndicesToBorderIndices(aggregateColumns)) {
        if (columnIndex >= 0 && columnIndex < columnsList.length) {
          paint
            ..color = const Color(0xffb3b3b3)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
          canvas.drawLine(
            Offset(rect.left + columnsList[columnIndex] + 0.5, rect.top /* + rowsList.first*/),
            Offset(rect.left + columnsList[columnIndex] + 0.5, rect.bottom),
            paint,
          );
        }
      }

      if (lastRowIsAggregate && rowsList.isNotEmpty) {
        paint
          ..color = const Color(0xffb3b3b3)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(rect.left, rect.top + rowsList.last + 0.5),
          Offset(rect.right, rect.top + rowsList.last + 0.5),
          paint,
        );
      }
    }

//    paintBorder(
//      canvas,
//      Rect.fromLTRB(rect.left, rect.top/* + rowsList.first*/, rect.right, rect.bottom),
//      top: top,
//      right: right,
//      bottom: bottom,
//      left: left,
//    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TestBorder &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom &&
        other.left == left &&
        other.horizontalInside == horizontalInside &&
        other.verticalInside == verticalInside &&
        other.aggregateColumns == aggregateColumns;
  }

  @override
  int get hashCode =>
      hashValues(top, right, bottom, left, horizontalInside, verticalInside, aggregateColumns);

  @override
  String toString() =>
      'TestBorder($top, $right, $bottom, $left, $horizontalInside, $verticalInside, $aggregateColumns)';
}

class TerraCheckbox extends StatelessWidget {
  const TerraCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onChanged(!value);
        },
        child: SizedBox(
          width: 14,
          height: 14,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff999999)),
            ),
            child: Padding(
              padding: EdgeInsets.all(1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: const <Color>[Color(0xfffcfcfc), Color(0xffe9e9e9)],
                  ),
                ),
                child: CustomPaint(
                  painter: CheckMarkPainter(checked: value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CheckMarkPainter extends CustomPainter {
  const CheckMarkPainter({
    required this.checked,
    this.color = const Color(0xff2b5580),
  });

  final bool checked;
  final Color color;

  static const double _checkmarkSize = 10;

  @override
  void paint(Canvas canvas, Size size) {
    if (checked) {
      Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5;

      final double n = _checkmarkSize / 2;
      final double m = _checkmarkSize / 4;
      final double offsetX = (size.width - (n + m)) / 2;
      final double offsetY = (size.height - n) / 2;

      canvas.drawLine(Offset(offsetX, (n - m) + offsetY), Offset(m + offsetX, n + offsetY), paint);
      canvas.drawLine(Offset(m + offsetX, n + offsetY), Offset((m + n) + offsetX, offsetY), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    assert(old is CheckMarkPainter);
    CheckMarkPainter oldPainter = old as CheckMarkPainter;
    return checked != oldPainter.checked;
  }
}
