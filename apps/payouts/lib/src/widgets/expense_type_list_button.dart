import 'package:chicago/chicago.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/localizations.dart';

class ExpenseTypeListButtonController extends ValueNotifier<ExpenseType?> {
  ExpenseTypeListButtonController([ExpenseType? value]) : super(value);
}

class ExpenseTypeListButton extends StatefulWidget {
  const ExpenseTypeListButton({
    required this.expenseReport,
    this.width = ListButtonWidth.shrinkWrapAllItems,
    this.controller,
  });

  final ExpenseReport expenseReport;
  final ListButtonWidth width;
  final ExpenseTypeListButtonController? controller;

  @override
  State<ExpenseTypeListButton> createState() => _ExpenseTypeListButtonState();
}

class _ExpenseTypeListButtonState extends State<ExpenseTypeListButton> {
  late List<ExpenseType> _expenseTypes;
  late ListViewSelectionController _controller;

  Widget _buildExpenseType(BuildContext context, ExpenseType? item, bool isForMeasurementOnly) {
    return ListButton.defaultBuilder(
      context,
      item == null ? '' : item.name,
      isForMeasurementOnly,
    );
  }

  Widget _buildExpenseTypeItem(
    BuildContext context,
    ExpenseType item,
    bool isSelected,
    bool isHighlighted,
    bool isDisabled,
  ) {
    String text = item.name;
    if (item.comment != null) {
      final String comment = PayoutsLocalizations.of(context).string(item.comment!);
      text = '$text $comment';
    }
    Widget built = ListButton.defaultItemBuilder(
      context,
      text,
      isSelected,
      isHighlighted,
      isDisabled,
    );
    if (!item.isReimbursable) {
      built = Padding(
        padding: EdgeInsets.only(left: item.depth * 12.toDouble()),
        child: built,
      );
    }
    return built;
  }

  bool _isExpenseTypeIncluded(ExpenseType type) {
    return type.isVisible && type.isReimbursable == widget.expenseReport.program.isBillable;
  }

  void _initExpenseTypes() {
    _expenseTypes = ExpenseTypesBinding.instance!.expenseTypes!
        .where(_isExpenseTypeIncluded)
        .toList()
        ..sort((ExpenseType a, ExpenseType b) => a.longName.compareTo(b.longName));
  }

  void _handleSelectedIndexChanged() {
    if (widget.controller != null) {
      widget.controller!.value = _expenseTypes[_controller.selectedIndex];
    }
  }

  void _handleValueChanged() {
    assert(widget.controller != null);
    final ExpenseType? expenseType = widget.controller!.value;
    if (expenseType == null) {
      _controller.selectedIndex = -1;
    } else {
      _controller.selectedIndex = _expenseTypes.indexOf(expenseType);
    }
  }

  @override
  void initState() {
    super.initState();
    _initExpenseTypes();
    _controller = ListViewSelectionController();
    _controller.addListener(_handleSelectedIndexChanged);
    widget.controller?.addListener(_handleValueChanged);
    if (widget.controller != null) {
      _handleValueChanged();
    }
  }

  @override
  void didUpdateWidget(covariant ExpenseTypeListButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenseReport != oldWidget.expenseReport) {
      _initExpenseTypes();
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleValueChanged);
      widget.controller?.addListener(_handleValueChanged);
      if (widget.controller != null) {
        _handleValueChanged();
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleValueChanged);
    _controller.removeListener(_handleSelectedIndexChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListButton<ExpenseType>(
      selectionController: _controller,
      items: _expenseTypes,
      width: widget.width,
      builder: _buildExpenseType,
      itemBuilder: _buildExpenseTypeItem,
      disabledItemFilter: (ExpenseType type) => !type.isEnabled,
    );
  }
}
