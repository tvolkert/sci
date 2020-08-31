import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show PopupMenuEntry, PopupMenuItem;

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/pivot.dart' as pivot;

class Toolbar extends StatelessWidget {
  const Toolbar({Key key}) : super(key: key);

  static void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'about':
        Actions.invoke(context, AboutIntent(context: context));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[Color(0xffc8c8bb), Color(0xffdddcd5)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 2, 8, 3),
        child: SizedBox(
          height: 57,
          child: Row(
            children: <Widget>[
              pivot.ActionPushButton<CreateInvoiceIntent>(
                icon: 'assets/document-new.png',
                label: 'New Invoice',
                axis: Axis.vertical,
                isToolbar: true,
                intent: CreateInvoiceIntent(context: context),
              ),
              const SizedBox(width: 5),
              pivot.ActionPushButton<OpenInvoiceIntent>(
                icon: 'assets/document-open.png',
                label: 'Open Invoice',
                axis: Axis.vertical,
                isToolbar: true,
                intent: OpenInvoiceIntent(context: context),
              ),
              const SizedBox(width: 5),
              pivot.ActionPushButton<SaveInvoiceIntent>(
                icon: 'assets/media-floppy.png',
                label: 'Save to Server',
                axis: Axis.vertical,
                isToolbar: true,
                intent: SaveInvoiceIntent(context: context),
              ),
              const SizedBox(width: 5),
              pivot.ActionPushButton<DeleteInvoiceIntent>(
                icon: 'assets/dialog-cancel.png',
                label: 'Delete Invoice',
                axis: Axis.vertical,
                isToolbar: true,
                intent: DeleteInvoiceIntent(context: context),
              ),
              const SizedBox(width: 5),
              pivot.ActionPushButton<ExportInvoiceIntent>(
                icon: 'assets/x-office-presentation.png',
                label: 'Export to PDF',
                axis: Axis.vertical,
                isToolbar: true,
                intent: ExportInvoiceIntent(context: context),
              ),
              const Spacer(),
              SizedBox(
                width: 64,
                child: pivot.PushButton<String>(
                  onPressed: () {},
                  icon: 'assets/help-browser.png',
                  label: 'Help',
                  axis: Axis.vertical,
                  isToolbar: true,
                  menuItems: const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'about',
                      height: 22,
                      child: Text('About'),
                    ),
                    PopupMenuItem<String>(
                      value: 'feedback',
                      height: 22,
                      child: Text('Provide feedback'),
                    ),
                  ],
                  onMenuItemSelected: (String value) {
                    _onMenuItemSelected(context, value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
