import 'dart:math' as math;

import 'package:chicago/chicago.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter/widgets.dart' hide TableCell, TableRow;

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/widgets/text_input_validators.dart';

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
  late FocusNode _focusNode;

  static final GlobalKey _key = GlobalKey();

  _TimesheetRow _buildTimesheetRow(Timesheet timesheet) => _TimesheetRow(timesheet: timesheet);

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

  void _handleRawKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _traverseFocus(TraversalDirection.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _traverseFocus(TraversalDirection.down);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _traverseFocus(TraversalDirection.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _traverseFocus(TraversalDirection.right);
      }
    }
  }

  void _traverseFocus(TraversalDirection direction) {
    final FocusNode? primaryFocus = FocusManager.instance.primaryFocus;
    assert(primaryFocus != null);
    primaryFocus!.focusInDirection(direction);
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
    _focusNode = FocusNode(canRequestFocus: false);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
    _focusNode.dispose();
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
            child: ActionLinkButton(
              image: AssetImage('assets/table_add.png'),
              text: 'Add hours line item',
              intent: AddTimesheetIntent(context: context),
            ),
          ),
          if (_timesheetRows.isNotEmpty) Expanded(
            child: ScrollPane(
              horizontalScrollBarPolicy: ScrollBarPolicy.expand,
              view: Padding(
                padding: const EdgeInsets.only(left: 20, right: 25),
                child: RawKeyboardListener(
                  focusNode: _focusNode,
                  onKey: _handleRawKeyEvent,
                  child: FocusTraversalGroup(
                    policy: _TimesheetTraversalPolicy(key: _key),
                    child: TablePane(
                      key: _key,
                      horizontalIntrinsicSize: MainAxisSize.min,
                      horizontalSpacing: 1,
                      verticalSpacing: 1,
                      columns: const <TablePaneColumn>[
                        TablePaneColumn(width: IntrinsicTablePaneColumnWidth()),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: FixedTablePaneColumnWidth(32)),
                        TablePaneColumn(width: IntrinsicTablePaneColumnWidth()),
                        TablePaneColumn(width: RelativeTablePaneColumnWidth()),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _TimesheetTraversalPolicy extends FocusTraversalPolicy {
  const _TimesheetTraversalPolicy({required this.key});

  final GlobalKey key;

  static const int rowOffset = 1;
  static const int columnOffset = 1;

  static Element? _childAt(Element parent, int index) {
    Element? result;
    int i = -1;
    parent.visitChildren((Element element) {
      i++;
      if (i == index) {
        assert(result == null);
        result = element;
      }
    });
    return result;
  }

  FocusNode? findFocusAtLocation(int timesheetIndex, int hoursIndex) {
    if (key.currentContext == null) {
      return null;
    }
    assert(timesheetIndex >= 0);
    assert(hoursIndex >= 0);
    final Invoice invoice = InvoiceBinding.instance!.invoice!;
    if (timesheetIndex >= invoice.timesheets.length ||
        hoursIndex >= invoice.timesheets[timesheetIndex].hours.length) {
      return null;
    }
    final TablePaneElement tablePaneElement = TablePane.of(key.currentContext!)!;
    final _TimesheetRowElement timesheetRowElement = _childAt(tablePaneElement, timesheetIndex + rowOffset) as _TimesheetRowElement;
    final _TimesheetScopeElement timesheetScopeElement = timesheetRowElement._child as _TimesheetScopeElement;
    final TableRowElement tableRowElement = timesheetScopeElement._child as TableRowElement;
    final StatefulElement hoursElement = _childAt(tableRowElement, hoursIndex + columnOffset) as StatefulElement;
    final _HoursInputState hoursState = hoursElement.state as _HoursInputState;
    return hoursState._focusNode;
  }

  @override
  bool inDirection(FocusNode focus, TraversalDirection direction) {
    final BuildContext? focusContext = focus.context;
    if (focusContext == null) {
      return false;
    }
    final Timesheet? timesheet = _TimesheetRow.of(focusContext);
    if (timesheet == null) {
      return false;
    }
    int timesheetIndex = timesheet.index;
    _HoursInputState? hoursInputState = _HoursInput.of(focusContext);
    int hoursIndex = hoursInputState?.widget.hoursIndex ?? -1;
    switch (direction) {
      case TraversalDirection.up:
        timesheetIndex--;
        break;
      case TraversalDirection.down:
        timesheetIndex++;
        break;
      case TraversalDirection.left:
        hoursIndex--;
        break;
      case TraversalDirection.right:
        hoursIndex++;
        break;
    }
    if (timesheetIndex < 0 || hoursIndex < 0) {
      return false;
    }
    final FocusNode? newFocusNode = findFocusAtLocation(timesheetIndex, hoursIndex);
    if (newFocusNode == null) {
      return false;
    }
    newFocusNode.requestFocus();
    return true;
  }

  @override
  FocusNode? findFirstFocusInDirection(FocusNode currentNode, TraversalDirection direction) {
    switch (direction) {
      case TraversalDirection.up:
      case TraversalDirection.left:
        final Invoice invoice = InvoiceBinding.instance!.invoice!;
        final int timesheetIndex = invoice.timesheets.length - 1;
        final int hoursIndex = invoice.timesheets[timesheetIndex].hours.length - 1;
        return findFocusAtLocation(timesheetIndex, hoursIndex);
      case TraversalDirection.down:
      case TraversalDirection.right:
        return findFocusAtLocation(0, 0);
    }
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    return descendants;
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
    return TableRow(
      children: <Widget>[
        const EmptyTableCell(),
        ..._buildDateHeadings(),
        const EmptyTableCell(),
        const EmptyTableCell(),
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

  static _HoursInputState? of(BuildContext context) {
    _HoursInputScope? scope = context.dependOnInheritedWidgetOfExactType<_HoursInputScope>();
    return scope == null ? null : scope.state;
  }
}

class _HoursInputState extends State<_HoursInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  void _handleEdit(String text) {
    widget.hours[widget.hoursIndex] = text.isEmpty ? 0 : double.parse(text);
  }

  @override
  void initState() {
    super.initState();
    final double initialValue = widget.hours[widget.hoursIndex];
    final String text = initialValue == 0 ? '' : NumberFormats.maybeDecimal.format(initialValue);
    _controller = TextEditingController(text: text);
    _focusNode = FocusNode(descendantsAreFocusable: false);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
    return _HoursInputScope(
      state: this,
      updateCount: 0, // TODO
      child: TextInput(
        controller: _controller,
        focusNode: _focusNode,
        onTextUpdated: _handleEdit,
        validator: TextInputValidators.validateHoursInDay,
        backgroundColor: widget.isWeekend ? const Color(0xffdddcd5) : const Color(0xffffffff),
        enabled: widget.enabled,
      ),
    );
  }
}

class _HoursInputScope extends InheritedWidget {
  const _HoursInputScope({
    Key? key,
    required this.state,
    required this.updateCount,
    required Widget child,
  }) : super(key: key, child: child);

  final _HoursInputState state;
  final int updateCount;

  @override
  bool updateShouldNotify(_HoursInputScope old) {
    return updateCount != old.updateCount;
  }
}

class _TimesheetRow extends StatefulWidget {
  const _TimesheetRow({
    Key? key,
    required this.timesheet,
  }) : super(key: key);

  final Timesheet timesheet;

  @override
  StatefulElement createElement() => _TimesheetRowElement(this);

  @override
  State<StatefulWidget> createState() => _TimesheetRowState();

  static Timesheet? of(BuildContext context) {
    _TimesheetScope? scope = context.dependOnInheritedWidgetOfExactType<_TimesheetScope>();
    return scope?.state.widget.timesheet;
  }
}

class _TimesheetRowElement extends StatefulElement {
  _TimesheetRowElement(StatefulWidget widget) : super(widget);

  Element? _child;

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    return _child = super.updateChild(child, newWidget, newSlot);
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
      return TableRow(
        height: IntrinsicTablePaneRowHeight(),
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
          const EmptyTableCell(),
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
  InheritedElement createElement() => _TimesheetScopeElement(this);

  @override
  bool updateShouldNotify(_TimesheetScope old) {
    return updateCount != old.updateCount;
  }
}

class _TimesheetScopeElement extends InheritedElement {
  _TimesheetScopeElement(InheritedWidget widget) : super(widget);

  Element? _child;

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    return _child = super.updateChild(child, newWidget, newSlot);
  }
}

class _TimesheetHeader extends StatelessWidget {
  const _TimesheetHeader({Key? key}) : super(key: key);

  static Widget _buildHeader(BuildContext context, bool hover) {
    final Timesheet timesheet = _TimesheetRow.of(context)!;
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
        SizedBox(
          width: 24,
          height: 22,
          child: Opacity(
            opacity: hover ? 1 : 0,
            child: ActionPushButton(
              intent: EditTimesheetIntent(timesheet),
              padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
              icon: 'assets/pencil.png',
              showTooltip: false,
              isToolbar: true,
              isFocusable: false,
            ),
          ),
        ),
        SizedBox(
          width: 24,
          height: 22,
          child: Opacity(
            opacity: hover ? 1 : 0,
            child: ActionPushButton(
              intent: DeleteTimesheetIntent(timesheet),
              padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
              icon: 'assets/cross.png',
              showTooltip: false,
              isToolbar: true,
              isFocusable: false,
            ),
          ),
        ),
        const SizedBox(width: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HoverBuilder(
      builder: _buildHeader,
    );
  }
}

class _TimesheetFooter extends StatelessWidget {
  const _TimesheetFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Timesheet timesheet = _TimesheetRow.of(context)!;
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
    return TableRow(
      height: const FixedTablePaneRowHeight(9),
      children: const <Widget>[
        TableCell(
          columnSpan: 128,
          child: Divider(
            thickness: 1,
            color: Color(0xff999999),
          ),
        ),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
        EmptyTableCell(),
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
    return _row ??= TableRow(
      children: [
        const Text('Daily Totals', maxLines: 1, style: TextStyle(fontStyle: FontStyle.italic)),
        ...List<Widget>.generate(InvoiceBinding.instance!.invoice!.billingPeriod.length, _toHours),
        const EmptyTableCell(),
        const EmptyTableCell(),
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
