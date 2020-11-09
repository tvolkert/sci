import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Ink, Theme;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:payouts/src/model/constants.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/pivot.dart' as pivot;

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
  late bool _isSubmitted; // ignore: unused_field
  late double _total;

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
    setState(() => _isSubmitted = invoice.isSubmitted);
  }

  static Widget _buildTimesheetsView(BuildContext context) => TimesheetsView();
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
    InvoiceBinding.instance!.addListener(_listener);
  }

  @override
  void dispose() {
    print('disposing invoice view');
    InvoiceBinding.instance!.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InvoiceListenerBuilder(
      builder: (BuildContext context, Invoice? invoice) {
        // TODO: Remove Ink when it's no longer needed.
        return Ink(
          decoration: const BoxDecoration(color: Color(0xffc8c8bb)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5.5, 5),
                child: SizedBox(
                  height: 32,
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
                  child: pivot.TabPane(
                    initialSelectedIndex: 0,
                    tabs: <pivot.Tab>[
                      pivot.Tab(
                        label: 'Billable Hours',
                        builder: _buildTimesheetsView,
                      ),
                      pivot.Tab(
                        label: 'Expense Reports',
                        builder: _buildExpenseReportsView,
                      ),
                      pivot.Tab(
                        label: 'Accomplishments',
                        builder: _buildAccomplishmentsView,
                      ),
                      pivot.Tab(
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
      },
    );
  }
}

class InvoiceNumberEditor extends StatefulWidget {
  const InvoiceNumberEditor({Key? key}) : super(key: key);

  @override
  _InvoiceNumberEditorState createState() => _InvoiceNumberEditorState();
}

class _InvoiceNumberEditorState extends State<InvoiceNumberEditor> {
  late InvoiceListener _listener;
  TextEditingController? _invoiceNumberEditor;
  late bool _isSubmitted;
  late String _invoiceNumber;

  Invoice get invoice => InvoiceBinding.instance!.invoice!;

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
    if (_invoiceNumberEditor == null) {
      setState(() => _invoiceNumberEditor = TextEditingController(text: _invoiceNumber));
    } else {
      _handleSaveEdit();
    }
  }

  void _handleSaveEdit() {
    invoice.invoiceNumber = _invoiceNumberEditor!.text;
    setState(() => _invoiceNumberEditor = null);
  }

  void _handleCancelEdit() {
    setState(() => _invoiceNumberEditor = null);
  }

  void _handleEditKeyEvent(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _handleSaveEdit();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _handleCancelEdit();
    }
  }

  @override
  void initState() {
    super.initState();
    _listener = InvoiceListener(
      onInvoiceOpened: _handleInvoiceOpened,
      onInvoiceNumberChanged: _handleInvoiceNumberChanged,
      onSubmitted: _handleSubmittedChanged,
    );
    final Invoice invoice = this.invoice;
    _isSubmitted = invoice.isSubmitted;
    _invoiceNumber = invoice.invoiceNumber;
    InvoiceBinding.instance!.addListener(_listener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
    _invoiceNumberEditor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget view;
    if (_invoiceNumberEditor == null) {
      view = Transform.translate(
        offset: Offset(0, -1),
        child: Text(
          _invoiceNumber,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      view = SizedBox(
        width: 100,
        child: pivot.TextInput(
          controller: _invoiceNumberEditor,
          autofocus: true,
          onKeyEvent: _handleEditKeyEvent,
        ),
      );
    }

    return Row(
      children: [
        view,
        SizedBox(
          height: 22,
          width: 23,
          child: pivot.PushButton(
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
