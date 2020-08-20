import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;

import 'package:payouts/src/pivot.dart' as pivot;

class CreateInvoiceIntent extends Intent {
  const CreateInvoiceIntent({this.context});

  final BuildContext context;
}

class CreateInvoiceAction extends ContextAction<CreateInvoiceIntent> {
  @override
  Future<void> invoke(CreateInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await CreateInvoiceSheet.open(context: context);
    print('TODO: create invoice');
  }
}

class CreateInvoiceSheet extends StatefulWidget {
  const CreateInvoiceSheet({Key key}) : super(key: key);

  @override
  _CreateInvoiceSheetState createState() => _CreateInvoiceSheetState();

  static Future<void> open({BuildContext context}) {
    return pivot.Sheet.open<void>(
      context: context,
      content: CreateInvoiceSheet(),
    );
  }
}

class _CreateInvoiceSheetState extends State<CreateInvoiceSheet> {
  List<Map<String, dynamic>> billingPeriods;
  String invoiceNumber;

  @override
  void initState() {
    super.initState();
    // TODO: Really fetch `/newInvoiceParameters`
    Timer(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      setState(() {
        billingPeriods = [
          {"billing_period": "2020-02-24"},
          {"billing_period": "2020-03-09"},
          {"billing_period": "2020-03-23"},
          {"billing_period": "2020-04-06"},
          {"billing_period": "2020-04-20"},
          {"billing_period": "2020-05-04"},
          {"billing_period": "2020-05-18"},
          {"billing_period": "2020-06-01"},
          {"billing_period": "2020-06-15"},
          {"billing_period": "2020-06-29"},
          {"billing_period": "2020-07-13"},
          {"billing_period": "2020-07-27"},
          {"billing_period": "2020-08-10"},
        ];
        invoiceNumber = '';
      });
    });
  }

  static final intl.DateFormat dateFormat = intl.DateFormat('M/d/yyyy');

  Widget _renderBillingPeriod({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
  }) {
    final Map<String, dynamic> row = billingPeriods[rowIndex];
    final String startDateValue = row['billing_period'];
    final DateTime startDate = DateTime.parse(startDateValue);
    final DateTime endDate = startDate.add(const Duration(days: 14));
    final String formattedStartDate = dateFormat.format(startDate);
    final String formattedEndDate = dateFormat.format(endDate);
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 65),
            child: Text(formattedStartDate, maxLines: 1, textAlign: TextAlign.right),
          ),
          Text(' - '),
          Expanded(child: Text(formattedEndDate, maxLines: 1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pivot.Border(
            title: 'Create New Invoice',
            titlePadding: EdgeInsets.symmetric(horizontal: 4),
            inset: 9,
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.fromLTRB(9, 13, 9, 9),
              child: Table(
                columnWidths: <int, TableColumnWidth>{
                  0: FixedColumnWidth(100),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(25),
                },
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      Text('Invoice number:'),
                      TextField(
                        cursorWidth: 1,
                        cursorColor: Colors.black,
                        style: TextStyle(fontFamily: 'Verdana', fontSize: 11),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hoverColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.fromLTRB(3, 13, 0, 4),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xff999999)),
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xff999999)),
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      Container(),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(height: 6),
                      SizedBox(height: 6),
                      SizedBox(height: 6),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      Text('Billing period:'),
                      SizedBox(
                        height: 200,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xff999999)),
                            color: const Color(0xffffffff),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(1),
                            child: pivot.ScrollableTableView(
                              rowHeight: 19,
                              length: billingPeriods?.length ?? 0,
                              includeHeader: false,
                              columns: [
                                pivot.TableColumnController(
                                  key: 'billing_period',
                                  cellRenderer: _renderBillingPeriod,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (billingPeriods == null)
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: pivot.ActivityIndicator(),
                      ),
                      SizedBox(width: 4),
                      Text('Loading data...'),
                    ],
                  ),
                ),
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: () => Navigator.of(context).pop(),
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
