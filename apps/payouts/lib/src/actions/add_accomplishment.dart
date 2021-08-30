import 'dart:async';

import 'package:chicago/chicago.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/track_invoice_mixin.dart';

class AddAccomplishmentIntent extends Intent {
  const AddAccomplishmentIntent({this.context});

  final BuildContext? context;
}

class AddAccomplishmentAction extends ContextAction<AddAccomplishmentIntent> with TrackInvoiceMixin {
  AddAccomplishmentAction._() {
    startTrackingInvoiceActivity();
  }

  static final AddAccomplishmentAction instance = AddAccomplishmentAction._();

  @override
  void onInvoiceOpenedChanged() {
    super.onInvoiceOpenedChanged();
    notifyActionListeners();
  }

  @override
  void onInvoiceSubmittedChanged() {
    super.onInvoiceSubmittedChanged();
    notifyActionListeners();
  }

  @override
  bool isEnabled(AddAccomplishmentIntent intent) {
    return isInvoiceOpened && !openedInvoice.isSubmitted;
  }

  @override
  Future<void> invoke(AddAccomplishmentIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    final Program? program = await AddAccomplishmentSheet.open(
      context: context,
    );
    if (program != null) {
      InvoiceBinding.instance!.invoice!.accomplishments.add(program: program);
    }
  }
}

class AddAccomplishmentSheet extends StatefulWidget {
  const AddAccomplishmentSheet({Key? key}) : super(key: key);

  @override
  AddAccomplishmentSheetState createState() => AddAccomplishmentSheetState();

  static Future<Program?> open({
    required BuildContext context,
  }) {
    return Sheet.open<Program>(
      context: context,
      content: AddAccomplishmentSheet(),
      barrierDismissible: true,
    );
  }
}

class AddAccomplishmentSheetState extends State<AddAccomplishmentSheet> {
  late List<Program> _assignments;
  late ListViewSelectionController _programSelectionController;
  Flag? _programFlag;
  String? _errorText;

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

  Program? get _selectedProgram {
    return _programSelectionController.selectedIndex >= 0
        ? _assignments[_programSelectionController.selectedIndex]
        : null;
  }

  void _handleOk() {
    bool isInputValid = true;

    final Program? selectedProgram = _selectedProgram;

    setState(() {
      _errorText = null;
    });

    if (selectedProgram == null) {
      isInputValid = false;
      setState(() {
        _programFlag = Flag(
          messageType: MessageType.error,
          message: 'TODO',
        );
      });
    } else {
      setState(() {
        _programFlag = null;
      });
    }

    if (isInputValid) {
      if (InvoiceBinding.instance!.invoice!.accomplishments.indexOf(selectedProgram!) >= 0) {
        setState(() {
          _errorText = 'Only one accomplishment entry is allowed per program. Note that you '
              'may write as much as you want in each entry.';
        });
        isInputValid = false;
      }

      if (isInputValid) {
        Navigator.of(context).pop<Program>(selectedProgram);
      }
    }

    if (!isInputValid) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  @protected
  void initState() {
    super.initState();
    _assignments = AssignmentsBinding.instance!.assignments!;
    _programSelectionController = ListViewSelectionController();
  }

  @override
  @protected
  void dispose() {
    _programSelectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    label: 'Program',
                    flag: _programFlag,
                    child: ListButton<Program>(
                      width: ListButtonWidth.shrinkWrapAllItems,
                      items: _assignments,
                      selectionController: _programSelectionController,
                      builder: _buildProgramButtonData,
                      itemBuilder: _buildProgramListItem,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_errorText != null) ...<Widget>[
            SizedBox(height: 8),
            DefaultTextStyle.merge(
              style: TextStyle(color: const Color(0xffb0000f)),
              child: Text(_errorText!),
            ),
          ],
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
