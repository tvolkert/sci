import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:payouts/src/pivot.dart' as pivot;

import 'rotated_text.dart';

class TimesheetsView extends StatelessWidget {
  const TimesheetsView({Key key}) : super(key: key);

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
