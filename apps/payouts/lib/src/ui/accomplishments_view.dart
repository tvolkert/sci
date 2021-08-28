import 'dart:math' as math;

import 'package:chicago/chicago.dart';
import 'package:flutter/material.dart' show InputBorder, InputDecoration, TextField, Theme;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide TableRow;

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/model/invoice.dart';

const double _horizontalContentPadding = 4;
const double _verticalContentPadding = 7;

class AccomplishmentsView extends StatelessWidget {
  const AccomplishmentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        AddAccomplishmentIntent: AddAccomplishmentAction.instance,
      },
      child: const _RawAccomplishmentsView(),
    );
  }
}

class _RawAccomplishmentsView extends StatefulWidget {
  const _RawAccomplishmentsView({Key? key}) : super(key: key);

  @override
  State<_RawAccomplishmentsView> createState() => _RawAccomplishmentsViewState();
}

class _RawAccomplishmentsViewState extends State<_RawAccomplishmentsView> {
  late InvoiceListener _listener;

  void _handleInvoiceOpened(Invoice? oldInvoice) {
    setState(() {}); // Actual state is held in the invoice
  }

  void _handleInvoiceSubmitted() {
    setState(() {}); // Actual state is held in the invoice
  }

  void _handleAccomplishmentInserted(int accomplishmentsIndex) {
    setState(() {}); // Actual state is held in the invoice
  }

  List<TableRow> _buildAccomplishmentRows() {
    final Invoice invoice = InvoiceBinding.instance!.invoice!;
    final Accomplishments accomplishments = invoice.accomplishments;
    return accomplishments.map(_buildAccomplishmentRow).toList();
  }

  TableRow _buildAccomplishmentRow(Accomplishment accomplishment) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(accomplishment.program.name),
        ),
        AccomplishmentsEntryField(
          accomplishment: accomplishment,
          isReadOnly: accomplishment.invoice.isSubmitted,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _listener = InvoiceListener(
      onInvoiceOpened: _handleInvoiceOpened,
      onSubmitted: _handleInvoiceSubmitted,
      onAccomplishmentInserted: _handleAccomplishmentInserted,
    );
    InvoiceBinding.instance!.addListener(_listener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              ActionLinkButton(
                image: AssetImage('assets/note_add.png'),
                text: 'Add accomplishment',
                intent: AddAccomplishmentIntent(context: context),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ScrollPane(
              horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
              view: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: TablePane(
                  horizontalSpacing: 10,
                  verticalSpacing: 10,
                  columns: <TablePaneColumn>[
                    TablePaneColumn(width: IntrinsicTablePaneColumnWidth()),
                    TablePaneColumn(width: RelativeTablePaneColumnWidth()),
                  ],
                  children: _buildAccomplishmentRows(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccomplishmentsEntryField extends StatefulWidget {
  const AccomplishmentsEntryField({
    Key? key,
    required this.accomplishment,
    this.isReadOnly = false,
  }) : super(key: key);

  final Accomplishment accomplishment;
  final bool isReadOnly;

  @override
  _AccomplishmentsEntryFieldState createState() => _AccomplishmentsEntryFieldState();
}

class _AccomplishmentsEntryFieldState extends State<AccomplishmentsEntryField> {
  late TextEditingController _controller;
  late TextEditingValue _lastValue;
  late InvoiceListener _listener;
  TextStyle? _textStyle;

  void _handleTextInput() {
    if (_lastValue.text != _controller.text) {
      widget.accomplishment.description = _controller.text;
    }
    _lastValue = _controller.value;
  }

  void _handleAccomplishmentTextUpdated(int accomplishmentsIndex, String previousDescription) {
    if (widget.accomplishment.index == accomplishmentsIndex) {
      final String updatedText = widget.accomplishment.description;
      if (_controller.text != updatedText) {
        _controller.text = updatedText;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.accomplishment.description);
    _controller.addListener(_handleTextInput);
    _lastValue = _controller.value;
    _listener = InvoiceListener(onAccomplishmentTextUpdated: _handleAccomplishmentTextUpdated);
    InvoiceBinding.instance!.addListener(_listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textStyle = Theme.of(context).textTheme.subtitle1;
  }

  @override
  void didUpdateWidget(covariant AccomplishmentsEntryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accomplishment != oldWidget.accomplishment) {
      _controller.value = TextEditingValue(
        text: widget.accomplishment.description,
      );
      _lastValue = _controller.value;
    }
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
    _controller.removeListener(_handleTextInput);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = ColoredBox(
      color: const Color(0xffffffff),
      child: TextField(
        controller: _controller,
        maxLines: null,
        readOnly: widget.isReadOnly,
        cursorWidth: 1,
        cursorColor: const Color(0xff000000),
        decoration: const InputDecoration(
          filled: false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _horizontalContentPadding,
            vertical: _verticalContentPadding,
          ),
          hoverColor: Color(0x0),
          border: InputBorder.none,
        ),
      ),
    );
    if (!widget.isReadOnly) {
      result = ScrollPane(
        horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
        verticalScrollBarPolicy: ScrollBarPolicy.expand,
        view: _ScrollOnTextEditUpdate(
          controller: _controller,
          textStyle: _textStyle,
          child: result,
        ),
      );
    }
    result = DecoratedBox(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: result,
      ),
    );
    if (!widget.isReadOnly) {
      result = SizedBox(
        height: 150,
        child: result,
      );
    }
    return result;
  }
}

class _ScrollOnTextEditUpdate extends StatefulWidget {
  const _ScrollOnTextEditUpdate({
    required this.controller,
    required this.textStyle,
    required this.child,
  });

  final TextEditingController controller;
  final TextStyle? textStyle;
  final Widget child;

  @override
  State<_ScrollOnTextEditUpdate> createState() => _ScrollOnTextEditUpdateState();
}

class _ScrollOnTextEditUpdateState extends State<_ScrollOnTextEditUpdate> {
  void _handleValueChanged() {
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: widget.textStyle,
        text: widget.controller.text,
      ),
    );
    painter.layout();
    final TextPosition textPosition = widget.controller.selection.extent;
    final Size caretSize = Size(1, painter.preferredLineHeight);
    final Offset caretOffset = painter.getOffsetForCaret(
      textPosition,
      Offset.zero & caretSize,
    );
    final Rect scrollArea = (caretOffset & caretSize).inflate(math.max<double>(
      _horizontalContentPadding,
      _verticalContentPadding,
    ));
    SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      if (mounted) {
        ScrollPane.of(context)!.scrollToVisible(scrollArea, context: context, propagate: false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleValueChanged);
  }

  @override
  void didUpdateWidget(covariant _ScrollOnTextEditUpdate oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.controller == oldWidget.controller);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
