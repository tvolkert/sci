import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Ink, Theme;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:payouts/src/model/constants.dart';
import 'package:payouts/src/model/invoice.dart';

import 'accomplishments_view.dart';
import 'currency_text.dart';
import 'expense_reports_view.dart';
import 'invoice_builder.dart';
import 'review.dart';
import 'timesheets_view.dart';

class InvoiceView extends StatefulWidget {
  const InvoiceView({Key? key}) : super(key: key);

  @override
  _InvoiceViewState createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<InvoiceView> {
  late InvoiceListener _listener;
  late bool _isSubmitted;
  late double _total;
  WatermarkPainter? _watermarkPainter;

  Invoice get invoice => InvoiceBinding.instance!.invoice!;

  void _handleInvoiceOpened(Invoice? previousInvoice) {
    setState(() {
      _total = invoice.total;
      _isSubmitted = invoice.isSubmitted;
    });
  }

  void _handleInvoiceTotalChanged(double previousTotal) {
    setState(() => _total = invoice.total);
  }

  void _handleSubmittedChanged() {
    setState(() {
      _isSubmitted = invoice.isSubmitted;
      _updateWatermarkPainter();
    });
  }

  void _updateWatermarkPainter() {
    if (_isSubmitted) {
      _watermarkPainter ??= WatermarkPainter('Submitted');
    } else {
      _watermarkPainter = null;
    }
  }

  static Widget _buildTimesheetsView(BuildContext context) => const TimesheetsView();
  static Widget _buildExpenseReportsView(BuildContext context) => ExpenseReportsView();
  static Widget _buildAccomplishmentsView(BuildContext context) => AccomplishmentsView();
  static Widget _buildReviewAndSubmit(BuildContext context) => ReviewAndSubmit();

  @override
  void initState() {
    super.initState();
    _listener = InvoiceListener(
      onInvoiceOpened: _handleInvoiceOpened,
      onInvoiceTotalChanged: _handleInvoiceTotalChanged,
      onSubmitted: _handleSubmittedChanged,
    );
    final Invoice invoice = this.invoice;
    _isSubmitted = invoice.isSubmitted;
    _total = invoice.total;
    _updateWatermarkPainter();
    InvoiceBinding.instance!.addListener(_listener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InvoiceListenerBuilder(
      builder: (BuildContext context, Invoice? invoice) {
        assert(invoice != null);

        // TODO: Remove Ink when it's no longer needed.
        Widget result = Ink(
          decoration: const BoxDecoration(color: Color(0xffc8c8bb)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5.5, 5),
                child: SizedBox(
                  height: 22,
                  child: Row(
                    children: [
                      const InvoiceNumberEditor(),
                      BillingPeriodView(invoice!.billingPeriod),
                      const Spacer(),
                      InvoiceTotalView(total: _total),
                    ],
                  ),
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 6, 4),
                  child: chicago.TabPane(
                    initialSelectedIndex: 0,
                    tabs: <chicago.Tab>[
                      chicago.Tab(
                        label: 'Billable Hours',
                        builder: _buildTimesheetsView,
                      ),
                      chicago.Tab(
                        label: 'Expense Reports',
                        builder: _buildExpenseReportsView,
                      ),
                      chicago.Tab(
                        label: 'Accomplishments',
                        builder: _buildAccomplishmentsView,
                      ),
                      chicago.Tab(
                        label: 'Review & Submit',
                        builder: _buildReviewAndSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        if (_isSubmitted) {
          result = CustomPaint(
            foregroundPainter: _watermarkPainter,
            child: result,
          );
        }

        return result;
      },
    );
  }
}

class WatermarkPainter extends CustomPainter {
  WatermarkPainter(String watermark) : paragraph = _paragraphFor(watermark);

  final ui.Paragraph paragraph;

  static const double theta = math.pi / 4;

  static ui.Paragraph _paragraphFor(String text) {
    final ui.ParagraphStyle paragraphStyle = ui.ParagraphStyle(
      fontFamily: 'Verdana',
      fontSize: 60,
      fontWeight: ui.FontWeight.bold,
    );
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(color: const Color(0x13000000)))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: double.infinity));
    return paragraph;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double sinTheta = math.sin(theta);
    double cosTheta = math.cos(theta);

    canvas.clipRect(Offset.zero & size);
    canvas.rotate(theta);

    // Calculate the separation in between each repetition of the watermark
    double dx = 1.5 * paragraph.longestLine;
    double dy = 2 * paragraph.height;

    // Prepare the origin of our graphics context
    double x = 0;
    double y = -size.width * sinTheta;
    canvas.translate(x, y);

    for (double yStop = size.height * cosTheta, p = 0; y < yStop; y += dy, p = 1 - p) {
      for (double xStop = size.height * sinTheta + size.width * cosTheta; x < xStop; x += dx) {
        canvas.drawParagraph(paragraph, Offset.zero);
        canvas.translate(dx, 0);
      }

      // Move X origin back to its starting position & Y origin down
      canvas.translate(-x, dy);
      x = 0;

      // Shift the x back and forth to add randomness feel to pattern
      canvas.translate((0.5 - p) * paragraph.longestLine, 0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InvoiceNumberEditor extends StatefulWidget {
  const InvoiceNumberEditor({Key? key}) : super(key: key);

  @override
  _InvoiceNumberEditorState createState() => _InvoiceNumberEditorState();
}

class _InvoiceNumberEditorState extends State<InvoiceNumberEditor> {
  late InvoiceListener _listener;
  TextEditingController? _invoiceNumberEditor;
  late FocusNode _focusNode;
  late bool _isSubmitted;
  late String _invoiceNumber;

  Invoice get invoice => InvoiceBinding.instance!.invoice!;

  bool get isEditing => _invoiceNumberEditor != null;

  void _handleInvoiceOpened(Invoice? previousInvoice) {
    setState(() {
      _invoiceNumber = invoice.invoiceNumber;
      _isSubmitted = invoice.isSubmitted;
    });
  }

  void _handleInvoiceNumberChanged(String previousInvoiceNumber) {
    setState(() => _invoiceNumber = invoice.invoiceNumber);
  }

  void _handleSubmittedChanged() {
    setState(() => _isSubmitted = invoice.isSubmitted);
  }

  void _handleToggleEdit() {
    if (isEditing) {
      _handleSaveEdit();
    } else {
      _handleInitiateEdit();
    }
  }

  void _handleInitiateEdit() {
    assert(!isEditing);
    setState(() {
      final TextEditingValue value = TextEditingValue(
        text: _invoiceNumber,
        selection:
        TextSelection(baseOffset: _invoiceNumber.length, extentOffset: _invoiceNumber.length),
      );
      _invoiceNumberEditor = TextEditingController.fromValue(value);
    });
    SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      _focusNode.requestFocus();
    });
  }

  void _handleSaveEdit() {
    assert(isEditing);
    invoice.invoiceNumber = _invoiceNumberEditor!.text;
    setState(() => _invoiceNumberEditor = null);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _handleCancelEdit() {
    assert(isEditing);
    setState(() => _invoiceNumberEditor = null);
  }

  void _handleEditKeyEvent(RawKeyEvent event) {
    if (isEditing && event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleSaveEdit();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleCancelEdit();
      }
    }
  }

  Widget _buildCrossFadeChildren(Widget top, Key topKey, Widget bottom, Key bottomKey) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Positioned(
          left: 0.0,
          right: 0.0,
          key: bottomKey,
          child: bottom,
        ),
        Positioned(
          key: topKey,
          child: top,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _listener = InvoiceListener(
      onInvoiceOpened: _handleInvoiceOpened,
      onInvoiceNumberChanged: _handleInvoiceNumberChanged,
      onSubmitted: _handleSubmittedChanged,
    );
    _focusNode = FocusNode();
    final Invoice invoice = this.invoice;
    _isSubmitted = invoice.isSubmitted;
    _invoiceNumber = invoice.invoiceNumber;
    InvoiceBinding.instance!.addListener(_listener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
    _focusNode.dispose();
    _invoiceNumberEditor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedCrossFade(
          alignment: Alignment.centerLeft,
          crossFadeState: isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          layoutBuilder: _buildCrossFadeChildren,
          firstChild: Transform.translate(
            offset: Offset(0, -1),
            child: Text(
              _invoiceNumber,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          secondChild: SizedBox(
            width: 100,
            child: chicago.TextInput(
              controller: _invoiceNumberEditor,
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: _handleEditKeyEvent,
            ),
          ),
        ),
        SizedBox(
          height: 22,
          width: 23,
          child: chicago.PushButton(
            padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
            icon: 'assets/pencil.png',
            showTooltip: false,
            isToolbar: true,
            onPressed: _isSubmitted ? null : _handleToggleEdit,
          ),
        ),
      ],
    );
  }
}

class BillingPeriodView extends StatelessWidget {
  BillingPeriodView(DateRange billingPeriod) : child = _createChild(billingPeriod);

  final Widget child;

  static Widget _createChild(DateRange billingPeriod) {
    StringBuffer buf = StringBuffer()
      ..write('(')
      ..write(DateFormats.mmddyyyy.format(billingPeriod.start))
      ..write(' - ')
      ..write(DateFormats.mmddyyyy.format(billingPeriod.end))
      ..write(')');
    return Text(buf.toString(), maxLines: 1, softWrap: false);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -1),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: child,
      ),
    );
  }
}

class InvoiceTotalView extends StatelessWidget {
  const InvoiceTotalView({
    Key? key,
    required this.total,
  }) : super(key: key);

  final double total;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -1),
      child: CurrencyText(
        prefix: 'Total Check Amount: ',
        amount: total,
      ),
    );
  }
}
