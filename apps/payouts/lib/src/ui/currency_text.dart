import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/constants.dart';

class CurrencyText extends StatelessWidget {
  const CurrencyText({
    Key? key,
    this.prefix,
    required this.amount,
  }) : super(key: key);

  final String? prefix;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final StringBuffer buf = StringBuffer();
    buf.writeAll([
      if (prefix != null) prefix,
      NumberFormats.currency.format(amount),
    ]);
    return Text(buf.toString(), maxLines: 1, softWrap: false);
  }
}
