import 'package:chicago/chicago.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/localizations.dart';

typedef SetStateCallback = void Function(VoidCallback callback);

class InvoiceEntryTextField {
  /// Creates a new [InvoiceEntryTextField].
  ///
  /// Instances must be disposed of by calling [dispose] before they are made
  /// ready to be garbage collected.
  InvoiceEntryTextField(this.setState) {
    controller = TextEditingController();
    focusNode = FocusNode();
  }

  final SetStateCallback setState;
  late final TextEditingController controller;
  late final FocusNode focusNode;

  Flag? _flag;
  Flag? get flag => _flag;
  set flag(Flag? value) {
    if (value != _flag) {
      setState(() {
        _flag = value;
      });
    }
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class InvoiceEntryListButtonField<T> {
  /// Creates a new [InvoiceEntryListButtonField].
  ///
  /// Instances must be disposed of by calling [dispose] before they are made
  /// ready to be garbage collected.
  InvoiceEntryListButtonField(this.setState, this.data) {
    controller = ListViewSelectionController();
  }

  final SetStateCallback setState;
  final List<T> data;
  late final ListViewSelectionController controller;

  Flag? _flag;
  Flag? get flag => _flag;
  set flag(Flag? value) {
    if (value != _flag) {
      setState(() {
        _flag = value;
      });
    }
  }

  bool _isReadOnly = false;
  bool get isReadOnly => _isReadOnly;
  set isReadOnly(bool value) {
    if (value != _isReadOnly) {
      setState(() {
        _isReadOnly = value;
      });
    }
  }

  T? get selectedValue {
    return controller.selectedIndex >= 0 ? data[controller.selectedIndex] : null;
  }

  dispose() {
    controller.dispose();
  }
}

abstract class InvoiceEntryEditor extends StatefulWidget {
  const InvoiceEntryEditor({Key? key}) : super(key: key);

  @override
  @protected
  InvoiceEntryEditorState createState();
}

abstract class InvoiceEntryEditorState<T extends InvoiceEntryEditor> extends State<T> {
  bool _requiresChargeNumber = false;
  bool _requiresRequestor = false;
  late InvoiceEntryListButtonField<Program> _program;
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
  void handleProgramSelected() {
    final Program selectedProgram = program.selectedValue!;
    setState(() {
      _requiresChargeNumber = selectedProgram.requiresChargeNumber;
      _requiresRequestor = selectedProgram.requiresRequestor;
      chargeNumber.flag = null;
      requestor.flag = null;
    });
  }

  @protected
  void handleOk();

  @protected
  List<FormPaneField> buildFormFields();

  @protected
  @nonVirtual
  Flag? flagFromMessage(String? message) {
    return message == null ? null : Flag(messageType: MessageType.error, message: message);
  }

  @protected
  @nonVirtual
  InvoiceEntryListButtonField get program => _program;

  @protected
  @nonVirtual
  bool get requiresChargeNumber => _requiresChargeNumber;

  @protected
  @nonVirtual
  InvoiceEntryTextField get chargeNumber => _chargeNumber;

  @protected
  @nonVirtual
  bool get requiresRequestor => _requiresRequestor;

  @protected
  @nonVirtual
  InvoiceEntryTextField get requestor => _requestor;

  @protected
  @nonVirtual
  InvoiceEntryTextField get task => _task;

  @protected
  @nonVirtual
  FormPaneField buildProgramFormField() {
    return FormPaneField(
      label: 'Program',
      flag: _program.flag,
      child: ListButton<Program>(
        width: ListButtonWidth.shrinkWrapAllItems,
        items: _program.data,
        selectionController: _program.controller,
        builder: _buildProgramButtonData,
        itemBuilder: _buildProgramListItem,
        isEnabled: !_program.isReadOnly,
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
    final List<Program> assignments = AssignmentsBinding.instance!.assignments!;
    _program = InvoiceEntryListButtonField<Program>(setState, assignments);
    _program.controller.addListener(handleProgramSelected);
    _chargeNumber = InvoiceEntryTextField(setState);
    _requestor = InvoiceEntryTextField(setState);
    _task = InvoiceEntryTextField(setState);
  }

  @override
  @protected
  void dispose() {
    _program.controller.removeListener(handleProgramSelected);
    _program.dispose();
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
