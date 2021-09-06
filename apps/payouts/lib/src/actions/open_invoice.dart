import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:chicago/chicago.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/entry_comparator.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/common/task_monitor.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/model/track_user_auth_mixin.dart';
import 'package:payouts/src/model/user.dart';

import 'warn_on_unsaved_changes_mixin.dart';

class OpenInvoiceIntent extends Intent {
  const OpenInvoiceIntent({this.context});

  final BuildContext? context;
}

class OpenInvoiceAction extends ContextAction<OpenInvoiceIntent>
    with TrackInvoiceMixin, TrackUserAuthMixin, WarnOnUnsavedChangesMixin {
  OpenInvoiceAction._() {
    startTrackingInvoiceActivity();
    startTrackingAuth();
  }

  static final OpenInvoiceAction instance = OpenInvoiceAction._();

  @override
  void onUserAuthenticated() {
    super.onUserAuthenticated();
    notifyActionListeners();
  }

  @override
  bool isEnabled(covariant OpenInvoiceIntent intent) {
    return isUserAuthenticated;
  }

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
    return Sheet.open<int>(
      context: context,
      content: OpenInvoiceSheet(),
      barrierDismissible: true,
    );
  }
}

class _OpenInvoiceSheetState extends State<OpenInvoiceSheet>
    with SingleTickerProviderStateMixin<OpenInvoiceSheet> {
  late TableViewMetricsController _metricsController;
  late TableViewSelectionController _selectionController;
  late TableViewSortController _sortController;
  late TableViewSortListener _sortListener;
  late ScrollPaneController _scrollController;
  late AnimationController _scrollAnimationController;
  List<Map<String, dynamic>>? _invoices;
  int? _selectedInvoiceId;

  static const _scrollDuration = Duration(milliseconds: 250);

  static EntryComparator _comparator(TableViewSortController controller) {
    final String sortKey = controller.keys.first;
    final SortDirection direction = controller[sortKey] ?? SortDirection.ascending;
    return EntryComparator(key: sortKey, direction: direction);
  }

  void _handleSelectionChanged() {
    final int rowIndex = _selectionController.selectedIndex;
    _handleInvoiceSelected(rowIndex >= 0 ? _invoices![rowIndex][Keys.invoiceId] : null);
  }

  void _handleSortChanged(TableViewSortController controller) {
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
    _metricsController = TableViewMetricsController();
    _selectionController = TableViewSelectionController(selectMode: SelectMode.single);
    _selectionController.addListener(_handleSelectionChanged);
    _sortListener = TableViewSortListener(onChanged: _handleSortChanged);
    _sortController = TableViewSortController(sortMode: TableViewSortMode.singleColumn);
    _sortController[Keys.billingStart] = SortDirection.descending;
    _sortController.addListener(_sortListener);
    _scrollController = ScrollPaneController();
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
          BorderPane(
            title: 'Open Existing Invoice',
            titlePadding: const EdgeInsets.symmetric(horizontal: 4),
            inset: 9,
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 13, 9, 9),
              child: SizedBox(
                height: 200,
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
                        child: ActivityIndicator(),
                      ),
                      SizedBox(width: 4),
                      Text('Loading invoice...'),
                    ],
                  ),
                ),
              CommandPushButton(
                label: 'OK',
                onPressed: _selectedInvoiceId != null ? _handleInvoiceChosen : null,
              ),
              SizedBox(width: 4),
              CommandPushButton(
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
  final TableViewMetricsController metricsController;
  final TableViewSelectionController selectionController;
  final TableViewSortController sortController;
  final ScrollPaneController scrollController;
  final VoidCallback onInvoiceChosen;

  @override
  Widget build(BuildContext context) {
    if (invoices != null && invoices!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'You have not yet created any invoices. Once you have created invoices, '
            'you will see them listed here.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return DecoratedBox(
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: InvoicesTable(
            invoices: invoices ?? <Map<String, dynamic>>[],
            metricsController: metricsController,
            selectionController: selectionController,
            sortController: sortController,
            scrollController: scrollController,
            onInvoiceChosen: onInvoiceChosen,
          ),
        ),
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
  final TableViewMetricsController metricsController;
  final TableViewSelectionController selectionController;
  final TableViewSortController sortController;
  final ScrollPaneController scrollController;
  final VoidCallback onInvoiceChosen;

  @override
  _InvoicesTableState createState() => _InvoicesTableState();
}

class _InvoicesTableState extends State<InvoicesTable> {
  late List<TableColumn> _columns;

  Widget _buildBillingPeriodCell(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool isRowSelected,
    bool isRowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    return CellWrapper(
      selected: isRowSelected,
      child: BillingPeriodCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _buildBillingPeriodHeader(
    BuildContext context,
    int columnIndex,
  ) {
    return SingleLineText(data: 'Billing Period');
  }

  Widget _buildInvoiceNumberCell(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool isRowSelected,
    bool isRowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    return CellWrapper(
      selected: isRowSelected,
      child: InvoiceNumberCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _buildInvoiceNumberHeader(
    BuildContext context,
    int columnIndex,
  ) {
    return SingleLineText(data: 'Invoice Number');
  }

  Widget _buildSubmittedCell(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool isRowSelected,
    bool isRowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    return CellWrapper(
      selected: isRowSelected,
      child: SubmittedCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _buildSubmittedHeader(
    BuildContext context,
    int columnIndex,
  ) {
    return SingleLineText(data: 'Submitted');
  }

  Widget _buildResubmitCell(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool isRowSelected,
    bool isRowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    return CellWrapper(
      selected: isRowSelected,
      child: ResubmitCell(invoice: widget.invoices[rowIndex]),
    );
  }

  Widget _buildResubmitHeader(
    BuildContext context,
    int columnIndex,
  ) {
    return SingleLineText(data: '');
  }

  @override
  initState() {
    super.initState();
    _columns = <TableColumn>[
      TableColumn(
        key: Keys.billingStart,
        width: ConstrainedTableColumnWidth(width: 150, minWidth: 50),
        cellBuilder: _buildBillingPeriodCell,
        headerBuilder: _buildBillingPeriodHeader,
      ),
      TableColumn(
        key: Keys.invoiceNumber,
        width: ConstrainedTableColumnWidth(width: 125, minWidth: 50),
        cellBuilder: _buildInvoiceNumberCell,
        headerBuilder: _buildInvoiceNumberHeader,
      ),
      TableColumn(
        key: Keys.submitted,
        width: ConstrainedTableColumnWidth(width: 125, minWidth: 50),
        cellBuilder: _buildSubmittedCell,
        headerBuilder: _buildSubmittedHeader,
      ),
      TableColumn(
        key: Keys.resubmit,
        width: FlexTableColumnWidth(),
        cellBuilder: _buildResubmitCell,
        headerBuilder: _buildResubmitHeader,
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
      child: ScrollableTableView(
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xfff7f5ee))),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
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

  static final intl.DateFormat format = intl.DateFormat('M/d/y');

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

  static final intl.DateFormat format = intl.DateFormat('M/d/y h:mm a');

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
