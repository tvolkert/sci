import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;

import 'package:chicago/chicago.dart' as chicago;

import 'accomplishments_view.dart';
import 'rotated_text.dart';

class ReviewAndSubmit extends StatelessWidget {
  const ReviewAndSubmit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: chicago.ScrollPane(
        horizontalScrollBarPolicy: chicago.ScrollBarPolicy.stretch,
        view: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('Volkert, Todd', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('Invoice #FOO'),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('10/12/2015 - 10/25/2015'),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(r'$5,296.63'),
              ),
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
                    Text(r'$2,160.95'),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffb3b3b3))),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: chicago.ScrollPane(
                    horizontalScrollBarPolicy: chicago.ScrollBarPolicy.expand,
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
                        children: <TableRow>[
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [SummaryRowHeader(label: 'SCI - Overhead')],
                          ),
                          TableRow(
                            children: [SummaryRowHeader(label: 'BSS, NNV8-913197 (COSC) (123)')],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [SummaryRowHeader(label: 'Orbital Sciences (abd)')],
                          ),
                          TableRow(
                            children: [SummaryRowHeader(label: 'Loral - T14R')],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: Color(0xffedead9),
                            ),
                            children: [SummaryRowHeader(label: 'Daily Totals', isAggregate: true)],
                          ),
                        ],
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
                            SummaryDateHeading('10/12'),
                            SummaryDateHeading('10/13'),
                            SummaryDateHeading('10/14'),
                            SummaryDateHeading('10/15'),
                            SummaryDateHeading('10/16'),
                            SummaryDateHeading('10/17'),
                            SummaryDateHeading('10/18'),
                            Container(),
                            SummaryDateHeading('10/19'),
                            SummaryDateHeading('10/20'),
                            SummaryDateHeading('10/21'),
                            SummaryDateHeading('10/22'),
                            SummaryDateHeading('10/23'),
                            SummaryDateHeading('10/24'),
                            SummaryDateHeading('10/25'),
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
                        children: <TableRow>[
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            children: <Widget>[
                              DailyTotalHours(amount: 4),
                              DailyTotalHours(amount: 4),
                              DailyTotalHours(amount: 5),
                              DailyTotalHours(amount: 6),
                              DailyTotalHours(amount: 6),
                              DailyTotalHours(amount: 7, isWeekend: true),
                              DailyTotalHours(amount: 6, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 7),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              Container(),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 10),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              Container(),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            children: <Widget>[
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 2),
                              DailyTotalHours(amount: 1),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              Container(),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 8),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isWeekend: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              Container(),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: Color(0xffedead9),
                            ),
                            children: <Widget>[
                              DailyTotalHours(amount: 4, isAggregate: true),
                              DailyTotalHours(amount: 6, isAggregate: true),
                              DailyTotalHours(amount: 6, isAggregate: true),
                              DailyTotalHours(amount: 16, isAggregate: true),
                              DailyTotalHours(amount: 6, isAggregate: true),
                              DailyTotalHours(amount: 7, isAggregate: true),
                              DailyTotalHours(amount: 6, isAggregate: true),
                              DailyTotalHours(amount: 51, isAggregate: true, isWeeklyTotal: true),
                              DailyTotalHours(amount: 15, isAggregate: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 0, isAggregate: true),
                              DailyTotalHours(amount: 15, isAggregate: true, isWeeklyTotal: true),
                              Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                    Text(r'$3,136.63'),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffb3b3b3))),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: chicago.ScrollPane(
                    horizontalScrollBarPolicy: chicago.ScrollBarPolicy.expand,
                    topLeftCorner: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Orbital Sciences (123)', maxLines: 1),
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
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [SummaryRowHeader(label: 'Car Rental')],
                            ),
                            TableRow(
                              children: [SummaryRowHeader(label: 'Lodging')],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 1),
                                  child: SummaryRowHeader(label: 'Parking'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    columnHeader: Table(
                      defaultColumnWidth: FixedColumnWidth(34),
                      columnWidths: <int, TableColumnWidth>{
                        14: FlexColumnWidth(),
                      },
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            SummaryDateHeading('10/12'),
                            SummaryDateHeading('10/13'),
                            SummaryDateHeading('10/14'),
                            SummaryDateHeading('10/15'),
                            SummaryDateHeading('10/16'),
                            SummaryDateHeading('10/17'),
                            SummaryDateHeading('10/18'),
                            SummaryDateHeading('10/19'),
                            SummaryDateHeading('10/20'),
                            SummaryDateHeading('10/21'),
                            SummaryDateHeading('10/22'),
                            SummaryDateHeading('10/23'),
                            SummaryDateHeading('10/24'),
                            SummaryDateHeading('10/25'),
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
                          14: FlexColumnWidth(),
                        },
                        border: const TestBorder(aggregateColumns: <int>[14]),
                        children: <TableRow>[
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            children: <Widget>[
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 34),
                              DailyTotalDollars(amount: 23),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              Container(),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219, isWeekend: true),
                              DailyTotalDollars(amount: 219, isWeekend: true),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219),
                              DailyTotalDollars(amount: 219, isWeekend: true),
                              DailyTotalDollars(amount: 219, isWeekend: true),
                              Container(),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            children: <Widget>[
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 12),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              DailyTotalDollars(amount: 0, isWeekend: true),
                              Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                initialText: 'qdlkajs flsdsdl',
                readOnly: true,
              ),
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
  })  : super(key: key);

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
        chicago.PushButton(
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
  })  : super(key: key);

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
  })  : super(key: key);

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
  })  : super(key: key);

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
  })  : super(
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
