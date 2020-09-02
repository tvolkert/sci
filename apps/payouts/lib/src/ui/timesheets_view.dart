import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';

import 'package:payouts/src/pivot.dart' as pivot;

import 'rotated_text.dart';

class TimesheetsView extends StatefulWidget {
  const TimesheetsView({Key key}) : super(key: key);

  @override
  _TimesheetsViewState createState() => _TimesheetsViewState();
}

class _TimesheetNotifier with ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class _TimesheetsViewState extends State<TimesheetsView> {
  InvoiceListener _listener;
  List<_TimesheetNotifier> _notifiers;
  List<TableRow> _timesheetRows;

  Iterable<_DateHeading> _dateHeadingsFromBillingPeriod() {
    return InvoiceBinding.instance.invoice.billingPeriod
        .map<String>((DateTime date) => DateFormats.md.format(date))
        .map<_DateHeading>((String date) => _DateHeading(date));
  }

  TableRow _buildTimesheetRow(Timesheet timesheet, _TimesheetNotifier notifier) {
    return TableRow(
      children: <Widget>[
        _TimesheetHeader(timesheet: timesheet, notifier: notifier),
        ...List<Widget>.generate(timesheet.hours.length, (int index) {
          return _HoursInput(
            hours: timesheet.hours,
            hoursIndex: index,
          );
        }),
        _TimesheetFooter(timesheet: timesheet, notifier: notifier),
        Container(),
      ],
    );
  }

  void _handleTimesheetInserted(int timesheetIndex) {
    final Timesheet timesheet = InvoiceBinding.instance.invoice.timesheets[timesheetIndex];
    final _TimesheetNotifier notifier = _TimesheetNotifier();
    _notifiers.insert(timesheetIndex, notifier);
    setState(() {
      _timesheetRows.insert(timesheetIndex, _buildTimesheetRow(timesheet, notifier));
    });
  }

  void _handleTimesheetsRemoved(int startIndex, Iterable<Timesheet> removed) {
    final int count = removed.length;
    final int endIndex = startIndex + count;
    for (int i = startIndex; i < endIndex; i++) _notifiers[i].dispose();
    _notifiers.removeRange(startIndex, endIndex);
    setState(() {
      _timesheetRows.removeRange(startIndex, endIndex);
    });
  }

  void _handleTimesheetUpdated(int timesheetIndex, String key, dynamic oldValue) {
    _notifiers[timesheetIndex].notify();
  }

  void _handleTimesheetHoursUpdated(int timesheetIndex, int dayIndex, double oldValue) {
    _notifiers[timesheetIndex].notify();
  }

  @override
  void initState() {
    super.initState();
    _listener = InvoiceListener(
      onTimesheetInserted: _handleTimesheetInserted,
      onTimesheetsRemoved: _handleTimesheetsRemoved,
      onTimesheetUpdated: _handleTimesheetUpdated,
      onTimesheetHoursUpdated: _handleTimesheetHoursUpdated,
    );
    InvoiceBinding.instance.addListener(_listener);
    final Invoice invoice = InvoiceBinding.instance.invoice;
    assert(invoice != null);
    _notifiers = List<_TimesheetNotifier>.generate(invoice.timesheets.length, (int index) {
      return _TimesheetNotifier();
    });
    _timesheetRows = List<TableRow>.generate(invoice.timesheets.length, (int index) {
      return _buildTimesheetRow(invoice.timesheets[index], _notifiers[index]);
    });
  }

  @override
  void dispose() {
    InvoiceBinding.instance.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7),
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
                  defaultColumnWidth: FixedColumnWidth(33),
                  textBaseline: TextBaseline.alphabetic,
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
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
                    ..._timesheetRows,
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

class _DateHeading extends StatelessWidget {
  const _DateHeading(this.text) : assert(text != null);

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

class _HoursInput extends StatefulWidget {
  const _HoursInput({
    Key key,
    this.hours,
    this.hoursIndex,
    this.isWeekend = false,
  }) : super(key: key);

  final Hours hours;
  final int hoursIndex;
  final bool isWeekend;

  @override
  _HoursInputState createState() => _HoursInputState();
}

class _HoursInputState extends State<_HoursInput> {
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
    } else if (text.contains('.')) {
      final String afterDecimal = text.substring(text.indexOf('.') + 1);
      assert(!afterDecimal.contains('.'));
      if (afterDecimal.length > 2) {
        valid = false;
      }
    }

    if (valid) {
      _lastValidValue = _controller.value;
      widget.hours[widget.hoursIndex] = value;
    } else {
      _controller.value = _lastValidValue;
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void initState() {
    super.initState();
    final double initialValue = widget.hours[widget.hoursIndex];
    final String text = initialValue == 0 ? '' : NumberFormats.maybeDecimal.format(initialValue);
    _controller = TextEditingController(text: text);
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
      child: pivot.TextInput(
        controller: _controller,
        backgroundColor: widget.isWeekend ? const Color(0xffdddcd5) : const Color(0xffffffff),
      ),
    );
  }
}

class _TimesheetHeader extends StatefulWidget {
  const _TimesheetHeader({
    Key key,
    @required this.timesheet,
    @required this.notifier,
  }) : super(key: key);

  final Timesheet timesheet;
  final _TimesheetNotifier notifier;

  @override
  _TimesheetHeaderState createState() => _TimesheetHeaderState();
}

class _TimesheetHeaderState extends State<_TimesheetHeader> {
  void _handleNeedsBuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_handleNeedsBuild);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_handleNeedsBuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pivot.HoverBuilder(
      builder: (BuildContext context, bool hover) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(widget.timesheet.name, maxLines: 1, softWrap: false),
              ),
            ),
            Baseline(
              baseline: 18.5,
              baselineType: TextBaseline.alphabetic,
              child: Opacity(
                opacity: hover ? 1 : 0,
                child: pivot.PushButton(
                  padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
                  icon: 'assets/pencil.png',
                  showTooltip: false,
                  isToolbar: true,
                  onPressed: () {},
                ),
              ),
            ),
            Baseline(
              baseline: 18.5,
              baselineType: TextBaseline.alphabetic,
              child: Opacity(
                opacity: hover ? 1 : 0,
                child: pivot.PushButton(
                  padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
                  icon: 'assets/cross.png',
                  showTooltip: false,
                  isToolbar: true,
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(width: 1),
          ],
        );
      },
    );
  }
}

class _TimesheetFooter extends StatefulWidget {
  const _TimesheetFooter({
    Key key,
    @required this.timesheet,
    @required this.notifier,
  }) : super(key: key);

  final Timesheet timesheet;
  final _TimesheetNotifier notifier;

  @override
  _TimesheetFooterState createState() => _TimesheetFooterState();
}

class _TimesheetFooterState extends State<_TimesheetFooter> {
  void _handleNeedsBuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_handleNeedsBuild);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_handleNeedsBuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StringBuffer summary = StringBuffer()
      ..writeAll(<String>[
        '${widget.timesheet.totalHours} hrs',
        ' @${NumberFormats.currency.format(widget.timesheet.program.rate)}/hr',
        ' (${NumberFormats.currency.format(widget.timesheet.total)})',
      ]);

    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Text(summary.toString(), maxLines: 1, softWrap: false),
    );
  }
}
