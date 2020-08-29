import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';

import 'invoice.dart';
import 'toolbar.dart';

class PayoutsHome extends StatefulWidget {
  @override
  _PayoutsHomeState createState() => _PayoutsHomeState();
}

class _PayoutsHomeState extends State<PayoutsHome> {
  InvoiceBindingListener _listener;

  void _handleInvoiceChanged(Invoice oldInvoice) {
    setState(() {});
  }

  bool get _shouldShowInvoice => InvoiceBinding.instance.invoice != null;

  @override
  void initState() {
    super.initState();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Toolbar(),
        Divider(
          height: 1,
          thickness: 1,
          color: Color(0xff999999),
        ),
        Expanded(
          child: _shouldShowInvoice ? InvoiceView() : _InvoiceArea(),
        ),
      ],
    );
  }
}

class _InvoiceArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xffc8c8bb)
      ),
    );
  }
}
