import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';

typedef InvoiceBuilder = Widget Function(BuildContext context, Invoice invoice);

class InvoiceBindingListenerBuilder extends StatefulWidget {
  const InvoiceBindingListenerBuilder({
    Key key,
    this.builder,
  }) : super(key: key);

  final InvoiceBuilder builder;

  @override
  _InvoiceBindingListenerBuilderState createState() => _InvoiceBindingListenerBuilderState();
}

class _InvoiceBindingListenerBuilderState extends State<InvoiceBindingListenerBuilder> {
  InvoiceBindingListener _listener;
  Invoice _invoice;

  void _handleInvoiceChanged(Invoice oldInvoice) {
    setState(() {
      _invoice = InvoiceBinding.instance.invoice;
    });
  }

  @override
  void initState() {
    super.initState();
    _invoice = InvoiceBinding.instance.invoice;
    _listener = InvoiceBindingListener(onInvoiceChanged: _handleInvoiceChanged);
    InvoiceBinding.instance.addListener(_listener);
  }

  @override
  void dispose() {
    InvoiceBinding.instance.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _invoice);
  }
}
