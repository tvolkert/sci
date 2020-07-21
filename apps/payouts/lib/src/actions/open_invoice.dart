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

class OpenInvoiceAction extends Action<OpenInvoiceIntent> {
  @override
  Future<void> invoke(OpenInvoiceIntent intent) async {
    BuildContext context = intent.context ?? primaryFocus.context;
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

  @override
  void initState() {
    super.initState();
    // TODO: Really fetch invoice data
    Timer(const Duration(seconds: 3), () {
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
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff999999)),
            ),
            child: SizedBox(
              height: 200,
              child: InvoicesView(invoices: invoices),
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
                        // TODO Pivot circular progress indicator
                        child: CircularProgressIndicator(backgroundColor: Colors.black),
                      ),
                      SizedBox(width: 4),
                      Text('Loading invoice...'),
                    ],
                  ),
                ),
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: () => Navigator.of(context).pop(1 /* TODO: invoiceId */),
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
  }) : super(key: key);

  final List<Map<String, dynamic>> invoices;

  @override
  Widget build(BuildContext context) {
    if (invoices == null) {
      return Container();
    } else if (invoices.isEmpty) {
      // TODO: what should this be?
      return Text('TODO');
    } else {
      return pivot.ScrollPane(
        horizontalScrollBarPolicy: pivot.ScrollBarPolicy.expand,
        verticalScrollBarPolicy: pivot.ScrollBarPolicy.expand,
        view: InvoicesTable(invoices: invoices),
      );
    }
  }
}

class InvoicesTable extends StatelessWidget {
  const InvoicesTable({
    Key key,
    this.invoices,
  }) : super(key: key);

  final List<Map<String, dynamic>> invoices;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: FixedColumnWidth(135),
      columnWidths: {
        3: FlexColumnWidth(),
      },
      children: List<TableRow>.generate(invoices.length, (int index) {
        final Map<String, dynamic> invoice = invoices[index];
        return TableRow(
          children: [
            BillingPeriodCell(invoice: invoice),
            Text(invoice['invoice_number']),
            SubmittedCell(invoice: invoice),
            ResubmitCell(invoice: invoice),
          ],
        );
      }),
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
    return Text(buf.toString(), maxLines: 1, overflow: TextOverflow.visible);
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
      return Text(format.format(submittedTime));
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
