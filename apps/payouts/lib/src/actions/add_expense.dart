import 'dart:async';

import 'package:chicago/chicago.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';
import 'package:payouts/src/widgets/expense_type_list_button.dart';
import 'package:payouts/src/widgets/text_input_validators.dart';

class AddExpenseIntent extends Intent {
  const AddExpenseIntent({this.context, required this.expenseReport});

  final BuildContext? context;
  final ExpenseReport expenseReport;
}

class AddExpenseAction extends ContextAction<AddExpenseIntent> with TrackInvoiceMixin {
  AddExpenseAction._() {
    startTrackingInvoiceActivity();
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
    return !openedInvoice.isSubmitted;
  }

  @override
  Future<void> invoke(AddExpenseIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final AddExpenseMetadata? metadata = await AddExpenseSheet.open(
      context: context,
      expenseReport: intent.expenseReport,
    );
    if (metadata != null) {
      for (int i = 0; i < metadata.count; i++) {
        intent.expenseReport.expenses.add(metadata.expenseMetadata.copyWith(
          ordinal: metadata.expenseMetadata.ordinal + i,
          date: metadata.expenseMetadata.date.add(Duration(days: i)),
        ));
      }
    }
  }
}

class AddExpenseMetadata {
  const AddExpenseMetadata({
    required this.expenseMetadata,
    required this.count,
  });

  final ExpenseMetadata expenseMetadata;
  final int count;
}

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    Key? key,
    required this.expenseReport,
  }) : super(key: key);

  final ExpenseReport expenseReport;

  @override
  AddExpenseSheetState createState() => AddExpenseSheetState();

  static Future<AddExpenseMetadata?> open({
    required BuildContext context,
    required ExpenseReport expenseReport,
  }) {
    return Sheet.open<AddExpenseMetadata>(
      context: context,
      content: AddExpenseSheet(expenseReport: expenseReport),
      barrierDismissible: true,
    );
  }
}

class AddExpenseSheetState extends State<AddExpenseSheet> {
  late ExpenseTypeListButtonController _expenseTypeController;
  late CalendarSelectionController _dateController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late SpinnerController _copyController;
  Flag? _expenseTypeFlag;
  Flag? _dateFlag;
  Flag? _amountFlag;
  bool _copyExpenses = false;

  bool _isDateOutOfRange(CalendarDate date) {
    final CalendarDate today = CalendarDate.today();
    final DateTime earliest = widget.expenseReport.period.start.subtract(const Duration(days: 90));
    return date > today || date < CalendarDate.fromDateTime(earliest);
  }

  void _handleToggleCopyExpenses() {
    setState(() {
      _copyExpenses = !_copyExpenses;
    });
  }

  void _handleOk() {
    bool isInputValid = true;

    if (_expenseTypeController.value == null) {
      isInputValid = false;
      setState(() {
        _expenseTypeFlag = Flag(
          messageType: MessageType.error,
          message: 'TODO',
        );
      });
    } else {
      setState(() {
        _expenseTypeFlag = null;
      });
    }

    if (_dateController.value == null) {
      isInputValid = false;
      setState(() {
        _dateFlag = Flag(
          messageType: MessageType.error,
          message: 'TODO',
        );
      });
    } else {
      setState(() {
        _dateFlag = null;
      });
    }

    if (_amountController.text.isEmpty) {
      isInputValid = false;
      setState(() {
        _amountFlag = Flag(
          messageType: MessageType.error,
          message: 'TODO',
        );
      });
    } else {
      setState(() {
        _amountFlag = null;
      });
    }

    if (isInputValid) {
      final ExpenseMetadata metadata = ExpenseMetadata(
        ordinal: widget.expenseReport.expenses.length,
        date: _dateController.value!.toDateTime(),
        type: _expenseTypeController.value!,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
      );
      final AddExpenseMetadata addExpenseMetadata = AddExpenseMetadata(
        expenseMetadata: metadata,
        count: _copyExpenses ? _copyController.selectedIndex + 1 : 1,
      );

      Navigator.of(context).pop<AddExpenseMetadata>(addExpenseMetadata);
    }

    if (!isInputValid) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void initState() {
    super.initState();
    _expenseTypeController = ExpenseTypeListButtonController();
    _dateController = CalendarSelectionController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _copyController = SpinnerController()..selectedIndex = 0;
  }

  @override
  void dispose() {
    _expenseTypeController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _copyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CalendarDate startDate = CalendarDate.fromDateTime(widget.expenseReport.period.start);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 370),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BorderPane(
            backgroundColor: const Color(0xffffffff),
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: FormPane(
                children: <FormPaneField>[
                  FormPaneField(
                    label: 'Category',
                    flag: _expenseTypeFlag,
                    child: ExpenseTypeListButton(
                      expenseReport: widget.expenseReport,
                      controller: _expenseTypeController,
                    ),
                  ),
                  FormPaneField(
                    label: 'Date',
                    flag: _dateFlag,
                    child: CalendarButton(
                      selectionController: _dateController,
                      initialMonth: startDate.month,
                      initialYear: startDate.year,
                      width: CalendarButtonWidth.shrinkWrap,
                      disabledDateFilter: _isDateOutOfRange,
                    ),
                  ),
                  FormPaneField(
                    label: 'Amount',
                    flag: _amountFlag,
                    child: SizedBox(
                      width: 180,
                      child: TextInput(
                        controller: _amountController,
                        validator: TextInputValidators.validateCurrency,
                        backgroundColor: const Color(0xfff7f5ee),
                      ),
                    ),
                  ),
                  FormPaneField(
                    label: 'Description',
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: TextInput(
                            controller: _descriptionController,
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
              BasicCheckbox(
                state: _copyExpenses ? CheckboxState.checked : CheckboxState.unchecked,
                onTap: _handleToggleCopyExpenses,
                spacing: 4,
                trailing: Text('Copy this expense for a total of'),
              ),
              SizedBox(width: 4),
              Spinner(
                isEnabled: _copyExpenses,
                controller: _copyController,
                sizeToContent: true,
                length: 14,
                itemBuilder: (BuildContext context, int index, bool isEnabled) {
                  Widget built = Spinner.defaultItemBuilder(context, '${index + 1}');
                  if (!isEnabled) {
                    built = DefaultTextStyle.merge(
                      style: const TextStyle(color: Color(0xff999999)),
                      child: built,
                    );
                  }
                  return built;
                },
              ),
              SizedBox(width: 4),
              Text('day(s)'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CommandPushButton(
                label: 'OK',
                onPressed: _handleOk,
              ),
              SizedBox(width: 6),
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
