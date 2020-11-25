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
  void _handleOk() {
    // TODO
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
                children: [],
              ),
            ),
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
