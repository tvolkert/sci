import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/pivot.dart' as pivot;

class AddExpenseIntent extends Intent {
  const AddExpenseIntent({this.context, required this.expenseReport});

  final BuildContext? context;
  final ExpenseReport expenseReport;
}

class AddExpenseAction extends ContextAction<AddExpenseIntent> with TrackInvoiceMixin {
  AddExpenseAction._() {
    initInstance();
  }

  static final AddExpenseAction instance = AddExpenseAction._();

  @override
  void onInvoiceSubmittedChanged() {
    super.onInvoiceSubmittedChanged();
    notifyActionListeners();
  }

  @override
  bool isEnabled(AddExpenseIntent intent) {
    assert(intent.expenseReport.invoice == invoice);
    return !invoice.isSubmitted;
  }

  @override
  Future<void> invoke(AddExpenseIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final ExpenseMetadata? metadata = await AddExpenseSheet.open(
      context: context,
      expenseReport: intent.expenseReport,
    );
    if (metadata != null) {
      intent.expenseReport.expenses.add(metadata);
    }
  }
}

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    Key? key,
    required this.expenseReport,
  }) : super(key: key);

  final ExpenseReport expenseReport;

  @override
  AddExpenseSheetState createState() => AddExpenseSheetState();

  static Future<ExpenseMetadata?> open({
    required BuildContext context,
    required ExpenseReport expenseReport,
  }) {
    return pivot.Sheet.open<ExpenseMetadata>(
      context: context,
      content: AddExpenseSheet(expenseReport: expenseReport),
      barrierDismissible: true,
    );
  }
}

class AddExpenseSheetState extends State<AddExpenseSheet> {
  bool _copyExpenses = false;

  void _handleToggleCopyExpenses() {
    setState(() {
      _copyExpenses = !_copyExpenses;
    });
  }

  void _handleOk() {
    // TODO
  }

  Widget _buildExpenseType<T>(BuildContext context, T? item, bool isForMeasurementOnly) {
    return Container();
  }

  Widget _buildExpenseTypeItem<T>(
    BuildContext context,
    T item,
    bool isSelected,
    bool isHighlighted,
    bool isDisabled,
  ) {
    return Container();
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
            backgroundColor: const Color(0xffffffff),
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: pivot.Form(
                children: <pivot.FormField>[
                  pivot.FormField(
                    label: 'Category',
                    child: pivot.ListButton(
                      items: [],
                      builder: _buildExpenseType,
                      itemBuilder: _buildExpenseTypeItem,
                    ),
                  ),
                  pivot.FormField(
                    label: 'Date',
                    child: pivot.CalendarButton(),
                  ),
                  pivot.FormField(
                    label: 'Amount',
                    child: pivot.TextInput(
                      backgroundColor: const Color(0xfff7f5ee),
                    ),
                  ),
                  pivot.FormField(
                    label: 'Description',
                    child: Row(
                      children: [
                        Expanded(
                          child: pivot.TextInput(
                            backgroundColor: const Color(0xfff7f5ee),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text('(optional)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.baseline,
            // textBaseline: TextBaseline.alphabetic,
            children: [
              pivot.Checkbox(
                checked: _copyExpenses,
                onChange: _handleToggleCopyExpenses,
                spacing: 6,
                child: Row(
                  children: [
                    Text('Copy this expense for a total of'),
                    SizedBox(width: 4),
                    pivot.Spinner(
                      isEnabled: _copyExpenses,
                      length: 14,
                      itemBuilder: (BuildContext context, int index, bool isEnabled) {
                        return pivot.Spinner.defaultItemBuilder(context, '${index + 1}');
                      },
                    ),
                    SizedBox(width: 4),
                    Text('day(s)'),
                  ],
                ),
              ),
              SizedBox(width: 4),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: _handleOk,
              ),
              SizedBox(width: 6),
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
