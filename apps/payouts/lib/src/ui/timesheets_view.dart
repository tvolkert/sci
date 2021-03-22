import 'dart:math' as math;

import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';

import 'rotated_text.dart';

class TimesheetsView extends StatelessWidget {
  const TimesheetsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        AddTimesheetIntent: AddTimesheetAction.instance,
        EditTimesheetIntent: EditTimesheetAction.instance,
        DeleteTimesheetIntent: DeleteTimesheetAction.instance,
      },
      child: const _RawTimesheetsView(),
    );
  }
}

class _RawTimesheetsView extends StatefulWidget {
  const _RawTimesheetsView({Key? key}) : super(key: key);

  @override
  _RawTimesheetsViewState createState() => _RawTimesheetsViewState();
}

class _RawTimesheetsViewState extends State<_RawTimesheetsView> {
  late InvoiceListener _listener;
  late List<_TimesheetRow> _timesheetRows;

  _TimesheetRow _buildTimesheetRow(Timesheet timesheet) {
    return _TimesheetRow(timesheet: timesheet);
  }

  void _initTimesheetRows() {
    setState(() {
      _timesheetRows = invoice.timesheets.map<_TimesheetRow>(_buildTimesheetRow).toList();
    });
  }

  void _handleInvoiceOpened(Invoice? oldInvoice) {
    _initTimesheetRows();
  }

  void _handleTimesheetInserted(int index) {
    setState(() {
      _timesheetRows.insert(index, _buildTimesheetRow(invoice.timesheets[index]));
    });
  }

  void _handleTimesheetsRemoved(int startIndex, Iterable<Timesheet> removed) {
    setState(() {
      _timesheetRows.removeRange(startIndex, startIndex + removed.length);
    });
  }

  Invoice get invoice => InvoiceBinding.instance!.invoice!;

  @override
  void initState() {
    super.initState();
    _listener = InvoiceListener(
      onInvoiceOpened: _handleInvoiceOpened,
      onTimesheetInserted: _handleTimesheetInserted,
      onTimesheetsRemoved: _handleTimesheetsRemoved,
    );
    InvoiceBinding.instance!.addListener(_listener);
    _initTimesheetRows();
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
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
            child: chicago.ActionLinkButton(
              image: AssetImage('assets/table_add.png'),
              text: 'Add hours line item',
              intent: AddTimesheetIntent(context: context),
            ),
          ),
          if (_timesheetRows.isNotEmpty) Expanded(
            child: chicago.ScrollPane(
              horizontalScrollBarPolicy: chicago.ScrollBarPolicy.expand,
              view: Padding(
                padding: const EdgeInsets.only(left: 20, right: 25),
                child: chicago.TablePane(
                  horizontalIntrinsicSize: MainAxisSize.min,
                  horizontalSpacing: 1,
                  verticalSpacing: 1,
                  columns: const <chicago.TablePaneColumn>[
                    chicago.TablePaneColumn(width: chicago.IntrinsicTablePaneColumnWidth()),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.FixedTablePaneColumnWidth(32)),
                    chicago.TablePaneColumn(width: chicago.IntrinsicTablePaneColumnWidth()),
                    chicago.TablePaneColumn(width: chicago.RelativeTablePaneColumnWidth()),
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
  const _HeaderRow({Key? key}) : super(key: key);

  Iterable<_DateHeading> _buildDateHeadings() {
    return InvoiceBinding.instance!.invoice!.billingPeriod
        .map<String>((DateTime date) => DateFormats.md.format(date))
        .map<_DateHeading>((String date) => _DateHeading(date));
  }

  @override
  Widget build(BuildContext context) {
    return chicago.TableRow(
      children: <Widget>[
        const chicago.EmptyTableCell(),
        ..._buildDateHeadings(),
        const chicago.EmptyTableCell(),
        const chicago.EmptyTableCell(),
      ],
    );
  }
}

class _DateHeading extends StatelessWidget {
  const _DateHeading(this.text);

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
    Key? key,
    required this.hours,
    required this.hoursIndex,
    this.isWeekend = false,
    this.enabled = true,
  }) : super(key: key);

  final Hours hours;
  final int hoursIndex;
  final bool isWeekend;
  final bool enabled;

  @override
  _HoursInputState createState() => _HoursInputState();
}

class _HoursInputState extends State<_HoursInput> {
  late TextEditingController _controller;
  late TextEditingValue _lastValidValue;

  void _handleEdit() {
    final String text = _controller.text;
    if (text == _lastValidValue.text) {
      // Shortcut to trivial success
      _lastValidValue = _controller.value;
      return;
    }

    bool valid = true;
    double? value = text.isEmpty ? 0 : double.tryParse(text);

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
      widget.hours[widget.hoursIndex] = value!;
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
    _lastValidValue = _controller.value;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleEdit);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _HoursInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hours != oldWidget.hours || widget.hoursIndex != oldWidget.hoursIndex) {
      final double newValue = widget.hours[widget.hoursIndex];
      final String text = newValue == 0 ? '' : NumberFormats.maybeDecimal.format(newValue);
      _controller.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return chicago.TextInput(
      controller: _controller,
      backgroundColor: widget.isWeekend ? const Color(0xffdddcd5) : const Color(0xffffffff),
      enabled: widget.enabled,
    );
  }
}

class _TimesheetRow extends StatefulWidget {
  const _TimesheetRow({
    Key? key,
    required this.timesheet,
  }) : super(key: key);

  final Timesheet timesheet;

  @override
  State<StatefulWidget> createState() => _TimesheetRowState();

  static Timesheet of(BuildContext context) {
    _TimesheetScope scope = context.dependOnInheritedWidgetOfExactType<_TimesheetScope>()!;
    return scope.state.widget.timesheet;
  }
}

class _TimesheetRowState extends State<_TimesheetRow> {
  late InvoiceListener _invoiceListener;
  int _updateCount = 0;

  void _handleTimesheetUpdated(int index, String key, dynamic previousValue) {
    if (InvoiceBinding.instance!.invoice!.timesheets[index] == widget.timesheet) {
      setState(() {
        _updateCount++;
      });
    }
  }

  void _handleTimesheetHoursUpdated(int index, int dayIndex, double previousHours) {
    if (InvoiceBinding.instance!.invoice!.timesheets[index] == widget.timesheet) {
      setState(() {
        _updateCount++;
      });
    }
  }

  Widget? _tableRow;
  Widget _buildTableRow() {
    return _tableRow ??= () {
      final bool isSubmitted = InvoiceBinding.instance!.invoice!.isSubmitted;
      return chicago.TableRow(
        height: chicago.IntrinsicTablePaneRowHeight(),
        children: <Widget>[
          const _TimesheetHeader(),
          ...List<Widget>.generate(widget.timesheet.hours.length, (int index) {
            return _HoursInput(
              hours: widget.timesheet.hours,
              hoursIndex: index,
              isWeekend: InvoiceBinding.instance!.invoice!.billingPeriod[index].weekday > 5,
              enabled: !isSubmitted,
            );
          }),
          const _TimesheetFooter(),
          const chicago.EmptyTableCell(),
        ],
      );
    }();
  }

  @override
  void initState() {
    super.initState();
    _invoiceListener = InvoiceListener(
      onTimesheetUpdated: _handleTimesheetUpdated,
      onTimesheetHoursUpdated: _handleTimesheetHoursUpdated,
    );
    InvoiceBinding.instance!.addListener(_invoiceListener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_invoiceListener);
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    setState(() {
      _tableRow = null;
    });
  }

  @override
  void didUpdateWidget(covariant _TimesheetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timesheet != oldWidget.timesheet) {
      setState(() {
        _tableRow = null;
        _updateCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TimesheetScope(
      state: this,
      updateCount: _updateCount,
      child: _buildTableRow(),
    );
  }
}

class _TimesheetScope extends InheritedWidget {
  const _TimesheetScope({
    Key? key,
    required this.state,
    required this.updateCount,
    required Widget child,
  }) : super(key: key, child: child);

  final _TimesheetRowState state;
  final int updateCount;

  @override
  bool updateShouldNotify(_TimesheetScope old) {
    return updateCount != old.updateCount;
  }
}

class _TimesheetHeader extends StatelessWidget {
  const _TimesheetHeader({Key? key}) : super(key: key);

  static Widget _buildHeader(BuildContext context, bool hover) {
    final Timesheet timesheet = _TimesheetRow.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(timesheet.name, maxLines: 1, softWrap: false),
            ),
          ),
        ),
        Opacity(
          opacity: hover ? 1 : 0,
          child: chicago.ActionPushButton(
            intent: EditTimesheetIntent(timesheet),
            padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
            icon: 'assets/pencil.png',
            showTooltip: false,
            isToolbar: true,
          ),
        ),
        Opacity(
          opacity: hover ? 1 : 0,
          child: chicago.ActionPushButton(
            intent: DeleteTimesheetIntent(timesheet),
            padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
            icon: 'assets/cross.png',
            showTooltip: false,
            isToolbar: true,
          ),
        ),
        const SizedBox(width: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const chicago.HoverBuilder(
      builder: _buildHeader,
    );
  }
}

class _TimesheetFooter extends StatelessWidget {
  const _TimesheetFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Timesheet timesheet = _TimesheetRow.of(context);
    final StringBuffer summary = StringBuffer()
      ..writeAll(<String>[
        '${NumberFormats.maybeDecimal.format(timesheet.totalHours)} hrs',
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
  const _DividerRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chicago.TableRow(
      height: const chicago.FixedTablePaneRowHeight(9),
      children: const <Widget>[
        chicago.TableCell(
          columnSpan: 128,
          child: Divider(
            thickness: 1,
            color: Color(0xff999999),
          ),
        ),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
        chicago.EmptyTableCell(),
      ],
    );
  }
}

class _FooterRow extends StatefulWidget {
  const _FooterRow({Key? key}) : super(key: key);

  @override
  _FooterRowState createState() => _FooterRowState();
}

double _sum(double a, double b) => a + b;

class _FooterRowState extends State<_FooterRow> {
  late InvoiceListener _invoiceListener;
  Widget? _row;

  void _handleTimesheetsRemoved(int timesheetsIndex, Iterable<Timesheet> removed) {
    _markRowNeedsBuilding();
  }

  void _handleTimesheetUpdated(int index, String key, dynamic previousValue) {
    if (key == Keys.rate) {
      _markRowNeedsBuilding();
    }
  }

  void _handleTimesheetHoursUpdated(int index, int dayIndex, double previousHours) {
    _markRowNeedsBuilding();
  }

  double _computeTotalHoursForDay(int index) {
    return InvoiceBinding.instance!.invoice!.timesheets
        .map<double>((Timesheet timesheet) => timesheet.hours[index])
        .fold<double>(0, _sum);
  }

  Widget _toHours(int index) {
    return _FooterHours(hours: _computeTotalHoursForDay(index));
  }

  void _markRowNeedsBuilding() {
    setState(() => _row = null);
  }

  @override
  void initState() {
    super.initState();
    _invoiceListener = InvoiceListener(
      onTimesheetsRemoved: _handleTimesheetsRemoved,
      onTimesheetUpdated: _handleTimesheetUpdated,
      onTimesheetHoursUpdated: _handleTimesheetHoursUpdated,
    );
    InvoiceBinding.instance!.addListener(_invoiceListener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_invoiceListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _row ??= chicago.TableRow(
      children: [
        const Text('Daily Totals', maxLines: 1, style: TextStyle(fontStyle: FontStyle.italic)),
        ...List<Widget>.generate(InvoiceBinding.instance!.invoice!.billingPeriod.length, _toHours),
        const chicago.EmptyTableCell(),
        const chicago.EmptyTableCell(),
      ],
    );
  }
}

class _FooterHours extends StatelessWidget {
  const _FooterHours({Key? key, required this.hours}) : super(key: key);

  final double hours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2),
      child: Text(
        hours == 0 ? '' : NumberFormats.maybeDecimal.format(hours),
        style: TextStyle(fontStyle: FontStyle.italic),
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
