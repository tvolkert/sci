import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/entry_comparator.dart';
import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/user.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/ui/common/task_monitor.dart';

import 'warn_on_unsaved_changes_mixin.dart';

class CreateInvoiceIntent extends Intent {
  const CreateInvoiceIntent({this.context});

  final BuildContext? context;
}

class CreateInvoiceAction extends ContextAction<CreateInvoiceIntent>
    with TrackInvoiceMixin, WarnOnUnsavedChangesMixin {
  CreateInvoiceAction._() {
    initInstance();
  }

  static final CreateInvoiceAction instance = CreateInvoiceAction._();

  @override
  Future<void> invoke(CreateInvoiceIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final bool canProceed = await checkForUnsavedChanges(context);
    if (canProceed) {
      final NewInvoiceProperties? properties = await CreateInvoiceSheet.open(context: context);
      if (properties != null) {
        await TaskMonitor.of(context).monitor(
          future: InvoiceBinding.instance!.createInvoice(properties),
          inProgressMessage: 'Creating invoice',
          completedMessage: 'Invoice created',
        );
      }
    }
  }
}

class CreateInvoiceSheet extends StatefulWidget {
  const CreateInvoiceSheet({Key? key}) : super(key: key);

  @override
  _CreateInvoiceSheetState createState() => _CreateInvoiceSheetState();

  static Future<NewInvoiceProperties?> open({required BuildContext context}) {
    return chicago.Sheet.open<NewInvoiceProperties>(
      context: context,
      content: CreateInvoiceSheet(),
      barrierDismissible: true,
    );
  }
}

class _CreateInvoiceSheetState extends State<CreateInvoiceSheet> {
  List<Map<String, dynamic>>? _billingPeriods;
  late double _billingPeriodsBaseline;
  late TextEditingController _invoiceNumberController;
  late chicago.TableViewSelectionController _selectionController;
  late chicago.TableViewRowDisablerController _disablerController;
  chicago.Flag? _invoiceNumberFlag;
  chicago.Flag? _billingPeriodFlag;

  static final intl.DateFormat dateFormat = intl.DateFormat('M/d/yyyy');
  static const EntryComparator _comparator = EntryComparator(
    key: Keys.billingPeriod,
    direction: chicago.SortDirection.descending,
  );

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
    bool isInputValid = true;

    final String invoiceNumber = _invoiceNumberController.text.trim();
    final int selectedIndex = _selectionController.selectedIndex;

    setState(() {
      if (invoiceNumber.isEmpty) {
        isInputValid = false;
        _invoiceNumberFlag = chicago.Flag(
          messageType: chicago.MessageType.error,
          message: 'TODO',
        );
      } else {
        _invoiceNumberFlag = null;
      }

      if (selectedIndex == -1) {
        isInputValid = false;
        _billingPeriodFlag = chicago.Flag(
          messageType: chicago.MessageType.error,
          message: 'TODO',
        );
      } else {
        _billingPeriodFlag = null;
      }
    });

    if (isInputValid) {
      final Map<String, dynamic> selectedItem = _billingPeriods![selectedIndex];
      final String billingStart = selectedItem[Keys.billingPeriod];
      Navigator.of(context).pop(NewInvoiceProperties(
        invoiceNumber: invoiceNumber,
        billingStart: billingStart,
      ));
    } else {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void _handleDoubleTapRow(int row) {
    assert(row >= 0);
    _handleOk();
  }

  bool _isRowDisabled(int rowIndex) {
    final Map<String, dynamic> row = _billingPeriods![rowIndex];
    return row.containsKey(Keys.invoiceNumber);
  }

  void _requestParameters() {
    final Uri url = Server.uri(Server.newInvoiceParametersUrl);
    UserBinding.instance!.user!.authenticate().get(url).then((http.Response response) {
      if (!mounted) {
        return;
      }
      if (response.statusCode == HttpStatus.ok) {
        setState(() {
          final Map<String, dynamic> parameters = json.decode(response.body);
          _billingPeriods = parameters[Keys.billingPeriods].cast<Map<String, dynamic>>();
          _billingPeriods!.sort(_comparator.compare);
          _invoiceNumberController.text = parameters[Keys.invoiceNumber];
        });
      }
    });
  }

  Widget _renderBillingPeriod(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
    bool isRowDisabled,
  ) {
    assert(!isEditing);
    assert(rowIndex >= 0);
    final Map<String, dynamic> row = _billingPeriods![rowIndex];
    final String startDateValue = row[Keys.billingPeriod];
    final DateTime startDate = DateTime.parse(startDateValue);
    final DateTime endDate = startDate.add(const Duration(days: 14));
    final String formattedStartDate = dateFormat.format(startDate);
    final String formattedEndDate = dateFormat.format(endDate);
    final String? invoiceNumber = row[Keys.invoiceNumber];

    Widget result = Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 68),
            child: Text(formattedStartDate, maxLines: 1, textAlign: TextAlign.right),
          ),
          Text(' - '),
          Text(formattedEndDate, maxLines: 1),
          if (invoiceNumber != null)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  '($invoiceNumber)',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
        ],
      ),
    );

    if (isRowDisabled) {
      final TextStyle style = DefaultTextStyle.of(context).style;
      result = DefaultTextStyle(
        style: style.copyWith(color: const Color(0xff999999)),
        child: result,
      );
    } else if (rowSelected) {
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
  void initState() {
    super.initState();
    _selectionController = chicago.TableViewSelectionController();
    _selectionController.addListener(_checkCanProceed);
    _invoiceNumberController = TextEditingController();
    _invoiceNumberController.addListener(_checkCanProceed);
    _disablerController = chicago.TableViewRowDisablerController(filter: _isRowDisabled);
    _requestParameters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TextStyle style = DefaultTextStyle.of(context).style;
    final TextDirection textDirection = Directionality.of(context);
    const chicago.WidgetSurveyor surveyor = chicago.WidgetSurveyor();
    setState(() {
      _billingPeriodsBaseline = surveyor.measureDistanceToBaseline(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
          child: Text('prototype', style: style, textDirection: textDirection),
        ),
      );
    });
  }

  @override
  void dispose() {
    _invoiceNumberController.removeListener(_checkCanProceed);
    _invoiceNumberController.dispose();
    _selectionController.removeListener(_checkCanProceed);
    _selectionController.dispose();
    _disablerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chicago.BorderPane(
            title: 'Create New Invoice',
            titlePadding: EdgeInsets.symmetric(horizontal: 4),
            inset: 9,
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.fromLTRB(9, 13, 9, 9),
              child: chicago.FormPane(
                children: [
                  chicago.FormPaneField(
                    label: 'Invoice number',
                    flag: _invoiceNumberFlag,
                    child: chicago.TextInput(
                      controller: _invoiceNumberController,
                      autofocus: true,
                    ),
                  ),
                  chicago.FormPaneField(
                    label: 'Billing period',
                    flag: _billingPeriodFlag,
                    child: SizedBox(
                      height: 200,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff999999)),
                          color: const Color(0xffffffff),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(1),
                          child: chicago.SetBaseline(
                            baseline: _billingPeriodsBaseline,
                            child: chicago.ScrollableTableView(
                              rowHeight: 19,
                              length: _billingPeriods?.length ?? 0,
                              includeHeader: false,
                              selectionController: _selectionController,
                              rowDisabledController: _disablerController,
                              onDoubleTapRow: _handleDoubleTapRow,
                              columns: [
                                chicago.TableColumn(
                                  key: 'billing_period',
                                  cellBuilder: _renderBillingPeriod,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                        child: chicago.ActivityIndicator(),
                      ),
                      SizedBox(width: 4),
                      Text('Loading data...'),
                    ],
                  ),
                ),
              chicago.CommandPushButton(
                label: 'OK',
                onPressed: canProceed ? _handleOk : null,
              ),
              SizedBox(width: 4),
              chicago.CommandPushButton(
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
