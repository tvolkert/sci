import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';

import 'invoice.dart';
import 'toolbar.dart';

class PayoutsHome extends StatelessWidget {
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
          child: InvoiceView(),
        ),
      ],
    );
  }
}
