import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/entry_comparator.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/user.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/src/pivot/foundation.dart';
import 'package:payouts/ui/common/task_monitor.dart';

import 'warn_on_unsaved_changes_mixin.dart';

class OpenInvoiceIntent extends Intent {
  const OpenInvoiceIntent({this.context});

  final BuildContext? context;
}

class OpenInvoiceAction extends ContextAction<OpenInvoiceIntent>
    with TrackInvoiceMixin, WarnOnUnsavedChangesMixin {
  OpenInvoiceAction._() {
    initInstance();
  }

  static final OpenInvoiceAction instance = OpenInvoiceAction._();

  @override
  Future<void> invoke(OpenInvoiceIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final bool canProceed = await checkForUnsavedChanges(context);
    if (canProceed) {
      final int? invoiceId = await OpenInvoiceSheet.open(context: context);
      if (invoiceId != null) {
        await TaskMonitor.of(context).monitor<Invoice>(
          future: InvoiceBinding.instance!.loadInvoice(invoiceId),
          inProgressMessage: 'Opening invoice',
          completedMessage: 'Invoice opened',
        );
      }
    }
  }
}

class OpenInvoiceSheet extends StatefulWidget {
  const OpenInvoiceSheet({Key? key}) : super(key: key);

  @override
  _OpenInvoiceSheetState createState() => _OpenInvoiceSheetState();

  static Future<int?> open({required BuildContext context}) {
    return pivot.Sheet.open<int>(
      context: context,
      content: OpenInvoiceSheet(),
      barrierDismissible: true,
    );
  }
}

class _OpenInvoiceSheetState extends State<OpenInvoiceSheet>
    with SingleTickerProviderStateMixin<OpenInvoiceSheet> {
  late pivot.TableViewMetricsController _metricsController;
  late pivot.TableViewSelectionController _selectionController;
  late pivot.TableViewSortController _sortController;
  late pivot.TableViewSortListener _sortListener;
  late pivot.ScrollController _scrollController;
  late AnimationController _scrollAnimationController;
  List<Map<String, dynamic>>? _invoices;
  int? _selectedInvoiceId;

  static const _scrollDuration = Duration(milliseconds: 250);

  static EntryComparator _comparator(pivot.TableViewSortController controller) {
    final String sortKey = controller.keys.first;
    final pivot.SortDirection direction = controller[sortKey] ?? pivot.SortDirection.ascending;
    return EntryComparator(key: sortKey, direction: direction);
  }

  void _handleSelectionChanged() {
    final int rowIndex = _selectionController.selectedIndex;
    _handleInvoiceSelected(rowIndex >= 0 ? _invoices![rowIndex][Keys.invoiceId] : null);
  }

  void _handleSortChanged(pivot.TableViewSortController controller) {
    assert(controller == _sortController);
    assert(controller.length == 1);

    Map<String, dynamic>? selectedItem;
    if (_selectionController.selectedIndex != -1) {
      selectedItem = _invoices![_selectionController.selectedIndex];
    }

    final EntryComparator comparator = _comparator(controller);
    _invoices!.sort(comparator.compare);

    if (selectedItem != null) {
      int selectedIndex = binarySearch(_invoices!, selectedItem, compare: comparator.compare);
      assert(selectedIndex >= 0);
      _selectionController.selectedIndex = selectedIndex;
      final Rect rowBounds = _metricsController.metrics.getRowBounds(selectedIndex);
      _scrollController.scrollToVisible(rowBounds, animation: _scrollAnimationController);
    }
  }

  void _handleInvoiceSelected(int? invoiceId) {
    setState(() {
      _selectedInvoiceId = invoiceId;
    });
  }

  void _handleInvoiceChosen() {
    Navigator.of(context).pop(_selectedInvoiceId);
  }

  void _requestInvoices() {
    final Uri url = Server.uri(Server.invoicesUrl);
    UserBinding.instance!.user!.authenticate().get(url).then((http.Response response) {
      if (!mounted) {
        return;
      }
      if (response.statusCode == HttpStatus.ok) {
        assert(_sortController.isNotEmpty);
        final EntryComparator comparator = _comparator(_sortController);

        setState(() {
          final List<dynamic> decoded = json.decode(response.body);
          List<Map<String, dynamic>> invoices = _invoices = decoded.cast<Map<String, dynamic>>();
          if (invoices.isNotEmpty) {
            invoices.sort(comparator.compare);
          }
        });

        // This ensures that we have updated metrics before we set the selected
        // row and scroll it to visible. The idiomatic way to do this would be
        // to post a callback using [SchedulerBinding.addPostFrameCallback],
        // thus ensuring that layout had been performed. Unfortunately, this
        // idiomatic way yields a frame being painted at a zero scroll offset
        // and with no row selected (followed by a frame with the correct
        // visual representation).
        context.owner!.buildScope(context as Element);
        RendererBinding.instance!.pipelineOwner.flushLayout();

        List<Map<String, dynamic>> invoices = _invoices!;
        if (invoices.isNotEmpty) {
          final Invoice? currentInvoice = InvoiceBinding.instance!.invoice;
          if (currentInvoice != null) {
            final Map<String, dynamic> invoiceData = currentInvoice.rawData;
            final int rowIndex = binarySearch(invoices, invoiceData, compare: comparator.compare);
            assert(rowIndex >= 0);
            _selectionController.selectedIndex = rowIndex;
            final Rect rowBounds = _metricsController.metrics.getRowBounds(rowIndex);
            _scrollController.scrollToVisible(rowBounds);
          } else {
            _selectionController.selectedIndex = 0;
            _scrollController.scrollOffset = Offset.zero;
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _metricsController = pivot.TableViewMetricsController();
    _selectionController = pivot.TableViewSelectionController(selectMode: pivot.SelectMode.single);
    _selectionController.addListener(_handleSelectionChanged);
    _sortListener = pivot.TableViewSortListener(onChanged: _handleSortChanged);
    _sortController = pivot.TableViewSortController(sortMode: pivot.TableViewSortMode.singleColumn);
    _sortController[Keys.billingStart] = pivot.SortDirection.descending;
    _sortController.addListener(_sortListener);
    _scrollController = pivot.ScrollController();
    _scrollAnimationController = AnimationController(duration: _scrollDuration, vsync: this);
    _requestInvoices();
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
            titlePadding: const EdgeInsets.symmetric(horizontal: 4),
            inset: 9,
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 13, 9, 9),
              child: SizedBox(
                height: 200,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: InvoicesView(
                      invoices: _invoices,
                      metricsController: _metricsController,
                      selectionController: _selectionController,
                      sortController: _sortController,
                      scrollController: _scrollController,
                      onInvoiceChosen: _handleInvoiceChosen,
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
              if (_invoices == null)
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
                onPressed: _selectedInvoiceId != null ? _handleInvoiceChosen : null,
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
    Key? key,
    required this.invoices,
    required this.metricsController,
    required this.selectionController,
    required this.sortController,
    required this.scrollController,
    required this.onInvoiceChosen,
  }) : super(key: key);

  final List<Map<String, dynamic>>? invoices;
  final pivot.TableViewMetricsController metricsController;
  final pivot.TableViewSelectionController selectionController;
  final pivot.TableViewSortController sortController;
  final pivot.ScrollController scrollController;
  final VoidCallback onInvoiceChosen;

  @override
  Widget build(BuildContext context) {
    if (invoices != null && invoices!.isEmpty) {
      // TODO: what should this be?
      return Text('TODO');
    } else {
      return InvoicesTable(
        invoices: invoices ?? <Map<String, dynamic>>[],
        metricsController: metricsController,
        selectionController: selectionController,
        sortController: sortController,
        scrollController: scrollController,
        onInvoiceChosen: onInvoiceChosen,
      );
    }
  }
}

class InvoicesTable extends StatefulWidget {
  const InvoicesTable({
    Key? key,
    required this.invoices,
    required this.metricsController,
    required this.selectionController,
    required this.sortController,
    required this.scrollController,
    required this.onInvoiceChosen,
  }) : super(key: key);

  final List<Map<String, dynamic>> invoices;
  final pivot.TableViewMetricsController metricsController;
  final pivot.TableViewSelectionController selectionController;
  final pivot.TableViewSortController sortController;
  final pivot.ScrollController scrollController;
  final VoidCallback onInvoiceChosen;

  @override
  _InvoicesTableState createState() => _InvoicesTableState();
}

class _InvoicesTableState extends State<InvoicesTable> {
  late List<pivot.TableColumnController> _columns;

  Widget _renderBillingPeriodCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowHighlighted,
    required bool rowSelected,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: BillingPeriodCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderBillingPeriodHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return SingleLineText(data: 'Billing Period');
  }

  Widget _renderInvoiceNumberCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowHighlighted,
    required bool rowSelected,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: InvoiceNumberCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderInvoiceNumberHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return SingleLineText(data: 'Invoice Number');
  }

  Widget _renderSubmittedCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowHighlighted,
    required bool rowSelected,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: SubmittedCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderSubmittedHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return SingleLineText(data: 'Submitted');
  }

  Widget _renderResubmitCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowHighlighted,
    required bool rowSelected,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    return CellWrapper(
      selected: rowSelected,
      child: ResubmitCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _renderResubmitHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return SingleLineText(data: '');
  }

  @override
  initState() {
    super.initState();
    _columns = <pivot.TableColumnController>[
      pivot.TableColumnController(
        key: Keys.billingStart,
        width: pivot.ConstrainedTableColumnWidth(width: 150, minWidth: 50),
        cellRenderer: _renderBillingPeriodCell,
        headerRenderer: _renderBillingPeriodHeader,
      ),
      pivot.TableColumnController(
        key: Keys.invoiceNumber,
        width: pivot.ConstrainedTableColumnWidth(width: 125, minWidth: 50),
        cellRenderer: _renderInvoiceNumberCell,
        headerRenderer: _renderInvoiceNumberHeader,
      ),
      pivot.TableColumnController(
        key: Keys.submitted,
        width: pivot.ConstrainedTableColumnWidth(width: 125, minWidth: 50),
        cellRenderer: _renderSubmittedCell,
        headerRenderer: _renderSubmittedHeader,
      ),
      pivot.TableColumnController(
        key: Keys.resubmit,
        width: pivot.FlexTableColumnWidth(),
        cellRenderer: _renderResubmitCell,
        headerRenderer: _renderResubmitHeader,
      ),
    ];
  }

  void _handleDoubleTapRow(int row) {
    assert(row >= 0);
    if (row < widget.invoices.length) {
      widget.onInvoiceChosen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xffffffff),
      child: pivot.ScrollableTableView(
        length: widget.invoices.length,
        rowHeight: 19,
        roundColumnWidthsToWholePixel: true,
        metricsController: widget.metricsController,
        selectionController: widget.selectionController,
        sortController: widget.sortController,
        scrollController: widget.scrollController,
        columns: _columns,
        onDoubleTapRow: _handleDoubleTapRow,
      ),
    );
  }
}

class CellWrapper extends StatelessWidget {
  const CellWrapper({
    Key? key,
    required this.selected,
    required this.child,
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
    Key? key,
    required this.data,
  }) : super(key: key);

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
    Key? key,
    required this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  static final DateFormat format = DateFormat('M/d/y');

  @override
  Widget build(BuildContext context) {
    String start = invoice[Keys.billingStart];
    int duration = invoice[Keys.billingDuration];
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
    Key? key,
    required this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    final String invoiceNumber = invoice[Keys.invoiceNumber];
    return SingleLineText(data: invoiceNumber);
  }
}

class SubmittedCell extends StatelessWidget {
  const SubmittedCell({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  static final DateFormat format = DateFormat('M/d/y h:mm a');

  @override
  Widget build(BuildContext context) {
    int? submitted = invoice[Keys.submitted];
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
    Key? key,
    required this.invoice,
  }) : super(key: key);

  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    final bool resubmit = invoice[Keys.resubmit];
    return resubmit ? Image.asset('assets/exclamation.png', width: 16, height: 16) : Container();
  }
}
