import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/ui/common/task_monitor.dart';

class SaveInvoiceIntent extends Intent {
  const SaveInvoiceIntent({this.context});

  final BuildContext context;
}

class SaveInvoiceAction extends ContextAction<SaveInvoiceIntent> {
  @override
  bool isEnabled(SaveInvoiceIntent intent) {
    // TODO(tvolkert): switch enabled based on whether invoice needs saving.
    return super.isEnabled(intent);
  }

  @override
  Future<void> invoke(SaveInvoiceIntent intent, [BuildContext context]) async {
    context ??= intent.context ?? primaryFocus.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    print('TODO: save invoice');
    bool doError = true;
    final Future<int> saveInvoiceFuture = Future<int>.delayed(const Duration(seconds: 2), () {
      if (doError) {
        throw StateError('uh oh super now I have to deal with trying to read a really long error message');
      }
      return 15;
    });

    try {
      int value = await TaskMonitor.of(context).monitor<int>(
        future: saveInvoiceFuture,
        inProgressMessage: 'Saving invoice...',
        completedMessage: 'Invoice saved',
      );
      print('value in my app: $value');
    } catch (error) {
      print('error in my app: $error');
    }
  }
}

class SaveInvoiceSheet extends StatefulWidget {
  const SaveInvoiceSheet({Key key}) : super(key: key);

  @override
  _SaveInvoiceSheetState createState() => _SaveInvoiceSheetState();

  static Future<void> open({BuildContext context}) {
    return pivot.Sheet.open<void>(
      context: context,
      content: SaveInvoiceSheet(),
    );
  }
}

class _SaveInvoiceSheetState extends State<SaveInvoiceSheet> {
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
