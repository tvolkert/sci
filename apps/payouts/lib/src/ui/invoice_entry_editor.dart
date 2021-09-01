import 'package:chicago/chicago.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/localizations.dart';

class InvoiceEntryTextField {
  /// Creates a new [InvoiceEntryTextField].
  ///
  /// Instances must be disposed of by calling [dispose] before they are made
  /// ready to be garbage collected.
  InvoiceEntryTextField() {
    this.controller = TextEditingController();
    this.focusNode = FocusNode();
  }

  Flag? flag;
  late TextEditingController controller;
  late FocusNode focusNode;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

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
  Flag? _programFlag;
  late ListViewSelectionController _programSelectionController;
  bool _programIsReadOnly = false;
  late InvoiceEntryTextField _chargeNumber;
  late InvoiceEntryTextField _requestor;
  late InvoiceEntryTextField _task;

  Widget _buildProgramButtonData(BuildContext context, Program? item, bool isForMeasurementOnly) {
    return ListButton.defaultBuilder(
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
    return ListButton.defaultItemBuilder(
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
    handleProgramSelected();
  }

  @protected
  @nonVirtual
  FormPaneField buildTextFormField(
    InvoiceEntryTextField field,
    String label, {
    bool isOptional = false,
  }) {
    Widget child = TextInput(
      backgroundColor: const Color(0xfff7f5ee),
      controller: field.controller,
      focusNode: field.focusNode,
    );
    if (isOptional) {
      child = Row(
        children: [
          Expanded(child: child),
          SizedBox(width: 4),
          Text('(optional)'),
        ],
      );
    }
    return FormPaneField(
      label: label,
      flag: field.flag,
      child: child,
    );
  }

  @protected
  @nonVirtual
  bool validateRequiredField(InvoiceEntryTextField field) {
    if (field.controller.text.trim().isEmpty) {
      final String errorMessage = PayoutsLocalizations.of(context).requiredField;
      setState(() {
        field.flag = flagFromMessage(errorMessage);
      });
      field.focusNode.requestFocus();
      return false;
    } else {
      if (field.flag != null) {
        setState(() {
          field.flag = null;
        });
      }
      return true;
    }
  }

  @protected
  @mustCallSuper
  void handleProgramSelected() {}

  @protected
  void handleOk();

  @protected
  List<FormPaneField> buildFormFields();

  @protected
  @nonVirtual
  Flag? flagFromMessage(String? message) {
    return message == null
        ? null
        : Flag(
            messageType: MessageType.error,
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
  ListViewSelectionController get programSelectionController => _programSelectionController;

  @protected
  @nonVirtual
  Program? get selectedProgram {
    return _programSelectionController.selectedIndex >= 0
        ? _assignments[_programSelectionController.selectedIndex]
        : null;
  }

  @protected
  @nonVirtual
  Flag? get programFlag => _programFlag;

  @protected
  @nonVirtual
  set programFlag(Flag? flag) {
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
  InvoiceEntryTextField get chargeNumber => _chargeNumber;

  @protected
  @nonVirtual
  set chargeNumberFlag(Flag? flag) {
    if (flag != _chargeNumber.flag) {
      setState(() {
        _chargeNumber.flag = flag;
      });
    }
  }

  @protected
  @nonVirtual
  bool get requiresRequestor => _requiresRequestor;

  @protected
  @nonVirtual
  InvoiceEntryTextField get requestor => _requestor;

  @protected
  @nonVirtual
  set requestorFlag(Flag? flag) {
    if (flag != _requestor.flag) {
      setState(() {
        _requestor.flag = flag;
      });
    }
  }

  @protected
  @nonVirtual
  InvoiceEntryTextField get task => _task;

  @protected
  @nonVirtual
  FormPaneField buildProgramFormField() {
    return FormPaneField(
      label: 'Program',
      flag: _programFlag,
      child: ListButton<Program>(
        width: ListButtonWidth.shrinkWrapAllItems,
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
  FormPaneField buildChargeNumberFormField() => buildTextFormField(_chargeNumber, 'Charge Number');

  @protected
  @nonVirtual
  FormPaneField buildRequestorFormField() => buildTextFormField(_requestor, 'Requestor (Client)');

  @protected
  @nonVirtual
  FormPaneField buildTaskFormField() => buildTextFormField(_task, 'Task', isOptional: true);

  @override
  @protected
  void initState() {
    super.initState();
    _assignments = AssignmentsBinding.instance!.assignments!;
    _programSelectionController = ListViewSelectionController();
    _programSelectionController.addListener(_handleProgramSelected);
    _chargeNumber = InvoiceEntryTextField();
    _requestor = InvoiceEntryTextField();
    _task = InvoiceEntryTextField();
  }

  @override
  @protected
  void dispose() {
    _programSelectionController.removeListener(_handleProgramSelected);
    _programSelectionController.dispose();
    _chargeNumber.dispose();
    _requestor.dispose();
    _task.dispose();
    super.dispose();
  }

  @override
  @protected
  @nonVirtual
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BorderPane(
            backgroundColor: const Color(0xffffffff),
            borderColor: const Color(0xff999999),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: FormPane(children: buildFormFields()),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CommandPushButton(
                label: 'OK',
                onPressed: handleOk,
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
