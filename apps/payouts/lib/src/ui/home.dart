import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/pivot.dart' as pivot;

import 'accomplishments.dart';
import 'expenses.dart';
import 'hours.dart';
import 'review.dart';

class PayoutsHome extends StatelessWidget {
  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'about':
        Actions.invoke(context, AboutIntent(context: context));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[Color(0xffc8c8bb), Color(0xffdddcd5)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 2, 8, 3),
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
                  SizedBox(width: 5),
                  pivot.ActionPushButton<OpenInvoiceIntent>(
                    icon: 'assets/document-open.png',
                    label: 'Open Invoice',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: OpenInvoiceIntent(context: context),
                  ),
                  SizedBox(width: 5),
                  pivot.ActionPushButton<SaveInvoiceIntent>(
                    icon: 'assets/media-floppy.png',
                    label: 'Save to Server',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: SaveInvoiceIntent(context: context),
                  ),
                  SizedBox(width: 5),
                  pivot.ActionPushButton<DeleteInvoiceIntent>(
                    icon: 'assets/dialog-cancel.png',
                    label: 'Delete Invoice',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: DeleteInvoiceIntent(context: context),
                  ),
                  SizedBox(width: 5),
                  pivot.ActionPushButton<ExportInvoiceIntent>(
                    icon: 'assets/x-office-presentation.png',
                    label: 'Export to PDF',
                    axis: Axis.vertical,
                    isToolbar: true,
                    intent: ExportInvoiceIntent(context: context),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 64,
                    child: pivot.PushButton<String>(
                      onPressed: () {},
                      icon: 'assets/help-browser.png',
                      label: 'Help',
                      axis: Axis.vertical,
                      isToolbar: true,
                      menuItems: <PopupMenuEntry<String>>[
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
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Color(0xff999999),
        ),
        Expanded(
          child: Ink(
            decoration: BoxDecoration(color: Color(0xffc8c8bb)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5.5, 5),
                  child: SizedBox(
                    height: 22,
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: Offset(0, -1),
                          child: Text(
                            'FOO',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        HoverPushButton(
                          iconName: 'assets/pencil.png',
                          onPressed: () {},
                        ),
                        Transform.translate(
                          offset: Offset(0, -1),
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('(10/12/2015 - 10/25/2015)'),
                          ),
                        ),
                        Spacer(),
                        Transform.translate(
                          offset: Offset(0, -1),
                          child: Text(r'Total Check Amount: $5,296.63'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 6, 4),
                    child: pivot.TabPane(
                      initialSelectedIndex: 0,
                      tabs: <pivot.Tab>[
                        pivot.Tab(
                          label: 'Billable Hours',
                          child: BillableHours(),
                        ),
                        pivot.Tab(
                          label: 'Expense Reports',
                          child: ExpenseReports(),
                        ),
                        pivot.Tab(
                          label: 'Accomplishments',
                          child: Accomplishments(),
                        ),
                        pivot.Tab(
                          label: 'Review & Submit',
                          child: ReviewAndSubmit(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HoverPushButton extends StatefulWidget {
  const HoverPushButton({
    @required this.iconName,
    @required this.onPressed,
    Key key,
  })  : assert(iconName != null),
        super(key: key);

  final String iconName;
  final VoidCallback onPressed;

  @override
  _HoverPushButtonState createState() => _HoverPushButtonState();
}

class _HoverPushButtonState extends State<HoverPushButton> {
  bool highlighted = false;

  @override
  Widget build(BuildContext context) {
    Widget button = FlatButton(
      color: Colors.transparent,
      hoverColor: Colors.transparent,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: widget.onPressed,
      child: Image.asset(widget.iconName),
    );

    if (highlighted) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xffdddcd5), Color(0xfff3f2eb)],
          ),
        ),
        child: button,
      );
    }

    return ButtonTheme(
      shape: highlighted ? Border.all(color: Color(0xff999999)) : Border(),
      minWidth: 1,
      height: 16,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: MouseRegion(
        onEnter: (PointerEnterEvent event) {
          setState(() {
            highlighted = true;
          });
        },
        onExit: (PointerExitEvent event) {
          setState(() {
            highlighted = false;
          });
        },
        child: button,
      ),
    );
  }
}
