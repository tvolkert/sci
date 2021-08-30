import 'package:chicago/chicago.dart';
import 'package:flutter/material.dart' show Divider, Theme;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter/widgets.dart' hide TableRow;

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_expense_report_mixin.dart';
import 'package:payouts/src/model/track_expense_reports_mixin.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/widgets/expense_type_list_button.dart';
import 'package:payouts/src/widgets/text_input_validators.dart';

class ExpenseReportsView extends StatelessWidget {
  const ExpenseReportsView();

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        AddExpenseIntent: AddExpenseAction.instance,
        AddExpenseReportIntent: AddExpenseReportAction.instance,
      },
      child: const _RawExpenseReportsView(),
    );
  }
}

class _RawExpenseReportsView extends StatefulWidget {
  const _RawExpenseReportsView({Key? key}) : super(key: key);

  @override
  _RawExpenseReportsViewState createState() => _RawExpenseReportsViewState();
}

class _RawExpenseReportsViewState extends State<_RawExpenseReportsView>
    with TrackExpenseReportsMixin {
  late ListViewSelectionController _selectionController;
  ExpenseReports? _expenseReports;
  ExpenseReport? _selectedExpenseReport;

  void _handleSelectedExpenseReportChanged() {
    final int selectedIndex = _selectionController.selectedIndex;
    setState(() {
      _selectedExpenseReport = selectedIndex == -1 ? null : _expenseReports![selectedIndex];
    });
  }

  @override
  void onExpenseReportInserted() {
    super.onExpenseReportInserted();
    setState(() {
      _expenseReports = this.expenseReports;
    });
  }

  @override
  void onExpenseReportsRemoved() {
    super.onExpenseReportsRemoved();
    setState(() {
      _expenseReports = this.expenseReports;
      if (_expenseReports == null) {
        _selectionController.selectedIndex = -1;
      } else if (_selectionController.selectedIndex >= _expenseReports!.length) {
        _selectionController.selectedIndex = 0;
      }
    });
  }

  @override
  void onExpenseReportsChanged() {
    super.onExpenseReportsChanged();
    setState(() {
      _expenseReports = this.expenseReports;
      if (_expenseReports == null) {
        _selectionController.selectedIndex = -1;
        _selectedExpenseReport = null;
      } else {
        _selectionController.selectedIndex = 0;
        _selectedExpenseReport = _expenseReports![_selectionController.selectedIndex];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTrackingExpenseReports();
    _selectionController = ListViewSelectionController();
    _expenseReports = this.expenseReports;
    _selectionController.selectedIndex = _expenseReports == null ? -1 : 0;
    if (_expenseReports != null) {
      _selectedExpenseReport = _expenseReports![_selectionController.selectedIndex];
    }
    _selectionController.addListener(_handleSelectedExpenseReportChanged);
  }

  @override
  void dispose() {
    stopTrackingExpenseReports();
    _selectionController.removeListener(_handleSelectedExpenseReportChanged);
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ActionLinkButton(
            image: AssetImage('assets/money_add.png'),
            text: 'Add expense report',
            intent: AddExpenseReportIntent(context: context),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _ExpenseReportContainer(
              expenseReports: _expenseReports,
              selectedExpenseReport: _selectedExpenseReport,
              selectionController: _selectionController,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseReportContainer extends StatelessWidget {
  const _ExpenseReportContainer({
    required this.expenseReports,
    required this.selectedExpenseReport,
    required this.selectionController,
  });

  final ExpenseReports? expenseReports;
  final ExpenseReport? selectedExpenseReport;
  final ListViewSelectionController selectionController;

  @override
  Widget build(BuildContext context) {
    if (expenseReports == null) {
      return Container();
    } else {
      return SplitPane(
        orientation: Axis.horizontal,
        initialSplitRatio: 0.25,
        roundToWholePixel: true,
        resizePolicy: SplitPaneResizePolicy.maintainBeforeSplitSize,
        before: ExpenseReportsListView(
          expenseReports: expenseReports!,
          selectionController: selectionController,
        ),
        after: DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: Color(0xFF999999))),
          child: selectedExpenseReport == null
              ? Container()
              : ExpenseReportView(expenseReport: selectedExpenseReport!),
        ),
      );
    }
  }
}

class ExpenseReportView extends StatelessWidget {
  const ExpenseReportView({
    Key? key,
    required this.expenseReport,
  }) : super(key: key);

  final ExpenseReport expenseReport;

  TableRow _buildMetadataRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4, right: 6),
          child: Text('$title:'),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(value),
        ),
      ],
    );
  }

  String _buildDateRangeDisplay(DateRange dateRange) {
    StringBuffer buf = StringBuffer()
      ..write(CalendarDateFormat.iso8601.formatDateTime(dateRange.start))
      ..write(' to ')
      ..write(CalendarDateFormat.iso8601.formatDateTime(dateRange.end));
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(11, 11, 11, 9),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: const Color(0xff000000)),
            child: TablePane(
              columns: <TablePaneColumn>[
                TablePaneColumn(width: IntrinsicTablePaneColumnWidth()),
                TablePaneColumn(width: RelativeTablePaneColumnWidth()),
              ],
              children: <TableRow>[
                _buildMetadataRow('Program', expenseReport.program.name),
                if (expenseReport.chargeNumber.isNotEmpty)
                  _buildMetadataRow('Charge number', expenseReport.chargeNumber),
                if (expenseReport.requestor.isNotEmpty)
                  _buildMetadataRow('Requestor', expenseReport.requestor),
                if (expenseReport.task.isNotEmpty) _buildMetadataRow('Task', expenseReport.task),
                _buildMetadataRow('Dates', _buildDateRangeDisplay(expenseReport.period)),
                if (expenseReport.travelPurpose.isNotEmpty)
                  _buildMetadataRow('Purpose of travel', expenseReport.travelPurpose),
                if (expenseReport.travelDestination.isNotEmpty)
                  _buildMetadataRow('Destination (city)', expenseReport.travelDestination),
                if (expenseReport.travelParties.isNotEmpty)
                  _buildMetadataRow('Party or parties visited', expenseReport.travelParties),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 9, left: 11),
          child: Row(
            children: [
              ActionLinkButton(
                image: AssetImage('assets/money_add.png'),
                text: 'Add expense line item',
                intent: AddExpenseIntent(
                  context: context,
                  expenseReport: expenseReport,
                ),
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
            child: ColoredBox(
              color: const Color(0xffffffff),
              child: ExpensesTableView(expenseReport: expenseReport),
            ),
          ),
        ),
      ],
    );
  }
}

class ExpensesTableView extends StatefulWidget {
  ExpensesTableView({
    Key? key,
    required this.expenseReport,
  }) : super(key: key);

  final ExpenseReport expenseReport;

  @override
  _ExpensesTableViewState createState() => _ExpensesTableViewState();
}

class _ExpensesTableViewState extends State<ExpensesTableView>
    with TrackExpenseReportMixin, TrackInvoiceMixin {
  late TableViewSelectionController _selectionController;
  late TableViewSortController _sortController;
  late TableViewEditorController _editorController;
  late TableViewRowDisablerController _disabledController;
  late TableViewSortListener _sortListener;
  late TableViewEditorListener _editorListener;
  ExpenseTypeListButtonController? _expenseTypeController;
  CalendarSelectionController? _dateController;
  TextEditingController? _amountController;
  TextEditingController? _descriptionController;

  TableHeaderBuilder _renderHeader(String name) {
    return (
      BuildContext context,
      int columnIndex,
    ) {
      return Text(
        name,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
      );
    };
  }

  Widget _buildDate(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    final DateTime date = expenseReport.expenses[rowIndex].date;
    if (isEditing) {
      return _renderDateEditor(date);
    }
    final String formattedDate = DateFormats.iso8601Short.format(date);
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      isRowDisabled: isRowDisabled,
      content: formattedDate,
    );
  }

  Widget _renderDateEditor(DateTime dateTime) {
    return CalendarButton(
      format: CalendarDateFormat.iso8601,
      selectionController: _dateController,
    );
  }

  Widget _buildType(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    final ExpenseType type = expenseReport.expenses[rowIndex].type;
    if (isEditing) {
      return _renderTypeEditor(type);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      isRowDisabled: isRowDisabled,
      content: type.name,
    );
  }

  Widget _renderTypeEditor(ExpenseType type) {
    return ExpenseTypeListButton(
      expenseReport: expenseReport,
      controller: _expenseTypeController,
    );
  }

  Widget _buildAmount(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    final double amount = expenseReport.expenses[rowIndex].amount;
    if (isEditing) {
      return _buildAmountEditor(amount);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      isRowDisabled: isRowDisabled,
      content: NumberFormats.currency.format(amount),
    );
  }

  Widget _buildAmountEditor(double amount) {
    return TextInput(
      controller: _amountController,
      validator: TextInputValidators.validateCurrency,
      backgroundColor: const Color(0xfff7f5ee),
    );
  }

  Widget _buildDescription(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    final String description = expenseReport.expenses[rowIndex].description;
    if (isEditing) {
      return _buildDescriptionEditor(description);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      isRowDisabled: isRowDisabled,
      content: description,
    );
  }

  Widget _buildDescriptionEditor(String description) {
    return TextInput(
      controller: _descriptionController,
      backgroundColor: const Color(0xfff7f5ee),
    );
  }

  void _handleSortChanged(TableViewSortController controller) {
    assert(controller.length == 1);
    final String columnName = controller.keys.single;
    final SortDirection sortDirection = controller[columnName]!;
    setState(() {
      _selectionController.clearSelection();
      expenseReport.expenses.sort((Expense a, Expense b) {
        Comparable<dynamic> fieldA, fieldB;
        switch (columnName) {
          case Keys.date:
            fieldA = a.date;
            fieldB = b.date;
            break;
          case Keys.expenseType:
            fieldA = a.type;
            fieldB = b.type;
            break;
          case Keys.amount:
            fieldA = a.amount;
            fieldB = b.amount;
            break;
          case Keys.description:
            fieldA = a.description;
            fieldB = b.description;
            break;
          default:
            throw UnimplementedError();
        }
        final int result = fieldA.compareTo(fieldB);
        switch (sortDirection) {
          case SortDirection.ascending:
            return result;
          case SortDirection.descending:
            return result * -1;
        }
      });
    });
  }

  Expense _getExpenseBeingEdited(TableViewEditorController controller) {
    final Iterable<int> rowsBeingEdited = controller.cellsBeingEdited.rows;
    assert(rowsBeingEdited.length == 1);
    final int rowIndex = rowsBeingEdited.single;
    return expenseReport.expenses[rowIndex];
  }

  void _updateDisabledController() {
    _disabledController.filter = (int rowIndex) => openedInvoice.isSubmitted;
  }

  void _handleEditStarted(TableViewEditorController controller) {
    _expenseTypeController = ExpenseTypeListButtonController();
    _dateController = CalendarSelectionController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    final Expense expense = _getExpenseBeingEdited(controller);
    _expenseTypeController!.value = expense.type;
    _dateController!.value = CalendarDate.fromDateTime(expense.date);
    _amountController!.text = expense.amount.toString();
    _descriptionController!.text = expense.description;
  }

  Vote _handlePreviewEditFinished(TableViewEditorController controller) {
    return _amountController!.text.isEmpty ? Vote.deny : Vote.approve;
  }

  void _handleEditFinished(TableViewEditorController controller, TableViewEditOutcome outcome) {
    assert(_expenseTypeController != null);
    assert(_dateController != null);
    assert(_amountController != null);
    assert(_descriptionController != null);
    if (outcome == TableViewEditOutcome.saved) {
      final Expense expense = _getExpenseBeingEdited(controller);
      expense.type = _expenseTypeController!.value!;
      expense.date = _dateController!.value!.toDateTime();
      expense.amount = double.tryParse(_amountController!.text) ?? 0;
      expense.description = _descriptionController!.text;
    }
    SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      // Disposing of these synchronously will cause the cell editors to throw
      // when they're disposed, since the cell editors unregister listeners
      // from the controllers in their dispose() methods.
      _expenseTypeController!.dispose();
      _dateController!.dispose();
      _amountController!.dispose();
      _descriptionController!.dispose();
    });
  }

  KeyEventResult _handleKey(FocusNode focusNode, RawKeyEvent keyEvent) {
    if (_editorController.isEditing) {
      if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
        _editorController.save();
        return KeyEventResult.handled;
      } else if (keyEvent.logicalKey == LogicalKeyboardKey.escape) {
        _editorController.cancel();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    startTrackingExpenseReport(widget.expenseReport);
    startTrackingInvoiceActivity();
    _selectionController = TableViewSelectionController(selectMode: SelectMode.multi);
    _sortController = TableViewSortController(sortMode: TableViewSortMode.singleColumn);
    _editorController = TableViewEditorController();
    _disabledController = TableViewRowDisablerController();
    _updateDisabledController();
    _sortListener = TableViewSortListener(
      onChanged: _handleSortChanged,
    );
    _editorListener = TableViewEditorListener(
      onEditStarted: _handleEditStarted,
      onPreviewEditFinished: _handlePreviewEditFinished,
      onEditFinished: _handleEditFinished,
    );
    _sortController.addListener(_sortListener);
    _editorController.addListener(_editorListener);
  }

  @override
  void didUpdateWidget(ExpensesTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenseReport != oldWidget.expenseReport) {
      stopTrackingExpenseReport();
      startTrackingExpenseReport(widget.expenseReport);
      _selectionController.selectedIndex = -1;
    }
  }

  @override
  void dispose() {
    stopTrackingExpenseReport();
    stopTrackingInvoiceActivity();
    _sortController.removeListener(_sortListener);
    _editorController.removeListener(_editorListener);
    _selectionController.dispose();
    _sortController.dispose();
    _editorController.dispose();
    _disabledController.dispose();
    super.dispose();
  }

  @override
  void onExpensesChanged() {
    super.onExpensesChanged();
    setState(() {}); // State is held in the expense report itself.
  }

  @override
  void onInvoiceSubmittedChanged() {
    super.onInvoiceSubmittedChanged();
    _updateDisabledController();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKey: _handleKey,
      child: ScrollableTableView(
        rowHeight: 19,
        length: expenseReport.expenses.length,
        selectionController: _selectionController,
        sortController: _sortController,
        editorController: _editorController,
        rowDisabledController: _disabledController,
        roundColumnWidthsToWholePixel: false,
        columns: <TableColumn>[
          TableColumn(
            key: Keys.date,
            width: ConstrainedTableColumnWidth(width: 120, minWidth: 20),
            cellBuilder: _buildDate,
            headerBuilder: _renderHeader('Date'),
          ),
          TableColumn(
            key: Keys.expenseType,
            width: ConstrainedTableColumnWidth(width: 120, minWidth: 20),
            cellBuilder: _buildType,
            headerBuilder: _renderHeader('Type'),
          ),
          TableColumn(
            key: Keys.amount,
            width: ConstrainedTableColumnWidth(width: 100, minWidth: 20),
            cellBuilder: _buildAmount,
            headerBuilder: _renderHeader('Amount'),
          ),
          TableColumn(
            key: Keys.description,
            width: FlexTableColumnWidth(),
            cellBuilder: _buildDescription,
            headerBuilder: _renderHeader('Description'),
          ),
        ],
      ),
    );
  }
}

class ExpenseCellWrapper extends StatelessWidget {
  const ExpenseCellWrapper({
    Key? key,
    this.rowIndex = 0,
    this.rowHighlighted = false,
    this.rowSelected = false,
    this.isRowDisabled = false,
    required this.content,
  }) : super(key: key);

  final int rowIndex;
  final bool rowHighlighted;
  final bool rowSelected;
  final bool isRowDisabled;
  final String content;

  static const List<Color> colors = <Color>[Color(0xffffffff), Color(0xfff7f5ee)];

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: const Color(0xffffffff));
    } else if (isRowDisabled) {
      style = style.copyWith(color: const Color(0xff999999));
    }
    Widget result = Padding(
      padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
      child: Text(
        content,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
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

class ExpenseReportsListView extends StatefulWidget {
  const ExpenseReportsListView({
    Key? key,
    required this.expenseReports,
    required this.selectionController,
  }) : super(key: key);

  final ExpenseReports expenseReports;
  final ListViewSelectionController selectionController;

  @override
  _ExpenseReportsListViewState createState() => _ExpenseReportsListViewState();
}

class _ExpenseReportsListViewState extends State<ExpenseReportsListView> {
  late InvoiceListener _invoiceListener;

  void _handleExpenseReportInserted(int expenseReportsIndex) {
    setState(() {
      // _expenseReports reference stays the same
    });
  }

  void _handleExpenseReportsRemoved(int expenseReportsIndex, Iterable<ExpenseReport> removed) {
    setState(() {
      // _expenseReports reference stays the same
    });
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    bool isSelected,
    bool isHighlighted,
    bool isDisabled,
  ) {
    final ExpenseReport data = widget.expenseReports[index];
    final StringBuffer buf = StringBuffer(data.program.name);

    final String chargeNumber = data.chargeNumber.trim();
    if (chargeNumber.isNotEmpty) {
      buf.write(' ($chargeNumber)');
    }

    final String task = data.task.trim();
    if (task.isNotEmpty) {
      buf.write(' ($task)');
    }

    final String title = buf.toString();
    final String total = '(${NumberFormats.currency.format(data.total)})';

    Widget result = Padding(
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          Expanded(
              child: Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
          )),
          const SizedBox(width: 2),
          Text(total),
        ],
      ),
    );

    if (isSelected) {
      final TextStyle style = DefaultTextStyle.of(context).style;
      result = DefaultTextStyle(
        style: style.copyWith(color: const Color(0xffffffff)),
        child: result,
      );
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _invoiceListener = InvoiceListener(
      onExpenseReportInserted: _handleExpenseReportInserted,
      onExpenseReportsRemoved: _handleExpenseReportsRemoved,
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xffffffff),
        border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ScrollableListView(
          itemHeight: 19,
          length: widget.expenseReports.length,
          itemBuilder: _buildItem,
          selectionController: widget.selectionController,
        ),
      ),
    );
  }
}
