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

class _TimesheetsViewState extends State<TimesheetsView> {
  InvoiceListener _listener;
  List<_TimesheetRow> _timesheetRows;

  _TimesheetRow _buildTimesheetRow(Timesheet timesheet) {
    return _TimesheetRow(
      timesheet: timesheet,
      child: pivot.TableRow(
        children: <Widget>[
          const _TimesheetHeader(),
          ...List<Widget>.generate(timesheet.hours.length, (int index) {
            return _HoursInput(
              hours: timesheet.hours,
              hoursIndex: index,
            );
          }),
          const _TimesheetFooter(),
          const pivot.EmptyTableCell(),
        ],
      ),
    );
  }

  void _handleTimesheetInserted(int index) {
    final Timesheet timesheet = InvoiceBinding.instance.invoice.timesheets[index];
    setState(() {
      _timesheetRows.insert(index, _buildTimesheetRow(timesheet));
    });
  }

  void _handleTimesheetsRemoved(int startIndex, Iterable<Timesheet> removed) {
    final int count = removed.length;
    final int endIndex = startIndex + count;
    setState(() {
      _timesheetRows.removeRange(startIndex, endIndex);
    });
  }

  Invoice get invoice {
    final Invoice invoice = InvoiceBinding.instance.invoice;
    assert(invoice != null);
    return invoice;
  }

  @override
  void initState() {
    super.initState();
    _listener = InvoiceListener(
      onTimesheetInserted: _handleTimesheetInserted,
      onTimesheetsRemoved: _handleTimesheetsRemoved,
    );
    InvoiceBinding.instance.addListener(_listener);
    _timesheetRows = invoice.timesheets.map<_TimesheetRow>(_buildTimesheetRow).toList();
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
                padding: const EdgeInsets.only(left: 20, right: 25),
                child: pivot.TablePane(
                  horizontalSize: MainAxisSize.min,
                  horizontalSpacing: 1,
                  verticalSpacing: 1,
                  columns: const <pivot.TablePaneColumn>[
                    pivot.TablePaneColumn(width: pivot.IntrinsicTablePaneColumnWidth()),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.FixedTablePaneColumnWidth(32)),
                    pivot.TablePaneColumn(width: pivot.IntrinsicTablePaneColumnWidth()),
                    pivot.TablePaneColumn(width: pivot.RelativeTablePaneColumnWidth()),
                  ],
                  children: <Widget>[
                    const _HeaderRow(),
                    ..._timesheetRows,
                    const _DividerRow(),
                    const _FooterRow(),
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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({Key key}) : super(key: key);

  Iterable<_DateHeading> _buildDateHeadings() {
    return InvoiceBinding.instance.invoice.billingPeriod
        .map<String>((DateTime date) => DateFormats.md.format(date))
        .map<_DateHeading>((String date) => _DateHeading(date));
  }

  @override
  Widget build(BuildContext context) {
    return pivot.TableRow(
      children: <Widget>[
        pivot.EmptyTableCell(),
        ..._buildDateHeadings(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
      ],
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
    return pivot.TextInput(
      controller: _controller,
      backgroundColor: widget.isWeekend ? const Color(0xffdddcd5) : const Color(0xffffffff),
    );
  }
}

class _TimesheetRow extends StatefulWidget {
  const _TimesheetRow({
    Key key,
    @required this.timesheet,
    @required this.child,
  }) : super(key: key);

  final Timesheet timesheet;
  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _TimesheetRowState();
  }

  static Timesheet of(BuildContext context) {
    _TimesheetScope scope = context.dependOnInheritedWidgetOfExactType<_TimesheetScope>();
    return scope.state.widget.timesheet;
  }
}

class _TimesheetRowState extends State<_TimesheetRow> {
  InvoiceListener _invoiceListener;
  int _updateCount = 0;

  void _handleTimesheetUpdated(int index, String key, dynamic previousValue) {
    if (InvoiceBinding.instance.invoice.timesheets[index] == widget.timesheet) {
      setState(() {
        _updateCount++;
      });
    }
  }

  void _handleTimesheetHoursUpdated(int index, int dayIndex, double previousHours) {
    if (InvoiceBinding.instance.invoice.timesheets[index] == widget.timesheet) {
      setState(() {
        _updateCount++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _invoiceListener = InvoiceListener(
      onTimesheetUpdated: _handleTimesheetUpdated,
      onTimesheetHoursUpdated: _handleTimesheetHoursUpdated,
    );
    InvoiceBinding.instance.addListener(_invoiceListener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance.removeListener(_invoiceListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _TimesheetScope(state: this, updateCount: _updateCount, child: widget.child);
  }
}

class _TimesheetScope extends InheritedWidget {
  const _TimesheetScope({
    Key key,
    this.state,
    this.updateCount,
    Widget child,
  }) : super(key: key, child: child);

  final _TimesheetRowState state;
  final int updateCount;

  @override
  bool updateShouldNotify(_TimesheetScope old) {
    return updateCount != old.updateCount;
  }
}

class _TimesheetHeader extends StatelessWidget {
  const _TimesheetHeader({Key key}) : super(key: key);

  void _handleEdit() {
    // TODO
  }

  void _handleDelete() {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    return pivot.HoverBuilder(
      builder: (BuildContext context, bool hover) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_TimesheetRow.of(context).name, maxLines: 1, softWrap: false),
                ),
              ),
            ),
            Opacity(
              opacity: hover ? 1 : 0,
              child: pivot.PushButton(
                padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
                icon: 'assets/pencil.png',
                showTooltip: false,
                isToolbar: true,
                onPressed: _handleEdit,
              ),
            ),
            Opacity(
              opacity: hover ? 1 : 0,
              child: pivot.PushButton(
                padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
                icon: 'assets/cross.png',
                showTooltip: false,
                isToolbar: true,
                onPressed: _handleDelete,
              ),
            ),
            const SizedBox(width: 1),
          ],
        );
      },
    );
  }
}

class _TimesheetFooter extends StatelessWidget {
  const _TimesheetFooter({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Timesheet timesheet = _TimesheetRow.of(context);
    final StringBuffer summary = StringBuffer()
      ..writeAll(<String>[
        '${NumberFormats.maybeDecimal.format(timesheet.totalHours)} hrs'
            ' @${NumberFormats.currency.format(timesheet.program.rate)}/hr',
        ' (${NumberFormats.currency.format(timesheet.total)})',
      ]);

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(summary.toString(), maxLines: 1, softWrap: false),
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return pivot.TableRow(
      height: pivot.FixedTablePaneRowHeight(1),
      children: const <Widget>[
        pivot.TableCell(
          columnSpan: 128,
          child: Divider(
            thickness: 1,
            color: Color(0xff999999),
          ),
        ),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
        pivot.EmptyTableCell(),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return pivot.TableRow(
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
    );
  }
}
