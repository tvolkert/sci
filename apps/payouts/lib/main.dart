import 'dart:math' as math;
import 'dart:ui' show window;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'package:payouts/bug_report.dart';
import 'package:payouts/expense_report_list_tile.dart';
import 'package:payouts/splitter.dart';
import 'package:payouts/src/pivot.dart' as pivot;

import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_home.dart';

import 'expense_report_list_view.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details, {bool forceReport = false}) =>
      FlutterError.dumpErrorToConsole(details, forceReport: true);
  runApp(
//    BugReport(),
    PayoutsApp(),
  );
}

bool relicatedUi = true;

class PayoutsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (relicatedUi) {
      return MaterialApp(
        title: 'Payouts',
        theme: ThemeData(
          brightness: Brightness.light,
          visualDensity: VisualDensity.compact,
          primaryColor: Color(0xFFC8C8BB),
          accentColor: Color(0xFFF7F5EE),
          scaffoldBackgroundColor: Color(0xFFF7F5EE),
          fontFamily: 'Dialog',
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 11.0, fontFamily: 'Verdana'),
            subtitle1: TextStyle(fontSize: 11.0, fontFamily: 'Verdana'),
          ),
        ),
        home: Foo(),
      );
    } else {
      return MaterialApp(
        title: 'Payouts',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: InvoiceHome(),
        builder: (BuildContext context, Widget child) {
          return UserBinding(
            child: InvoiceBinding(
              child: PersistentCredentials(
                child: RequireUser(
                  child: child,
                ),
              ),
            ),
          );
        },
      );
    }
  }
}

class Foo extends StatefulWidget {
  @override
  _FooState createState() => _FooState();
}

class _FooState extends State<Foo> with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: 'Billable Hours'),
    Tab(text: 'Expense Reports'),
    Tab(text: 'Accomplishments'),
    Tab(text: 'Review & Submit'),
  ];

  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[Color(0xffc8c8bb), Color(0xffdddcd5)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(5, 2, 8, 3),
              child: SizedBox(
                height: 57,
                child: Row(
                  children: <Widget>[
                    TerraPushButton(
                      onPressed: () {
//                        showGeneralDialog(
//                          context: context,
//                          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
//                            return TerraSheet();
//                          },
//                          barrierDismissible: false,
//                          barrierColor: const Color(0xaa000000),
//                        );
                        print('TODO: new invoice');
                      },
                      icon: 'assets/document-new.png',
                      label: 'New Invoice',
                      axis: Axis.vertical,
                      isToolbar: true,
                    ),
                    SizedBox(width: 5),
                    TerraPushButton(
                      onPressed: () {
                        print('TODO: open invoice');
                      },
                      icon: 'assets/document-open.png',
                      label: 'Open Invoice',
                      axis: Axis.vertical,
                      isToolbar: true,
                    ),
                    SizedBox(width: 5),
                    TerraPushButton(
                      icon: 'assets/media-floppy.png',
                      label: 'Save to Server',
                      axis: Axis.vertical,
                      isToolbar: true,
                    ),
                    SizedBox(width: 5),
                    TerraPushButton(
                      onPressed: () {
                        print('TODO: delete invoice');
                      },
                      icon: 'assets/dialog-cancel.png',
                      label: 'Delete Invoice',
                      axis: Axis.vertical,
                      isToolbar: true,
                    ),
                    SizedBox(width: 5),
                    TerraPushButton(
                      onPressed: () {
                        print('TODO: export to PDF');
                      },
                      icon: 'assets/x-office-presentation.png',
                      label: 'Export to PDF',
                      axis: Axis.vertical,
                      isToolbar: true,
                    ),
                    Spacer(),
                    SizedBox(
                      width: 64,
                      child: TerraPushButton(
                        onPressed: () {},
                        icon: 'assets/help-browser.png',
                        label: 'Help',
                        axis: Axis.vertical,
                        isToolbar: true,
                        menuItems: <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'about',
                            height: 22,
                            child: Text('About'),
                          ),
                          PopupMenuItem<String>(
                            value: 'feedback',
                            height: 22,
                            child: Text('Provide feedback'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Color(0xff999999),
          ),
          Expanded(
            child: Ink(
              decoration: BoxDecoration(color: Color(0xffc8c8bb)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 5.5, 5),
                    child: SizedBox(
                      height: 22,
                      child: Row(
                        children: [
                          Transform.translate(
                            offset: Offset(0, -1),
                            child: Text(
                              'FOO',
                              style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          HoverPushButton(
                            iconName: 'assets/pencil.png',
                            onPressed: () {},
                          ),
                          Transform.translate(
                            offset: Offset(0, -1),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text('(10/12/2015 - 10/25/2015)'),
                            ),
                          ),
                          Spacer(),
                          Transform.translate(
                            offset: Offset(0, -1),
                            child: Text(r'Total Check Amount: $5,296.63'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 6, 4),
                      child: pivot.TabPane(
                        initialSelectedIndex: 0,
                        tabs: <pivot.Tab>[
                          pivot.Tab(
                            label: 'Billable Hours',
                            child: BillableHours(),
                          ),
                          pivot.Tab(
                            label: 'Expense Reports',
                            child: ExpenseReports(),
                          ),
                          pivot.Tab(
                            label: 'Accomplishments',
                            child: Accomplishments(),
                          ),
                          pivot.Tab(
                            label: 'Review & Submit',
                            child: ReviewAndSubmit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewAndSubmit extends StatelessWidget {
  const ReviewAndSubmit({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: pivot.ScrollPane(
        horizontalScrollBarPolicy: pivot.ScrollBarPolicy.stretch,
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
                  child: pivot.ScrollPane(
                    horizontalScrollBarPolicy: pivot.ScrollBarPolicy.expand,
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
                  child: pivot.ScrollPane(
                    horizontalScrollBarPolicy: pivot.ScrollBarPolicy.expand,
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

class CertifyAndSubmit extends StatefulWidget {
  @override
  _CertifyAndSubmitState createState() => _CertifyAndSubmitState();
}

class _CertifyAndSubmitState extends State<CertifyAndSubmit> {
  bool certified;

  @override
  void initState() {
    super.initState();
    certified = false;
  }

  void _handleSubmit() {}

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TerraPushButton(
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

class TerraCheckbox extends StatelessWidget {
  const TerraCheckbox({
    Key key,
    @required this.value,
    @required this.onChanged,
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

class Accomplishments extends StatelessWidget {
  const Accomplishments({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              LinkButton(
                image: AssetImage('assets/note_add.png'),
                text: 'Add accomplishment',
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text('BSS, NNV8-913197 (COSC)'),
                  ),
                  Expanded(
                    child: AccomplishmentsEntryField(
                      minLines: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SortDirection {
  ascending,
  descending,
}

class TableHeaderCell extends StatelessWidget {
  const TableHeaderCell({
    Key key,
    @required this.label,
    this.width,
    this.sortDirection,
  }) : super(key: key);

  final String label;
  final double width;
  final SortDirection sortDirection;

  @override
  Widget build(BuildContext context) {
    Widget content = Text(label);
    if (sortDirection != null) {
      content = Row(
        children: [
          content,
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 2),
                child: CustomPaint(
                  size: Size(7, 4),
                  painter: SortIndicatorPainter(sortDirection: sortDirection),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final Widget box = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xff999999)),
          right: BorderSide(color: Color(0xff999999)),
          bottom: BorderSide(color: Color(0xff999999)),
        ),
        gradient: LinearGradient(
          begin: Alignment(0, 0.8),
          end: Alignment(0, -0.8),
          colors: <Color>[Color(0xffdfded7), Color(0xfff6f4ed)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(3, 2, 3, 3),
        child: content,
      ),
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: box,
      );
    } else {
      return Expanded(
        child: box,
      );
    }
  }
}

class SortIndicatorPainter extends CustomPainter {
  const SortIndicatorPainter({
    this.sortDirection,
    this.isAntiAlias = true,
    this.color = const Color(0xff999999),
  });

  final SortDirection sortDirection;
  final bool isAntiAlias;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = isAntiAlias;
    Path path = Path();
    switch (sortDirection) {
      case SortDirection.ascending:
        path
          ..moveTo(0, 3)
          ..lineTo(3, 0)
          ..lineTo(6, 3);
        break;
      case SortDirection.descending:
        path
          ..moveTo(0, 0)
          ..lineTo(3, 3)
          ..lineTo(6, 0);
        break;
    }

    path.close();
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    assert(old is SortIndicatorPainter);
    SortIndicatorPainter oldPainter = old;
    return sortDirection != oldPainter.sortDirection;
  }
}

class CheckMarkPainter extends CustomPainter {
  const CheckMarkPainter({
    @required this.checked,
    this.color = const Color(0xff2b5580),
  })  : assert(checked != null),
        assert(color != null);

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
    CheckMarkPainter oldPainter = old;
    return checked != oldPainter.checked;
  }
}

class TimesheetHeaderRow extends StatefulWidget {
  const TimesheetHeaderRow({
    Key key,
    @required this.assignment,
  }) : super(key: key);

  final String assignment;

  @override
  _TimesheetHeaderRowState createState() => _TimesheetHeaderRowState();
}

class _TimesheetHeaderRowState extends State<TimesheetHeaderRow> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          hover = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          hover = false;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(widget.assignment, maxLines: 1),
            ),
          ),
          Baseline(
            baseline: 18.5,
            baselineType: TextBaseline.alphabetic,
            child: Opacity(
              opacity: hover ? 1 : 0,
              child: HoverPushButton(
                iconName: 'assets/pencil.png',
                onPressed: () {},
              ),
            ),
          ),
          Baseline(
            baseline: 18.5,
            baselineType: TextBaseline.alphabetic,
            child: Opacity(
              opacity: hover ? 1 : 0,
              child: HoverPushButton(
                iconName: 'assets/cross.png',
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(width: 1),
        ],
      ),
    );
  }
}

class HoverPushButton extends StatefulWidget {
  const HoverPushButton({
    @required this.iconName,
    @required this.onPressed,
    Key key,
  })  : assert(iconName != null),
        super(key: key);

  final String iconName;
  final VoidCallback onPressed;

  @override
  _HoverPushButtonState createState() => _HoverPushButtonState();
}

class _HoverPushButtonState extends State<HoverPushButton> {
  bool highlighted = false;

  @override
  Widget build(BuildContext context) {
    Widget button = FlatButton(
      color: Colors.transparent,
      hoverColor: Colors.transparent,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: widget.onPressed,
      child: Image.asset(widget.iconName),
    );

    if (highlighted) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xffdddcd5), Color(0xfff3f2eb)],
          ),
        ),
        child: button,
      );
    }

    return ButtonTheme(
      shape: highlighted ? Border.all(color: Color(0xff999999)) : Border(),
      minWidth: 1,
      height: 16,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: MouseRegion(
        onEnter: (PointerEnterEvent event) {
          setState(() {
            highlighted = true;
          });
        },
        onExit: (PointerExitEvent event) {
          setState(() {
            highlighted = false;
          });
        },
        child: button,
      ),
    );
  }
}

class HoursTextInput extends StatelessWidget {
  final bool isWeekend;

  HoursTextInput({this.isWeekend = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 1, 1),
      child: TextField(
        cursorWidth: 1,
        cursorColor: Colors.black,
        style: TextStyle(fontFamily: 'Verdana', fontSize: 11),
        decoration: InputDecoration(
          fillColor: isWeekend ? Color(0xffdddcd5) : Colors.white,
          hoverColor: isWeekend ? Color(0xffdddcd5) : Colors.white,
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(3, 13, 0, 4),
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff999999)),
            borderRadius: BorderRadius.zero,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff999999)),
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }
}

class Heading extends StatelessWidget {
  const Heading(this.text) : assert(text != null);

  final String text;

  @override
  Widget build(BuildContext context) {
    return RotatedText(
      offset: const Offset(-6, 4),
      angle: math.pi / 6,
      text: text,
    );
  }
}

class SummaryDateHeading extends StatelessWidget {
  const SummaryDateHeading(this.text) : assert(text != null);

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

class RotatedText extends StatelessWidget {
  const RotatedText({
    Key key,
    @required this.offset,
    @required this.angle,
    @required this.text,
  })  : assert(offset != null),
        assert(angle != null),
        assert(text != null),
        super(key: key);

  final Offset offset;
  final double angle;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        alignment: Alignment.bottomCenter,
        angle: angle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 40,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(text, maxLines: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class LinkButton extends StatefulWidget {
  const LinkButton({this.image, this.text, this.onPressed});

  final ImageProvider image;
  final String text;
  final VoidCallback onPressed;

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          hover = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          hover = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.image != null)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Image(image: widget.image),
              ),
            Text(
              widget.text,
              style: TextStyle(
                color: Color(0xff2b5580),
                decoration: hover ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TerraPushButton extends StatefulWidget {
  TerraPushButton({
    @required this.icon,
    @required this.label,
    this.axis = Axis.horizontal,
    this.isToolbar = false,
    this.onPressed,
    this.menuItems,
  })  : assert(icon != null),
        assert(label != null);

  final String icon;
  final String label;
  final Axis axis;
  final bool isToolbar;
  final VoidCallback onPressed;
  final List<PopupMenuEntry> menuItems;

  @override
  _TerraPushButtonState createState() => _TerraPushButtonState();
}

class _TerraPushButtonState extends State<TerraPushButton> {
  bool hover;
  bool pressed;

  static const LinearGradient highlightGradient = LinearGradient(
    begin: Alignment(0, 0.2),
    end: Alignment.topCenter,
    colors: <Color>[Color(0xffdddcd5), Color(0xfff6f4ed)],
  );

  static const LinearGradient pressedGradient = LinearGradient(
    begin: Alignment.center,
    end: Alignment.topCenter,
    colors: <Color>[Color(0xffdddcd5), Color(0xffc5c4bd)],
  );

  @override
  void initState() {
    super.initState();
    hover = false;
    pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;

    final List<Widget> buttonData = <Widget>[];
    if (widget.icon != null) {
      Widget iconImage = Image(image: AssetImage(widget.icon));
      if (!enabled) {
        iconImage = Opacity(
          opacity: 0.5,
          child: iconImage,
        );
      }
      buttonData..add(iconImage)..add(SizedBox(width: 4, height: 4));
    }

    if (widget.label != null) {
      TextStyle style = Theme.of(context).textTheme.bodyText2;
      if (!enabled) {
        style = style.copyWith(color: const Color(0xff999999));
      }
      buttonData.add(Text(widget.label, style: style));
    }

    Widget button = Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: widget.axis == Axis.horizontal ? Row(children: buttonData) : Column(children: buttonData),
    );

    if (widget.menuItems != null) {
      button = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: button,
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: CustomPaint(
              size: Size(7, 4),
              painter: SortIndicatorPainter(
                sortDirection: SortDirection.descending,
                color: Colors.black,
              ),
            ),
          )
        ],
      );
    }

    if (hover || !widget.isToolbar) {
      const Border border = Border.fromBorderSide(BorderSide(color: Color(0xff999999)));
      Decoration decoration;
      if (enabled && pressed) {
        decoration = const BoxDecoration(border: border, gradient: pressedGradient);
      } else if (enabled) {
        decoration = const BoxDecoration(border: border, gradient: highlightGradient);
      } else {
        decoration = const BoxDecoration(border: border, color: Color(0xffdddcd5));
      }
      button = DecoratedBox(decoration: decoration, child: button);
    }

    GestureTapCallback callback = widget.onPressed;
    if (widget.menuItems != null) {
      callback = () {
        if (widget.onPressed != null) {
          widget.onPressed();
        }
        setState(() {
          hover = true;
          pressed = true;
        });
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        showMenu<String>(
          context: context,
          position: position,
          items: widget.menuItems,
        ).then((String value) {
          setState(() {
            hover = false;
            pressed = false;
          });
          switch (value) {
            case 'about':
              showAboutDialog(
                context: context,
                applicationName: 'Payouts',
                applicationVersion: '2.0.0',
                applicationIcon: Image.asset('assets/logo-large.png'),
                applicationLegalese:
                    '\u00A9 2001-2020 Satellite Consulting, Inc. All Rights Reserved. SCI Payouts and the Satellite Consulting, Inc. logo are trademarks of Satellite Consulting, Inc. All rights reserved.',
              );
              break;
          }
        });
      };
    }

    if (enabled) {
      button = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (PointerEnterEvent event) {
          setState(() => hover = true);
        },
        onExit: (PointerExitEvent event) {
          if (!Navigator.of(context).canPop()) {
            setState(() => hover = false);
          }
        },
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            setState(() => pressed = true);
          },
          onPointerUp: (PointerUpEvent event) {
            setState(() => pressed = false);
          },
          child: GestureDetector(
            onTap: callback,
            child: Tooltip(
              message: widget.label,
              waitDuration: Duration(seconds: 1, milliseconds: 500),
              child: button,
            ),
          ),
        ),
      );
    }

    return button;
  }
}

class BillableHours extends StatelessWidget {
  TableRow _buildRow(String assignment, String footer) {
    return TableRow(
      children: <Widget>[
        TimesheetHeaderRow(assignment: assignment),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(isWeekend: true),
        HoursTextInput(isWeekend: true),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(),
        HoursTextInput(isWeekend: true),
        HoursTextInput(isWeekend: true),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(footer, maxLines: 1),
        ),
        Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 7),
            child: LinkButton(
              image: AssetImage('assets/table_add.png'),
              text: 'Add hours line item',
              onPressed: () {},
            ),
          ),
          Expanded(
            child: pivot.ScrollPane(
              horizontalScrollBarPolicy: pivot.ScrollBarPolicy.expand,
              view: Padding(
                padding: EdgeInsets.only(left: 20, right: 25),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: FixedColumnWidth(33),
                    2: FixedColumnWidth(33),
                    3: FixedColumnWidth(33),
                    4: FixedColumnWidth(33),
                    5: FixedColumnWidth(33),
                    6: FixedColumnWidth(33),
                    7: FixedColumnWidth(33),
                    8: FixedColumnWidth(33),
                    9: FixedColumnWidth(33),
                    10: FixedColumnWidth(33),
                    11: FixedColumnWidth(33),
                    12: FixedColumnWidth(33),
                    13: FixedColumnWidth(33),
                    14: FixedColumnWidth(33),
                    15: IntrinsicColumnWidth(),
                    16: FlexColumnWidth(),
                  },
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Container(),
                        Heading('10/12'),
                        Heading('10/13'),
                        Heading('10/14'),
                        Heading('10/15'),
                        Heading('10/16'),
                        Heading('10/17'),
                        Heading('10/18'),
                        Heading('10/19'),
                        Heading('10/20'),
                        Heading('10/21'),
                        Heading('10/22'),
                        Heading('10/23'),
                        Heading('10/24'),
                        Heading('10/25'),
                        Container(),
                        Container(),
                      ],
                    ),
                    _buildRow('SCI - Overhead', r'47 hrs @$0.00/hr ($0.00)'),
                    _buildRow('BSS, NNV8-913197 (COSC) (123)', r'1.21 hrs @$95.00/hr ($114.95)'),
                    _buildRow('Orbital Sciences (abc)', r'5 hrs @$110.00/hr ($550.00)'),
                    _buildRow('Loral - T14R', r'0 hrs @$110.00/hr ($0.00)'),
                    _buildRow('Sirius FM 6', r'5 hrs @$120.00/hr ($600.00)'),
                    TableRow(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xff999999)))),
                      children: [
                        SizedBox(height: 5),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                        Container(),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Daily Totals', maxLines: 1, style: TextStyle(fontStyle: FontStyle.italic)),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('6', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('6', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('6', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('9.21', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('11', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('7', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('6', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 2),
                          child: Text('7', style: TextStyle(fontStyle: FontStyle.italic)),
                        ),
                        Text(''),
                        Text(''),
                        Text(''),
                        Text(''),
                        Text(''),
                        Text(''),
                        Container(),
                        Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseReports extends StatelessWidget {
  List<TableRow> _buildExpenseRows() {
    List<List<String>> data = [
      ['2015-10-12', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-13', 'Car Rental', r'$34.50', 'Test'],
      ['2015-10-13', 'Parking', r'$12.00', ''],
      ['2015-10-13', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-14', 'Car Rental', r'$23.43', 'foo'],
      ['2015-10-14', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-15', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-16', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-17', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-18', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-19', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-20', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-21', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-22', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-23', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-24', 'Lodging', r'$219.05', 'Hotel'],
      ['2015-10-25', 'Lodging', r'$219.05', 'Hotel'],
    ];

    List<Color> colors = <Color>[Colors.white, Color(0xfff7f5ee)];
    int colorIndex = 1;
    return data.map<TableRow>((List<String> row) {
      colorIndex = 1 - colorIndex;
      return TableRow(
        decoration: BoxDecoration(color: colors[colorIndex]),
        children: row.map<Widget>((String value) {
          return Padding(
            padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 7, 5),
            child: LinkButton(
              image: AssetImage('assets/money_add.png'),
              text: 'Add expense report',
              onPressed: () {},
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Split(
                axis: Axis.horizontal,
                initialFractions: [0.25, 0.75],
                children: [
                  ExpenseReportListView(),
                  DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(color: Color(0xFF999999))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(11, 11, 11, 9),
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black),
                            child: Table(
                              columnWidths: {
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Program:')),
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Orbital Sciences')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Charge number:')),
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('123')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Dates:')),
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('2015-10-12 to 2015-10-25')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Purpose of travel:')),
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('None of your business')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Destination (city):')),
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Vancouver')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4, right: 6),
                                        child: Text('Party or parties visited:')),
                                    Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Jimbo')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 9, left: 11),
                          child: Row(
                            children: [
                              LinkButton(
                                image: AssetImage('assets/money_add.png'),
                                text: 'Add expense line item',
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(1),
                            child: pivot.ScrollPane(
                              horizontalScrollBarPolicy: pivot.ScrollBarPolicy.stretch,
                              topRightCorner: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xfff0ece7),
                                  border: Border(
                                    top: BorderSide(color: Color(0xff999999)),
                                  ),
                                ),
                              ),
                              columnHeader: Row(
                                children: [
                                  TableHeaderCell(width: 120, label: 'Date', sortDirection: SortDirection.ascending),
                                  TableHeaderCell(width: 120, label: 'Type'),
                                  TableHeaderCell(width: 100, label: 'Amount'),
                                  TableHeaderCell(label: 'Description'),
                                ],
                              ),
                              view: Table(
                                border: TableBorder.symmetric(
                                  inside: BorderSide(
                                    width: 0,
                                    color: Color(0xfff7f5ee),
                                  ),
                                ),
                                columnWidths: <int, TableColumnWidth>{
                                  0: FixedColumnWidth(120),
                                  1: FixedColumnWidth(120),
                                  2: FixedColumnWidth(100),
                                  3: FlexColumnWidth(),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: _buildExpenseRows(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryReportTableDecoration extends Decoration {
  const SummaryReportTableDecoration({
    @required this.border,
    @required this.color,
  }) : assert(border != null);

  final BoxBorder border;
  final Color color;

  @override
  SummaryReportBoxPainter createBoxPainter([VoidCallback onChanged]) {
    return SummaryReportBoxPainter(this, onChanged);
  }
}

class SummaryReportBoxPainter extends BoxPainter {
  const SummaryReportBoxPainter(this._decoration, VoidCallback onChanged)
      : assert(_decoration != null),
        super(onChanged);

  final SummaryReportTableDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect backgroundRect = offset & (configuration.size - Offset(0, 1));
    final Rect borderRect = (offset - Offset(1, 0)) & (configuration.size + Offset(2, 0));
    canvas.drawRect(backgroundRect, Paint()..color = _decoration.color);
    _decoration.border?.paint(
      canvas,
      borderRect,
      shape: BoxShape.rectangle,
      borderRadius: null,
      textDirection: configuration.textDirection,
    );
  }
}

class TestBorder extends TableBorder {
  const TestBorder({
    this.aggregateColumns = const <int>[],
    this.lastRowIsAggregate = false,
  })  : assert(aggregateColumns != null),
        assert(lastRowIsAggregate != null),
        super(
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
    @required Iterable<double> rows,
    @required Iterable<double> columns,
  }) {
    // properties can't be null
    assert(top != null);
    assert(right != null);
    assert(bottom != null);
    assert(left != null);

    // arguments can't be null
    assert(canvas != null);
    assert(rect != null);
    assert(rows != null);
    assert(rows.isEmpty || (rows.first >= 0.0 && rows.last <= rect.height));
    assert(columns != null);
    assert(columns.isEmpty || (columns.first >= 0.0 && rect.width - columns.last >= -Tolerance.defaultTolerance.distance));

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
  int get hashCode => hashValues(top, right, bottom, left, horizontalInside, verticalInside, aggregateColumns);

  @override
  String toString() =>
      'TestBorder($top, $right, $bottom, $left, $horizontalInside, $verticalInside, $aggregateColumns)';
}

class DailyTotalHours extends StatelessWidget {
  const DailyTotalHours({
    @required this.amount,
    this.isWeekend = false,
    this.isAggregate = false,
    this.isWeeklyTotal = false,
    Key key,
  })  : assert(amount != null),
        super(key: key);

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
    @required this.amount,
    this.isWeekend = false,
    this.isAggregate = false,
    this.isWeeklyTotal = false,
    Key key,
  })  : assert(amount != null),
        super(key: key);

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
    @required this.amount,
    this.isWeekend = false,
    this.isAggregate = false,
    this.isWeeklyTotal = false,
    this.cautionIfExceeded,
    Key key,
  })  : assert(amount != null),
        super(key: key);

  final double amount;
  final bool isWeekend;
  final bool isAggregate;
  final bool isWeeklyTotal;
  final double cautionIfExceeded;

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
    if (cautionIfExceeded != null && amount > cautionIfExceeded && !isWeeklyTotal) {
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

class SummaryRowHeader extends StatelessWidget {
  const SummaryRowHeader({
    Key key,
    @required this.label,
    this.isAggregate = false,
  })  : assert(label != null),
        super(key: key);

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

class AccomplishmentsEntryField extends StatefulWidget {
  const AccomplishmentsEntryField({
    Key key,
    this.minLines = 2,
    this.maxLines = 20,
    this.readOnly = false,
    this.initialText,
  }) : super(key: key);

  final int minLines;
  final int maxLines;
  final bool readOnly;
  final String initialText;

  @override
  _AccomplishmentsEntryFieldState createState() => _AccomplishmentsEntryFieldState();
}

class _AccomplishmentsEntryFieldState extends State<AccomplishmentsEntryField> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff999999), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(1),
        child: TextField(
          controller: controller,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          cursorWidth: 1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 7),
            hoverColor: Colors.transparent,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
