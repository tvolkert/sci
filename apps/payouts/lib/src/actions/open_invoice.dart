import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:payouts/src/pivot.dart' as pivot;

//  static BuildContext _getRootNavigatorContext() {
//    assert(WidgetsBinding.instance.isRootWidgetAttached);
//    final List<Element> queue = [WidgetsBinding.instance.renderViewElement];
//    while (queue.isNotEmpty) {
//      Element element = queue.removeLast();
//      element.visitChildren((Element child) {
//        if (child is StatefulElement && child.state is NavigatorState) {
//          return child;
//        }
//        queue.insert(0, child);
//      });
//    }
//    return null;
//  }

class OpenInvoiceIntent extends Intent {
  const OpenInvoiceIntent({this.context});

  final BuildContext context;
}

class OpenInvoiceAction extends ContextAction<OpenInvoiceIntent> {
  @override
  Future<void> invoke(OpenInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final int invoiceId = await OpenInvoiceSheet.open(context: context);
    if (invoiceId != null) {
      print('TODO: open invoice $invoiceId');
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
    // TODO: Really fetch invoice data
    Timer(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      setState(() {
        invoices = [
          {
            "billing_start": "2008-02-25",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-08-01",
            "submitted": 1252367383491,
            "invoice_id": 65
          },
          {
            "billing_start": "2008-03-24",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-08-02",
            "submitted": 1252367781502,
            "invoice_id": 66
          },
          {
            "billing_start": "2009-02-23",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-09-01",
            "submitted": 1252367003325,
            "invoice_id": 67
          },
          {
            "billing_start": "2009-07-13",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-09-03",
            "submitted": 1249295854823,
            "invoice_id": 33
          },
          {
            "billing_start": "2009-07-27",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-09-02",
            "submitted": 1249194276046,
            "invoice_id": 32
          },
          {
            "billing_start": "2009-08-10",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-09-04",
            "submitted": 1250099538922,
            "invoice_id": 35
          },
          {
            "billing_start": "2009-08-24",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-09-05",
            "submitted": 1252373740578,
            "invoice_id": 54
          },
          {
            "billing_start": "2009-09-21",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-09-06",
            "submitted": 1254439104933,
            "invoice_id": 105
          },
          {
            "billing_start": "2009-10-19",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-09-07",
            "submitted": 1257247734745,
            "invoice_id": 202
          },
          {
            "billing_start": "2009-12-28",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-01",
            "submitted": 1262496920789,
            "invoice_id": 339
          },
          {
            "billing_start": "2010-02-22",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-02",
            "submitted": 1268941298809,
            "invoice_id": 516
          },
          {
            "billing_start": "2010-03-22",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-04",
            "submitted": 1270957011976,
            "invoice_id": 570
          },
          {
            "billing_start": "2010-04-05",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-03",
            "submitted": 1270580789671,
            "invoice_id": 560
          },
          {
            "billing_start": "2010-04-19",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-05",
            "submitted": 1272896039899,
            "invoice_id": 624
          },
          {
            "billing_start": "2010-05-31",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-06",
            "submitted": 1275915515416,
            "invoice_id": 700
          },
          {
            "billing_start": "2010-06-28",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-07",
            "submitted": 1279079308335,
            "invoice_id": 771
          },
          {
            "billing_start": "2010-07-26",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-10-08",
            "submitted": 1281899676803,
            "invoice_id": 842
          },
          {
            "billing_start": "2011-01-10",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-11-01",
            "submitted": 1295194544361,
            "invoice_id": 1160
          },
          {
            "billing_start": "2011-02-07",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-11-02",
            "submitted": 1297170886802,
            "invoice_id": 1211
          },
          {
            "billing_start": "2011-02-21",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-11-03",
            "submitted": 1299375981047,
            "invoice_id": 1269
          },
          {
            "billing_start": "2011-10-31",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-11-04",
            "submitted": 1322149278742,
            "invoice_id": 1813
          },
          {
            "billing_start": "2011-11-14",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-11-05",
            "submitted": 1322670744382,
            "invoice_id": 1834
          },
          {
            "billing_start": "2013-11-11",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-13-01",
            "submitted": 1384730376421,
            "invoice_id": 3235
          },
          {
            "billing_start": "2014-09-01",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-14-01",
            "submitted": 1409984241086,
            "invoice_id": 3645
          },
          {
            "billing_start": "2015-04-27",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-15-02",
            "submitted": 1442966288681,
            "invoice_id": 4221
          },
          {
            "billing_start": "2015-09-14",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-15-01",
            "submitted": 1442851163357,
            "invoice_id": 4219
          },
          {
            "billing_start": "2015-09-28",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-15-03",
            "submitted": 1444150699566,
            "invoice_id": 4240
          },
          {
            "billing_start": "2015-10-12",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "FOO",
            "submitted": null,
            "invoice_id": 4282
          },
          {
            "billing_start": "2015-10-26",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-15-04",
            "submitted": 1446658122622,
            "invoice_id": 4279
          },
          {
            "billing_start": "2015-11-23",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-15-05",
            "submitted": 1449785900901,
            "invoice_id": 4337
          },
          {
            "billing_start": "2015-12-21",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-16-01",
            "submitted": 1451968322139,
            "invoice_id": 4366
          },
          {
            "billing_start": "2016-01-04",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-16-02",
            "submitted": 1452788447967,
            "invoice_id": 4382
          },
          {
            "billing_start": "2016-02-01",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-16-03",
            "submitted": 1454604092702,
            "invoice_id": 4416
          },
          {
            "billing_start": "2017-09-11",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-17-01",
            "submitted": 1506294968475,
            "invoice_id": 5217
          },
          {
            "billing_start": "2017-09-25",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-17-02",
            "submitted": 1508440798862,
            "invoice_id": 5262
          },
          {
            "billing_start": "2019-03-25",
            "resubmit": false,
            "billing_duration": 14,
            "invoice_number": "TCV-FOO",
            "submitted": null,
            "invoice_id": 6021,
          },
        ];
      });
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

class _InvoicesTableState extends State<InvoicesTable> {
  pivot.TableViewSelectionController _selectionController;

  @override
  initState() {
    super.initState();
    _selectionController = pivot.TableViewSelectionController(selectMode: pivot.SelectMode.single);
    _selectionController.addListener(_handleSelectionChanged);
  }

  @override
  dispose() {
    _selectionController.removeListener(_handleSelectionChanged);
    _selectionController.dispose();
    super.dispose();
  }

  void _handleSelectionChanged() {
    if (widget.onInvoiceSelected != null) {
      final int rowIndex = _selectionController.selectedIndex;
      widget.onInvoiceSelected(rowIndex >= 0 ? widget.invoices[rowIndex]['invoice_id'] : null);
    }
  }

  Widget _renderBillingPeriodCell({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowHighlighted,
    bool rowSelected,
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
        selectionController: _selectionController,
        columns: <pivot.TableColumnController>[
          pivot.TableColumnController(
            name: 'billing_period',
            width: pivot.ConstrainedTableColumnWidth(width: 150, minWidth: 50),
            cellRenderer: _renderBillingPeriodCell,
            headerRenderer: _renderBillingPeriodHeader,
          ),
          pivot.TableColumnController(
            name: 'invoice_number',
            width: pivot.ConstrainedTableColumnWidth(width: 125, minWidth: 50),
            cellRenderer: _renderInvoiceNumberCell,
            headerRenderer: _renderInvoiceNumberHeader,
          ),
          pivot.TableColumnController(
            name: 'submitted',
            width: pivot.ConstrainedTableColumnWidth(width: 125, minWidth: 50),
            cellRenderer: _renderSubmittedCell,
            headerRenderer: _renderSubmittedHeader,
          ),
          pivot.TableColumnController(
            name: 'resubmit',
            width: pivot.FlexTableColumnWidth(),
            cellRenderer: _renderResubmitCell,
            headerRenderer: _renderResubmitHeader,
          ),
        ],
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
