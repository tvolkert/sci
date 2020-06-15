import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:payouts/expense_report_list_tile.dart';

import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_home.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details,
          {bool forceReport = false}) =>
      FlutterError.dumpErrorToConsole(details, forceReport: true);
  runApp(
//    Directionality(
//      textDirection: TextDirection.ltr,
//      child: Table(
//        children: <TableRow>[
//          TableRow(
//            children: <Widget>[
//              RotatedBox(
//                quarterTurns: 1,
//                child: Text('rotated so should be tall, not wide'),
//              ),
//            ],
//          ),
//        ],
//      ),
//    ),
//    Tmp(),

    PayoutsApp(),
  );
}

class Tmp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ColoredBox(
                color: Color(0x2200ff00),
                child: InkWell(
                  hoverColor: Colors.red,
                  child: Text('Hover'),
                  onTap: () {},
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: Color(0x220000ff),
                child: Text('No hover'),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            FlatButton(
              onPressed: () {},
              child: Column(
                children: [
                  Image(image: AssetImage('assets/document-new.png')),
                  Text('New Invoice'),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Column(
                children: [
                  Image(image: AssetImage('assets/document-open.png')),
                  Text('Open Invoice'),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Column(
                children: [
                  Image(image: AssetImage('assets/media-floppy.png')),
                  Text('Save to Server'),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Column(
                children: [
                  Image(image: AssetImage('assets/dialog-cancel.png')),
                  Text('Delete Invoice'),
                ],
              ),
            ),
            FlatButton(
              onPressed: null,
              child: Column(
                children: [
                  Image(image: AssetImage('assets/x-office-presentation.png')),
                  Text('Export to PDF'),
                ],
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: tabs.map((Tab tab) {
          if (tab.text == 'Billable Hours') {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(7),
                  child: LinkButton(
                    image: AssetImage('assets/table_add.png'),
                    text: 'Add hours line item',
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: EdgeInsets.only(left: 32, right: 32),
                        child: Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.baseline,
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
                            _buildRow(
                                'SCI - Overhead', r'47 hrs @$0.00/hr ($0.00)'),
                            _buildRow('BSS, NNV8-913197 (COSC) (123)',
                                r'1.21 hrs @$95.00/hr ($114.95)'),
                            _buildRow('Orbital Sciences (abc)',
                                r'5 hrs @$110.00/hr ($550.00)'),
                            _buildRow(
                                'Loral - T14R', r'0 hrs @$110.00/hr ($0.00)'),
                            _buildRow(
                                'Sirius FM 6', r'5 hrs @$120.00/hr ($600.00)'),
                            TableRow(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xff999999)))),
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
                                    maxLines: 1,
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic)),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('6',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('6',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('6',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('9.21',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('11',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('7',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('6',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 2),
                                  child: Text('7',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
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
                ),
              ],
            );
          } else if (tab.text == 'Expense Reports') {
            return Padding(
              padding: EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(7),
                    child: LinkButton(
                      image: AssetImage('assets/money_add.png'),
                      text: 'Add expense report',
                      onPressed: () {},
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Splitter(
                        axis: Axis.horizontal,
                        initialSplitRatio: 0.25,
                        primaryRegion: null,
                        before: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xFF999999)),
                          ),
                          child: ListView(
//                            itemExtent: 17,
                            shrinkWrap: true,
                            //padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            children: [
                              ListTile(
                                title: Text('Foo'),
                                hoverColor: Colors.red,
                                selected: true,
                                enabled: true,
                                onTap: () {},
                              ),
                              ListTile(
                                title: Text('Bar'),
                                hoverColor: Colors.red,
                                selected: false,
                                enabled: true,
                                onTap: () {},
                              ),
                              ExpenseReportListTile(
                                title: 'SCI - Overhead',
                                amount: 0,
                                hoverColor: Colors.red,
                                selected: true,
                                onTap: () {},
                              ),
                              ExpenseReportListTile(
                                title: 'Orbital Sciences (123)',
                                amount: 3136.63,
                                selected: true,
                                onTap: () {},
                              ),
//                              Row(
//                                children: [
//                                  Text('SCI - Overhead', maxLines: 1),
//                                  Expanded(child: Text(r'($0.00)', textAlign: TextAlign.right, maxLines: 1)),
//                                ],
//                              ),
//                              Row(
//                                children: [
//                                  Text('Orbital Sciences (123)', maxLines: 1),
//                                  Expanded(child: Text(r'($3,136.63)', textAlign: TextAlign.right, maxLines: 1)),
//                                ],
//                              ),
                            ],
                          ),
                        ),
                        after: DecoratedBox(
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF999999))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Table(
                                columnWidths: {
                                  0: IntrinsicColumnWidth(),
                                  1: FlexColumnWidth(),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text('Program:'),
                                      Text('Orbital Sciences'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('Charge number:'),
                                      Text('123'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('Dates:'),
                                      Text('2015-10-12 to 2015-10-25'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('Purpose of travel:'),
                                      Text('None of your business'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('Destination (city):'),
                                      Text('Vancouver'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('Party or parties visited:'),
                                      Text('Jimbo'),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  LinkButton(
                                    image: AssetImage('assets/money_add.png'),
                                    text: 'Add expense line item',
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              DataTable(
                                sortColumnIndex: 0,
                                columns: [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Type')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Description')),
                                ],
                                rows: [
                                  DataRow(
                                    cells: [
                                      DataCell(Text('2015-10-12')),
                                      DataCell(Text('Lodging')),
                                      DataCell(Text(r'$219.05')),
                                      DataCell(Text('Hotel')),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (tab.text == 'Accomplishments') {
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
                      padding: EdgeInsets.only(top: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BSS, NNV8-913197 (COSC)'),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(border: Border.all()),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  minLines: 10,
                                  maxLines: 20,
                                ),
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
          } else {
            return Padding(
              padding: EdgeInsets.all(6),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Volkert, Todd',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Invoice #FOO'),
                        Text('10/12/2015 - 10/25/2015'),
                        Text(r'$4,401.58'),
                        SizedBox(height: 20),
                        DefaultTextStyle.merge(
                          style: TextStyle(fontWeight: FontWeight.bold),
                          child: Row(
                            children: [
                              Expanded(child: Text('Billable Hours')),
                              Text(r'$1,264.95'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }).toList(),
      ),
    );
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
  final String text;

  Heading(this.text) : assert(text != null);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-6, 4),
      child: Transform.rotate(
        alignment: Alignment.bottomCenter,
        angle: math.pi / 6,
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
          children: <Widget>[
            if (widget.image != null)
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Image(image: widget.image),
              ),
            Text(
              widget.text,
              style: TextStyle(
                color: Color(0xff2b5580),
                decoration:
                    hover ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ResizeMode {
  splitRatio,
  primaryRegion,
}

enum PrimaryRegion {
  before,
  after,
}

class Splitter extends StatefulWidget {
  Splitter({
    Key key,
    @required this.before,
    @required this.after,
    @required this.axis,
    this.initialSplitRatio = 0.5,
    this.resizeMode,
    this.primaryRegion,
    this.locked,
  }) : super(key: key);

  final Widget before;
  final Widget after;
  final Axis axis;
  final double initialSplitRatio;
  final ResizeMode resizeMode;
  final PrimaryRegion primaryRegion;
  final bool locked;

  @override
  _SplitterState createState() => _SplitterState();
}

class _SplitterState extends State<Splitter> {
  double splitRatio;

  @override
  void initState() {
    super.initState();
    splitRatio = widget.initialSplitRatio;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.axis) {
      case Axis.horizontal:
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double split = constraints.maxWidth * splitRatio;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: split, child: widget.before),
                MouseRegion(
                  cursor: SystemMouseCursors.horizontalDoubleArrow,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    dragStartBehavior: DragStartBehavior.down,
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      final double newSplit = split + details.delta.dx;
                      final double newSplitRatio =
                          newSplit / context.size.width;
                      setState(() {
                        splitRatio = newSplitRatio;
                      });
                    },
                    child: SizedBox(
                      width: 6,
                      child: Container(),
                    ),
                  ),
                ),
                Expanded(child: widget.after),
              ],
            );
          },
        );
        break;
      case Axis.vertical:
        break;
    }
    return SizedBox.expand(
      key: widget.key,
      child: Row(
        children: [],
      ),
    );
  }
}
