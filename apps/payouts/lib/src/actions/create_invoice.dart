import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class CreateInvoiceIntent extends Intent {
  const CreateInvoiceIntent({this.context});

  final BuildContext context;
}

class CreateInvoiceAction extends Action<CreateInvoiceIntent> {
  @override
  Future<void> invoke(CreateInvoiceIntent intent) async {
    BuildContext context = intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await CreateInvoiceSheet.open(context: context);
    print('TODO: create invoice');
  }
}

class CreateInvoiceSheet extends StatefulWidget {
  const CreateInvoiceSheet({Key key}) : super(key: key);

  @override
  _CreateInvoiceSheetState createState() => _CreateInvoiceSheetState();

  static Future<void> open({BuildContext context}) {
    return pivot.Sheet.open<void>(
      context: context,
      content: CreateInvoiceSheet(),
    );
  }
}

class _CreateInvoiceSheetState extends State<CreateInvoiceSheet> {
  @override
  void initState() {
    super.initState();
    // TODO: Really fetch billing periods
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              pivot.CommandPushButton(
                label: 'OK',
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 4),
              pivot.CommandPushButton(
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
