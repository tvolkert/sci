import 'package:flutter/material.dart';

import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_home.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details, { bool forceReport = false }) => FlutterError.dumpErrorToConsole(details, forceReport: true);
  runApp(
//    Directionality(
//      textDirection: TextDirection.ltr,
//      child: Table(
//        children: <TableRow>[
//          TableRow(
//            children: <Widget>[
//              RotatedBox(
//                quarterTurns: 1,
//                child: Text('rotated so should be tall, not wide'),
//              ),
//            ],
//          ),
//        ],
//      ),
//    ),
    PayoutsApp(),
  );
}

class PayoutsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payouts',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InvoiceHome(),
      builder: (BuildContext context, Widget child) {
        return UserBinding(
          child: InvoiceBinding(
            child: PersistentCredentials(
              child: RequireUser(
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
