import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/user.dart';

import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/ui/common/task_monitor.dart';

class CreateInvoiceIntent extends Intent {
  const CreateInvoiceIntent({this.context});

  final BuildContext context;
}

class CreateInvoiceAction extends ContextAction<CreateInvoiceIntent> {
  CreateInvoiceAction._();

  static final CreateInvoiceAction instance = CreateInvoiceAction._();

  @override
  Future<void> invoke(CreateInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final NewInvoiceProperties properties = await CreateInvoiceSheet.open(context: context);
    if (properties != null) {
      await TaskMonitor.of(context).monitor(
        future: InvoiceBinding.instance.createInvoice(properties),
        inProgressMessage: 'Creating invoice',
        completedMessage: 'Invoice created',
      );
    }
  }
}

class CreateInvoiceSheet extends StatefulWidget {
  const CreateInvoiceSheet({Key key}) : super(key: key);

  @override
  _CreateInvoiceSheetState createState() => _CreateInvoiceSheetState();

  static Future<NewInvoiceProperties> open({BuildContext context}) {
    return pivot.Sheet.open<NewInvoiceProperties>(
      context: context,
      content: CreateInvoiceSheet(),
    );
  }
}

class _CreateInvoiceSheetState extends State<CreateInvoiceSheet> {
  List<Map<String, dynamic>> _billingPeriods;
  TextEditingController _invoiceNumberController;
  pivot.TableViewSelectionController _selectionController;

  bool _canProceed = false;
  bool get canProceed => _canProceed;
  set canProceed(bool value) {
    if (value != _canProceed) {
      setState(() {
        _canProceed = value;
      });
    }
  }

  void _checkCanProceed() {
    // TODO: max length for Quickbooks
    final bool isValidInvoiceNumber = _invoiceNumberController.text.trim().isNotEmpty;
    final bool isBillingPeriodSelected = _selectionController.selectedIndex != -1;
    canProceed = isValidInvoiceNumber && isBillingPeriodSelected;
  }

  void _handleOk() {
    final Map<String, dynamic> selectedItem = _billingPeriods[_selectionController.selectedIndex];
    final String billingStart = selectedItem[Keys.billingPeriod];
    Navigator.of(context).pop(NewInvoiceProperties(
      invoiceNumber: _invoiceNumberController.text,
      billingStart: billingStart,
    ));
  }

  @override
  void initState() {
    super.initState();
    _selectionController = pivot.TableViewSelectionController();
    _selectionController.addListener(_checkCanProceed);
    _invoiceNumberController = TextEditingController();
    _invoiceNumberController.addListener(_checkCanProceed);

    final Uri url = Server.uri(Server.newInvoiceParametersUrl);
    UserBinding.instance.user.authenticate().get(url).then((http.Response response) {
      if (!mounted) {
        return;
      }
      if (response.statusCode == HttpStatus.ok) {
        // TODO: Handle disabled row from existing invoices for any given billing period.
        setState(() {
          final Map<String, dynamic> parameters = json.decode(response.body);
          _billingPeriods = parameters[Keys.billingPeriods].cast<Map<String, dynamic>>();
          _invoiceNumberController.text = parameters[Keys.invoiceNumber];
        });
      }
    });
  }

  @override
  void dispose() {
    _invoiceNumberController.removeListener(_checkCanProceed);
    _invoiceNumberController.dispose();
    _selectionController.removeListener(_checkCanProceed);
    _selectionController.dispose();
    super.dispose();
  }

  static final intl.DateFormat dateFormat = intl.DateFormat('M/d/yyyy');

  Widget _renderBillingPeriod({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final Map<String, dynamic> row = _billingPeriods[rowIndex];
    final String startDateValue = row['billing_period'];
    final DateTime startDate = DateTime.parse(startDateValue);
    final DateTime endDate = startDate.add(const Duration(days: 14));
    final String formattedStartDate = dateFormat.format(startDate);
    final String formattedEndDate = dateFormat.format(endDate);

    Widget result = Padding(
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

    if (rowSelected) {
      final TextStyle style = DefaultTextStyle.of(context).style;
      result = DefaultTextStyle(
        style: style.copyWith(color: const Color(0xffffffff)),
        child: result,
      );
    }

    result = AbsorbPointer(
      child: result,
    );

    return result;
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
                        controller: _invoiceNumberController,
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
                              length: _billingPeriods?.length ?? 0,
                              includeHeader: false,
                              selectionController: _selectionController,
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
              if (_billingPeriods == null)
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
                onPressed: canProceed ? _handleOk : null,
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
