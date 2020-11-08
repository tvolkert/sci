import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';

typedef InvoiceBuilder = Widget Function(BuildContext context, Invoice? invoice);

class InvoiceListenerBuilder extends StatefulWidget {
  const InvoiceListenerBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final InvoiceBuilder builder;

  @override
  _InvoiceListenerBuilderState createState() => _InvoiceListenerBuilderState();
}

class _InvoiceListenerBuilderState extends State<InvoiceListenerBuilder> {
  late InvoiceListener _listener;
  Invoice? _invoice;

  void _handleInvoiceChanged(Invoice? oldInvoice) {
    setState(() {
      _invoice = InvoiceBinding.instance!.invoice;
    });
  }

  @override
  void initState() {
    super.initState();
    _invoice = InvoiceBinding.instance!.invoice;
    _listener = InvoiceListener(onInvoiceChanged: _handleInvoiceChanged);
    InvoiceBinding.instance!.addListener(_listener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance!.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _invoice);
  }
}
