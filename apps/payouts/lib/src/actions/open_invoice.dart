import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/user.dart';

import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/src/pivot/foundation.dart';
import 'package:payouts/ui/common/task_monitor.dart';

typedef InvoiceComparator = int Function(Map<String, dynamic> a, Map<String, dynamic> b);

int _compareInvoiceNumber(Map<String, dynamic> a, Map<String, dynamic> b) {
  final String aVal = a['invoice_number'];
  final String bVal = b['invoice_number'];
  assert(aVal != null && bVal != null);
  return aVal.compareTo(bVal);
}

int _compareBillingPeriod(Map<String, dynamic> a, Map<String, dynamic> b) {
  final String aVal = a['billing_start'];
  final String bVal = b['billing_start'];
  // String comparison should work since we're using YYYY-MM-DD format.
  return aVal.compareTo(bVal);
}

int _compareSubmitted(Map<String, dynamic> a, Map<String, dynamic> b) {
  final int aVal = a['submitted'];
  final int bVal = b['submitted'];
  if (aVal == bVal) {
    return 0;
  } else if (aVal == null) {
    return 1;
  } else if (bVal == null) {
    return -1;
  } else {
    return aVal.compareTo(bVal);
  }
}

int _compareResubmit(Map<String, dynamic> a, Map<String, dynamic> b) {
  final bool aVal = a['resubmit'];
  final bool bVal = b['resubmit'];
  if (aVal == bVal) {
    return 0;
  } else if (aVal) {
    return -1;
  } else {
    return 1;
  }
}

const Map<String, InvoiceComparator> _invoiceComparators = <String, InvoiceComparator>{
  'invoice_number': _compareInvoiceNumber,
  'billing_start': _compareBillingPeriod,
  'submitted': _compareSubmitted,
  'resubmit': _compareResubmit,
};

class OpenInvoiceIntent extends Intent {
  const OpenInvoiceIntent({this.context});

  final BuildContext context;
}

class OpenInvoiceAction extends ContextAction<OpenInvoiceIntent> {
  OpenInvoiceAction._();

  static final OpenInvoiceAction instance = OpenInvoiceAction._();

  @override
  Future<void> invoke(OpenInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final int invoiceId = await OpenInvoiceSheet.open(context: context);
    if (invoiceId != null) {
      await TaskMonitor.of(context).monitor<Invoice>(
        future: InvoiceBinding.instance.loadInvoice(invoiceId),
        inProgressMessage: 'Opening invoice',
        completedMessage: 'Invoice opened',
      );
    }
  }
}

class OpenInvoiceSheet extends StatefulWidget {
  const OpenInvoiceSheet({Key key}) : super(key: key);

  @override
  _OpenInvoiceSheetState createState() => _OpenInvoiceSheetState();

  static Future<int> open({BuildContext context}) {
    return pivot.Sheet.open<int>(
      context: context,
      content: OpenInvoiceSheet(),
    );
  }
}

class _OpenInvoiceSheetState extends State<OpenInvoiceSheet> {
  List<Map<String, dynamic>> invoices;
  int _selectedInvoiceId;

  void _handleInvoiceSelected(int invoiceId) {
    setState(() {
      _selectedInvoiceId = invoiceId;
    });
  }

  void _handleOk() {
    Navigator.of(context).pop(_selectedInvoiceId);
  }

  @override
  void initState() {
    super.initState();
    final Uri url = Server.uri(Server.invoicesUrl);
    UserBinding.instance.user.authenticate().get(url).then((http.Response response) {
      if (!mounted) {
        return;
      }
      if (response.statusCode == HttpStatus.ok) {
        setState(() {
          invoices = json.decode(response.body).cast<Map<String, dynamic>>();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pivot.Border(
            title: 'Open Existing Invoice',
            titlePadding: EdgeInsets.symmetric(horizontal: 4),
            inset: 9,
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.fromLTRB(9, 13, 9, 9),
              child: SizedBox(
                height: 200,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff999999)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(1),
                    child: InvoicesView(
                      invoices: invoices,
                      onInvoiceSelected: _handleInvoiceSelected,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (invoices == null)
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: pivot.ActivityIndicator(),
                      ),
                      SizedBox(width: 4),
                      Text('Loading invoice...'),
                    ],
                  ),
                ),
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: _selectedInvoiceId != null ? _handleOk : null,
              ),
              SizedBox(width: 4),
              pivot.CommandPushButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InvoicesView extends StatelessWidget {
  const InvoicesView({
    Key key,
    this.invoices,
    this.onInvoiceSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> invoices;
  final ValueChanged<int> onInvoiceSelected;

  @override
  Widget build(BuildContext context) {
    if (invoices == null) {
      return InvoicesTable(invoices: const <Map<String, dynamic>>[]);
    } else if (invoices.isEmpty) {
      // TODO: what should this be?
      return Text('TODO');
    } else {
      return InvoicesTable(
        invoices: invoices,
        onInvoiceSelected: onInvoiceSelected,
      );
    }
  }
}

class InvoicesTable extends StatefulWidget {
  const InvoicesTable({
    Key key,
    this.invoices,
    this.onInvoiceSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> invoices;
  final ValueChanged<int> onInvoiceSelected;

  @override
  _InvoicesTableState createState() => _InvoicesTableState();
}

class _InvoicesTableState extends State<InvoicesTable>
    with SingleTickerProviderStateMixin<InvoicesTable> {
  pivot.TableViewMetricsController _metricsController;
  pivot.TableViewSelectionController _selectionController;
  pivot.TableViewSortController _sortController;
  pivot.TableViewSortListener _sortListener;
  pivot.ScrollController _scrollController;
  AnimationController _scrollAnimationController;
  List<pivot.TableColumnController> _columns;

  @override
  initState() {
    super.initState();
    _metricsController = pivot.TableViewMetricsController();
    _selectionController = pivot.TableViewSelectionController(selectMode: pivot.SelectMode.single);
    _selectionController.addListener(_handleSelectionChanged);
    _sortListener = pivot.TableViewSortListener(onChanged: _handleSortChanged);
    _sortController = pivot.TableViewSortController(sortMode: pivot.TableViewSortMode.singleColumn);
    _sortController.addListener(_sortListener);
    _scrollController = pivot.ScrollController();
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _columns = <pivot.TableColumnController>[
      pivot.TableColumnController(
        key: 'billing_start',
        width: pivot.ConstrainedTableColumnWidth(width: 150, minWidth: 50),
        cellRenderer: _renderBillingPeriodCell,
        headerRenderer: _renderBillingPeriodHeader,
      ),
      pivot.TableColumnController(
        key: 'invoice_number',
        width: pivot.ConstrainedTableColumnWidth(width: 125, minWidth: 50),
        cellRenderer: _renderInvoiceNumberCell,
        headerRenderer: _renderInvoiceNumberHeader,
      ),
      pivot.TableColumnController(
        key: 'submitted',
        width: pivot.ConstrainedTableColumnWidth(width: 125, minWidth: 50),
        cellRenderer: _renderSubmittedCell,
        headerRenderer: _renderSubmittedHeader,
      ),
      pivot.TableColumnController(
        key: 'resubmit',
        width: pivot.FlexTableColumnWidth(),
        cellRenderer: _renderResubmitCell,
        headerRenderer: _renderResubmitHeader,
      ),
    ];
  }

  @override
  dispose() {
    _metricsController.dispose();
    _selectionController.removeListener(_handleSelectionChanged);
    _selectionController.dispose();
    _sortController.removeListener(_sortListener);
    _sortController.dispose();
    _scrollController.dispose();
    _scrollAnimationController.dispose();
    super.dispose();
  }

  void _handleSelectionChanged() {
    if (widget.onInvoiceSelected != null) {
      final int rowIndex = _selectionController.selectedIndex;
      widget.onInvoiceSelected(rowIndex >= 0 ? widget.invoices[rowIndex]['invoice_id'] : null);
    }
  }

  void _handleSortChanged(pivot.TableViewSortController controller) {
    assert(controller == _sortController);
    assert(controller.length == 1);

    Map<String, dynamic> selectedItem;
    if (_selectionController.selectedIndex != -1) {
      selectedItem = widget.invoices[_selectionController.selectedIndex];
    }

    final String sortKey = controller.keys.first;
    final pivot.SortDirection direction = controller[sortKey];
    final InvoiceComparator basicComparator = _invoiceComparators[sortKey];
    InvoiceComparator comparator = (Map<String, dynamic> a, Map<String, dynamic> b) {
      int result = basicComparator(a, b);
      if (direction == pivot.SortDirection.descending) {
        result *= -1;
      }
      return result;
    };
    widget.invoices.sort(comparator);

    if (selectedItem != null) {
      int selectedIndex = binarySearch(widget.invoices, selectedItem, compare: comparator);
      assert(selectedIndex >= 0);
      _selectionController.selectedIndex = selectedIndex;
      assert(_metricsController.metrics != null);
      final Rect rowBounds = _metricsController.metrics.getRowBounds(selectedIndex);
      _scrollController.scrollToVisible(rowBounds, animation: _scrollAnimationController);
    }
  }

  Widget _renderBillingPeriodCell({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowHighlighted,
    bool rowSelected,
    bool isEditing,
    bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: BillingPeriodCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderBillingPeriodHeader({BuildContext context, int columnIndex}) {
    return SingleLineText(data: 'Billing Period');
  }

  Widget _renderInvoiceNumberCell({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowHighlighted,
    bool rowSelected,
    bool isEditing,
    bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: InvoiceNumberCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderInvoiceNumberHeader({BuildContext context, int columnIndex}) {
    return SingleLineText(data: 'Invoice Number');
  }

  Widget _renderSubmittedCell({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowHighlighted,
    bool rowSelected,
    bool isEditing,
    bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: SubmittedCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderSubmittedHeader({BuildContext context, int columnIndex}) {
    return SingleLineText(data: 'Submitted');
  }

  Widget _renderResubmitCell({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowHighlighted,
    bool rowSelected,
    bool isEditing,
    bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: ResubmitCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderResubmitHeader({BuildContext context, int columnIndex}) {
    return SingleLineText(data: '');
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xffffffff),
      child: pivot.ScrollableTableView(
        length: widget.invoices.length,
        rowHeight: 19,
        roundColumnWidthsToWholePixel: true,
        metricsController: _metricsController,
        selectionController: _selectionController,
        sortController: _sortController,
        scrollController: _scrollController,
        columns: _columns,
      ),
    );
  }
}

class CellWrapper extends StatelessWidget {
  const CellWrapper({
    Key key,
    this.selected,
    this.child,
  }) : super(key: key);

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: const Color(0xfff7f5ee))),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ),
    );

    if (selected) {
      final TextStyle style = DefaultTextStyle.of(context).style;
      result = DefaultTextStyle(
        style: style.copyWith(color: const Color(0xffffffff)),
        child: result,
      );
    }

    return result;
  }
}

class SingleLineText extends StatelessWidget {
  const SingleLineText({
    Key key,
    @required this.data,
  })  : assert(data != null),
        super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: 1,
      softWrap: false,
      textAlign: TextAlign.left,
      overflow: TextOverflow.clip,
    );
  }
}

class BillingPeriodCell extends StatelessWidget {
  const BillingPeriodCell({
    Key key,
    this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  static final DateFormat format = DateFormat('M/d/y');

  @override
  Widget build(BuildContext context) {
    String start = invoice['billing_start'];
    int duration = invoice['billing_duration'];
    DateTime startDate = DateTime.parse(start);
    DateTime endDate = startDate.add(Duration(days: duration));
    StringBuffer buf = StringBuffer()
      ..write(format.format(startDate))
      ..write(' - ')
      ..write(format.format(endDate));
    return SingleLineText(data: buf.toString());
  }
}

class InvoiceNumberCell extends StatelessWidget {
  const InvoiceNumberCell({
    Key key,
    this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    final String invoiceNumber = invoice['invoice_number'];
    return SingleLineText(data: invoiceNumber);
  }
}

class SubmittedCell extends StatelessWidget {
  const SubmittedCell({
    Key key,
    this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  static final DateFormat format = DateFormat('M/d/y h:mm a');

  @override
  Widget build(BuildContext context) {
    int submitted = invoice['submitted'];
    if (submitted == null) {
      return Container();
    } else {
      DateTime submittedTime = DateTime.fromMillisecondsSinceEpoch(submitted);
      return SingleLineText(data: format.format(submittedTime));
    }
  }
}

class ResubmitCell extends StatelessWidget {
  const ResubmitCell({
    Key key,
    this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    final bool resubmit = invoice['resubmit'];
    return resubmit ? Image.asset('assets/exclamation.png', width: 16, height: 16) : Container();
  }
}
