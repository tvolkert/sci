import 'dart:async';
import 'dart:convert';
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
import 'package:payouts/src/actions.dart';
import 'package:payouts/src/pivot.dart' as pivot;

import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/common/task_monitor.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_home.dart';

import 'expense_report_list_view.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details, {bool forceReport = false}) =>
      FlutterError.dumpErrorToConsole(details, forceReport: true);
  runApp(
//    BugReport(),
    pivot.NavigatorListener(
      child: PayoutsApp(),
    ),
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
        actions: <Type, Action<Intent>>{
          ...WidgetsApp.defaultActions,
          AboutIntent: AboutAction(),
          AddTimesheetIntent: AddTimesheetAction(),
          CreateInvoiceIntent: CreateInvoiceAction(),
          DeleteInvoiceIntent: DeleteInvoiceAction(),
          ExportInvoiceIntent: ExportInvoiceAction(),
          LoginIntent: LoginAction(),
          OpenInvoiceIntent: OpenInvoiceAction(),
          SaveInvoiceIntent: SaveInvoiceAction(),
        },
        shortcuts: <LogicalKeySet, Intent>{
          ...WidgetsApp.defaultShortcuts,
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): CreateInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyD): DeleteInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyE): ExportInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyO): OpenInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS): SaveInvoiceIntent(),
        },
        navigatorObservers: [
          pivot.NavigatorListener.of(context).observer,
        ],
        home: PayoutsScaffold(),
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

class PayoutsScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        // TODO set the alpha on this color to ff
        color: const Color(0x00c8c8bb),
        child: TaskMonitor(
          child: RequireUser(
            child: PayoutsHome(),
          ),
        ),
      ),
    );
  }
}

class PayoutsHome extends StatelessWidget {
  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'about':
        Actions.invoke(context, AboutIntent(context: context));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  pivot.ActionPushButton<CreateInvoiceIntent>(
                    icon: 'assets/document-new.png',
                    label: 'New Invoice',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: CreateInvoiceIntent(context: context),
                  ),
                  SizedBox(width: 5),
                  pivot.ActionPushButton<OpenInvoiceIntent>(
                    icon: 'assets/document-open.png',
                    label: 'Open Invoice',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: OpenInvoiceIntent(context: context),
                  ),
                  SizedBox(width: 5),
                  pivot.ActionPushButton<SaveInvoiceIntent>(
                    icon: 'assets/media-floppy.png',
                    label: 'Save to Server',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: SaveInvoiceIntent(context: context),
                  ),
                  SizedBox(width: 5),
                  pivot.ActionPushButton<DeleteInvoiceIntent>(
                    icon: 'assets/dialog-cancel.png',
                    label: 'Delete Invoice',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: DeleteInvoiceIntent(context: context),
                  ),
                  SizedBox(width: 5),
                  pivot.ActionPushButton<ExportInvoiceIntent>(
                    icon: 'assets/x-office-presentation.png',
                    label: 'Export to PDF',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: ExportInvoiceIntent(context: context),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 64,
                    child: pivot.PushButton<String>(
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
                      onMenuItemSelected: (String value) {
                        _onMenuItemSelected(context, value);
                      },
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(fontWeight: FontWeight.bold),
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
        pivot.PushButton(
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
              pivot.LinkButton(
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
            child: pivot.LinkButton(
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
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xff999999)))),
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
                        Text('Daily Totals',
                            maxLines: 1, style: TextStyle(fontStyle: FontStyle.italic)),
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

class ExpenseCellWrapper extends StatelessWidget {
  const ExpenseCellWrapper({
    Key key,
    this.rowIndex = 0,
    this.rowHighlighted = false,
    this.rowSelected = false,
    this.child,
  }) : assert(rowIndex != null), super(key: key);

  final int rowIndex;
  final bool rowHighlighted;
  final bool rowSelected;
  final Widget child;

  static const List<Color> colors = <Color>[Colors.white, Color(0xfff7f5ee)];

  @override
  Widget build(BuildContext context) {
    Widget result = Padding(
      padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
      child: child,
    );

    if (!rowHighlighted && !rowSelected) {
      result = ColoredBox(
        color: colors[rowIndex % 2],
        child: result,
      );
    }

    return result;
  }
}

class ExpenseReports extends StatelessWidget {
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
            child: pivot.LinkButton(
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
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black),
                            child: Table(
                              columnWidths: {
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Program:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Orbital Sciences')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Charge number:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4), child: Text('123')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4), child: Text('Dates:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('2015-10-12 to 2015-10-25')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Purpose of travel:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('None of your business')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Destination (city):')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Vancouver')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4, right: 6),
                                        child: Text('Party or parties visited:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4), child: Text('Jimbo')),
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
                              pivot.LinkButton(
                                image: AssetImage('assets/money_add.png'),
                                text: 'Add expense line item',
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: const Color(0xff999999),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(1),
                            child: ExpensesTableView(),
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

class ExpensesTableView extends StatefulWidget {
  @override
  _ExpensesTableViewState createState() => _ExpensesTableViewState();
}

class _ExpensesTableViewState extends State<ExpensesTableView> {
  pivot.TableViewSelectionController _selectionController;
  pivot.TableViewSortController _sortController;
  pivot.TableViewEditorController _editorcontroller;

  final List<List<String>> data = [
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

  static final intl.DateFormat dateFormat = intl.DateFormat('yyyy-MM-dd');

  pivot.TableHeaderRenderer _renderHeader(String name) {
    return ({
      BuildContext context,
      int columnIndex,
    }) {
      return Text(
        name,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
      );
    };
  }

  Widget _renderDate({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String date = data[rowIndex][0];
    final DateTime dateTime = DateTime.parse(date);
    final String formattedDate = dateFormat.format(dateTime);
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        formattedDate,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  Widget _renderType({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String type = data[rowIndex][1];
    if (isEditing) {
      return _renderTypeEditor(type);
    }
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        type,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  Widget _renderTypeEditor(String type) {
    return pivot.PushButton<String>(
      onPressed: () {},
      label: type,
      menuItems: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'type1',
          height: 22,
          child: Text('Another type'),
        ),
        PopupMenuItem<String>(
          value: 'type2',
          height: 22,
          child: Text('Yet another type'),
        ),
      ],
      onMenuItemSelected: (String value) {
      },
    );
  }

  Widget _renderAmount({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String amount = data[rowIndex][2];
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        amount,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  Widget _renderDescription({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String description = data[rowIndex][3];
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        description,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectionController = pivot.TableViewSelectionController(selectMode: pivot.SelectMode.multi);
    _sortController = pivot.TableViewSortController(sortMode: pivot.TableViewSortMode.singleColumn);
    _editorcontroller = pivot.TableViewEditorController();
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _sortController.dispose();
    _editorcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pivot.ScrollableTableView(
      rowHeight: 19,
      length: data.length,
      selectionController: _selectionController,
      sortController: _sortController,
      editorController: _editorcontroller,
      roundColumnWidthsToWholePixel: false,
      columns: <pivot.TableColumnController>[
        pivot.TableColumnController(
          key: 'date',
          width: pivot.ConstrainedTableColumnWidth(width: 120),
          cellRenderer: _renderDate,
          headerRenderer: _renderHeader('Date'),
        ),
        pivot.TableColumnController(
          key: 'type',
          width: pivot.FixedTableColumnWidth(120),
          cellRenderer: _renderType,
          headerRenderer: _renderHeader('Type'),
        ),
        pivot.TableColumnController(
          key: 'amount',
          width: pivot.FixedTableColumnWidth(100),
          cellRenderer: _renderAmount,
          headerRenderer: _renderHeader('Amount'),
        ),
        pivot.TableColumnController(
          key: 'description',
          width: pivot.FlexTableColumnWidth(),
          cellRenderer: _renderDescription,
          headerRenderer: _renderHeader('Description'),
        ),
      ],
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
