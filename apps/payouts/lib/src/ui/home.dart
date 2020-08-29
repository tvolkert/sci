import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';

import 'invoice.dart';
import 'invoice_builder.dart';
import 'toolbar.dart';

class PayoutsHome extends StatelessWidget {
  static Widget _buildInvoiceArea(BuildContext context, Invoice invoice) {
    if (invoice != null) {
      return const InvoiceView();
    }
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xffc8c8bb)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Toolbar(),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xff999999),
        ),
        const Expanded(
          child: InvoiceBindingListenerBuilder(
            builder: _buildInvoiceArea,
          ),
        ),
      ],
    );
  }
}
