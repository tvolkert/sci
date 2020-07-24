import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class ExportInvoiceIntent extends Intent {
  const ExportInvoiceIntent({this.context});

  final BuildContext context;
}

class ExportInvoiceAction extends ContextAction<ExportInvoiceIntent> {
  @override
  Future<void> invoke(ExportInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await ExportInvoiceSheet.open(context: context);
    print('TODO: export invoice');
  }
}

class ExportInvoiceSheet extends StatefulWidget {
  const ExportInvoiceSheet({Key key}) : super(key: key);

  @override
  _ExportInvoiceSheetState createState() => _ExportInvoiceSheetState();

  static Future<void> open({BuildContext context}) {
    return pivot.Sheet.open<void>(
      context: context,
      content: ExportInvoiceSheet(),
    );
  }
}

class _ExportInvoiceSheetState extends State<ExportInvoiceSheet> {
  @override
  void initState() {
    super.initState();
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
