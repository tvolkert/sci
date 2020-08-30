import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Ink, Theme;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/pivot.dart' as pivot;

import 'accomplishments_view.dart';
import 'expense_reports_view.dart';
import 'invoice_builder.dart';
import 'review.dart';
import 'timesheets_view.dart';

class InvoiceView extends StatelessWidget {
  const InvoiceView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InvoiceListenerBuilder(
      builder: (BuildContext context, Invoice invoice) {
        // TODO: Remove Ink when it's no longer needed.
        return Ink(
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
                        child: TimesheetsView(),
                      ),
                      pivot.Tab(
                        label: 'Expense Reports',
                        child: ExpenseReportsView(),
                      ),
                      pivot.Tab(
                        label: 'Accomplishments',
                        child: AccomplishmentsView(),
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
        );
      },
    );
  }
}
