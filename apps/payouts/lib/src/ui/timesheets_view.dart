import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';

import 'package:payouts/src/pivot.dart' as pivot;

import 'rotated_text.dart';

class TimesheetsView extends StatelessWidget {
  const TimesheetsView({Key key}) : super(key: key);

  Iterable<Heading> _dateHeadingsFromBillingPeriod() {
    return InvoiceBinding.instance.invoice.billingPeriod
        .map<String>((DateTime date) => DateFormats.md.format(date))
        .map<Heading>((String date) => Heading(date));
  }

  Iterable<TableRow> _buildTimesheetRows() {
    return InvoiceBinding.instance.invoice.timesheets.map<TableRow>(_buildTimesheetRow);
  }

  TableRow _buildTimesheetRow(Timesheet timesheet) {
    final StringBuffer summary = StringBuffer()
      ..writeAll(<String>[
        '${timesheet.totalHours} hrs',
        ' @${NumberFormats.currency.format(timesheet.program.rate)}/hr',
        ' (${NumberFormats.currency.format(timesheet.total)})',
      ]);

    return TableRow(
      children: <Widget>[
        TimesheetHeaderRow(assignment: timesheet.name),
        ...List<Widget>.generate(timesheet.hours.length, (int index) {
          return HoursTextInput(
            hours: timesheet.hours,
            index: index,
          );
        }),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(summary.toString(), maxLines: 1, softWrap: false),
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
                        ..._dateHeadingsFromBillingPeriod(),
                        Container(),
                        Container(),
                      ],
                    ),
                    ..._buildTimesheetRows(),
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

class HoursTextInput extends StatefulWidget {
  const HoursTextInput({
    Key key,
    this.hours,
    this.index,
    this.isWeekend = false,
  }) : super(key: key);

  final Hours hours;
  final int index;
  final bool isWeekend;

  @override
  _HoursTextInputState createState() => _HoursTextInputState();
}

class _HoursTextInputState extends State<HoursTextInput> {
  TextEditingController _controller;
  TextEditingValue _lastValidValue;

  void _handleEdit() {
    final String text = _controller.text;
    if (text == _lastValidValue?.text) {
      // Shortcut to trivial success
      _lastValidValue = _controller.value;
      return;
    }

    bool valid = true;
    double value = text.isEmpty ? 0 : double.tryParse(text);

    if (value == null) {
      valid = false;
    } else if (value < 0 || value > 24) {
      valid = false;
    }

    if (valid) {
      _lastValidValue = _controller.value;
      widget.hours[widget.index] = value;
    } else {
      _controller.value = _lastValidValue;
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void initState() {
    super.initState();
    final double initialValue = widget.hours[widget.index];
    _controller = TextEditingController(text: initialValue == 0 ? '' : '$initialValue');
    _controller.addListener(_handleEdit);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleEdit);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 1, 1),
      child: TextField(
        controller: _controller,
        cursorWidth: 1,
        cursorColor: Colors.black,
        style: TextStyle(fontFamily: 'Verdana', fontSize: 11),
        decoration: InputDecoration(
          fillColor: widget.isWeekend ? Color(0xffdddcd5) : Colors.white,
          hoverColor: widget.isWeekend ? Color(0xffdddcd5) : Colors.white,
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
