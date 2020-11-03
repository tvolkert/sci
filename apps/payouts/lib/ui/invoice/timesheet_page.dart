// @dart=2.9

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart' as ib;
import 'package:payouts/ui/invoice/invoice_scaffold.dart';

class TimesheetPage extends StatefulWidget {
  TimesheetPage({Key key, this.timesheet}) : super(key: key);

  final Map<String, dynamic> timesheet;

  @override
  State<StatefulWidget> createState() {
    return _TimesheetPageState();
  }
}

class _TimesheetPageState extends State<TimesheetPage> {
  @override
  Widget build(BuildContext context) {
    Invoice invoice = ib.InvoiceBinding.of(context).invoice;
    DateTime billingStart = invoice.billingPeriod.start;
    int billingDuration = invoice.billingPeriod.length;
    return InvoiceScaffold(
      body: ListView.builder(
        //itemExtent: 60,
        itemCount: billingDuration,
        itemBuilder: (BuildContext context, int index) {
          DateTime day = billingStart.add(Duration(days: index));
          DateFormat dayOfWeek = DateFormat('EEEE');
          DateFormat dayOfMonth = DateFormat('d');
          DateFormat monthAndYear = DateFormat('MMM yyyy');
          double value = widget.timesheet['hours'][index].toDouble();
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white,
                  Theme.of(context).buttonColor,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Row(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        color: Color.fromARGB(0xff, 0x77, 0x77, 0x77),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                          maxWidth: 55,
                          maxHeight: 50,
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              '${dayOfMonth.format(day)}',
                              style: DefaultTextStyle.of(context).style.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Color.fromARGB(0xff, 0xf9, 0xb2, 0x60),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 90),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${dayOfWeek.format(day)}',
                              style: DefaultTextStyle.of(context).style.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                            Text(
                              '${monthAndYear.format(day)}',
                              style: DefaultTextStyle.of(context).style.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        label: '${NumberFormat('0.00').format(value)}',
                        value: value,
                        min: 0,
                        max: 8,
                        divisions: 32,
                        onChanged: (double value) {
                          List<num> hours = widget.timesheet['hours'].cast<num>();
                          setState(() {
                            hours[index] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
