import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/pivot.dart' as pivot;

abstract class InvoiceEntryEditor extends StatefulWidget {
  const InvoiceEntryEditor({Key? key}) : super(key: key);

  @override
  @protected
  InvoiceEntryEditorState createState();
}

abstract class InvoiceEntryEditorState<T extends InvoiceEntryEditor> extends State<T> {
  late List<Program> _assignments;
  bool _requiresChargeNumber = false;
  bool _requiresRequestor = false;
  pivot.Flag? _programFlag;
  pivot.Flag? _chargeNumberFlag;
  pivot.Flag? _requestorFlag;
  late pivot.ListViewSelectionController _programSelectionController;
  late TextEditingController _chargeNumberController;
  late TextEditingController _requestorController;
  late TextEditingController _taskController;
  bool _programIsReadOnly = false;

  Widget _buildProgramButtonData(BuildContext context, Program? item, bool isForMeasurementOnly) {
    return pivot.ListButton.defaultBuilder(
      context,
      item == null ? '' : item.name,
      isForMeasurementOnly,
    );
  }

  Widget _buildProgramListItem(
    BuildContext context,
    Program item,
    bool isSelected,
    bool isHighlighted,
    bool isDisabled,
  ) {
    return pivot.ListButton.defaultItemBuilder(
      context,
      item.name,
      isSelected,
      isHighlighted,
      isDisabled,
    );
  }

  void _handleProgramSelected() {
    final Program selectedProgram = this.selectedProgram!;
    setState(() {
      _requiresChargeNumber = selectedProgram.requiresChargeNumber;
      _requiresRequestor = selectedProgram.requiresRequestor;
    });
  }

  @protected
  void handleOk();

  @protected
  List<pivot.FormField> buildFormFields();

  @protected
  @nonVirtual
  pivot.Flag? flagFromMessage(String? message) {
    return message == null ? null : pivot.Flag(
      messageType: pivot.MessageType.error,
      message: message,
    );
  }

  @protected
  @nonVirtual
  List<Program> get assignments => _assignments;

  @protected
  @nonVirtual
  bool get programIsReadOnly => _programIsReadOnly;

  @protected
  @nonVirtual
  set programIsReadOnly(bool value) {
    if (value != _programIsReadOnly) {
      setState(() {
        _programIsReadOnly = value;
      });
    }
  }

  @protected
  @nonVirtual
  pivot.ListViewSelectionController get programSelectionController => _programSelectionController;

  @protected
  @nonVirtual
  Program? get selectedProgram {
    return _programSelectionController.selectedIndex >= 0
        ? _assignments[_programSelectionController.selectedIndex]
        : null;
  }

  @protected
  @nonVirtual
  pivot.Flag? get programFlag => _programFlag;

  @protected
  @nonVirtual
  set programFlag(pivot.Flag? flag) {
    if (flag != _programFlag) {
      setState(() {
        _programFlag = flag;
      });
    }
  }

  @protected
  @nonVirtual
  bool get requiresChargeNumber => _requiresChargeNumber;

  @protected
  @nonVirtual
  TextEditingController get chargeNumberController => _chargeNumberController;

  @protected
  @nonVirtual
  pivot.Flag? get chargeNumberFlag => _chargeNumberFlag;

  @protected
  @nonVirtual
  set chargeNumberFlag(pivot.Flag? flag) {
    if (flag != _chargeNumberFlag) {
      setState(() {
        _chargeNumberFlag = flag;
      });
    }
  }

  @protected
  @nonVirtual
  bool get requiresRequestor => _requiresRequestor;

  @protected
  @nonVirtual
  TextEditingController get requestorController => _requestorController;

  @protected
  @nonVirtual
  pivot.Flag? get requestorFlag => _requestorFlag;

  @protected
  @nonVirtual
  set requestorFlag(pivot.Flag? flag) {
    if (flag != _requestorFlag) {
      setState(() {
        _requestorFlag = flag;
      });
    }
  }

  @protected
  @nonVirtual
  TextEditingController get taskController => _taskController;

  @protected
  @nonVirtual
  pivot.FormField buildProgramFormField() {
    return pivot.FormField(
      label: 'Program',
      flag: _programFlag,
      child: pivot.ListButton<Program>(
        width: pivot.ListButtonWidth.expand,
        items: _assignments,
        selectionController: _programSelectionController,
        builder: _buildProgramButtonData,
        itemBuilder: _buildProgramListItem,
        isEnabled: !_programIsReadOnly,
      ),
    );
  }

  @protected
  @nonVirtual
  pivot.FormField buildChargeNumberFormField() {
    return pivot.FormField(
      label: 'Charge Number',
      flag: _chargeNumberFlag,
      child: pivot.TextInput(
        backgroundColor: const Color(0xfff7f5ee),
        controller: _chargeNumberController,
      ),
    );
  }

  @protected
  @nonVirtual
  pivot.FormField buildRequestorFormField() {
    return pivot.FormField(
      label: 'Requestor (Client)',
      flag: _requestorFlag,
      child: pivot.TextInput(
        backgroundColor: const Color(0xfff7f5ee),
        controller: _requestorController,
      ),
    );
  }

  @protected
  @nonVirtual
  pivot.FormField buildTaskFormField() {
    return pivot.FormField(
      label: 'Task',
      child: Row(
        children: [
          Expanded(
            child: pivot.TextInput(
              backgroundColor: const Color(0xfff7f5ee),
              controller: _taskController,
            ),
          ),
          SizedBox(width: 4),
          Text('(optional)'),
        ],
      ),
    );
  }

  @override
  @protected
  void initState() {
    super.initState();
    _assignments = AssignmentsBinding.instance!.assignments!;
    _programSelectionController = pivot.ListViewSelectionController();
    _programSelectionController.addListener(_handleProgramSelected);
    _chargeNumberController = TextEditingController();
    _requestorController = TextEditingController();
    _taskController = TextEditingController();
  }

  @override
  @protected
  void dispose() {
    _programSelectionController.removeListener(_handleProgramSelected);
    _programSelectionController.dispose();
    _chargeNumberController.dispose();
    _requestorController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  @protected
  @nonVirtual
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
              child: pivot.Form(children: buildFormFields()),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: handleOk,
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
