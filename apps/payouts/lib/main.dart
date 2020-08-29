import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/src/ui/home.dart';

import 'package:payouts/ui/auth/persistent_credentials.dart';
import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/auth/user_binding.dart';
import 'package:payouts/ui/common/task_monitor.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_home.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details, {bool forceReport = false}) =>
      FlutterError.dumpErrorToConsole(details, forceReport: true);
  runApp(
//    BugReport(),
    pivot.NavigatorListener(
      child: PayoutsApp(),
    ),
  );
}

bool relicatedUi = true;

class PayoutsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (relicatedUi) {
      return MaterialApp(
        title: 'Payouts',
        theme: ThemeData(
          brightness: Brightness.light,
          visualDensity: VisualDensity.compact,
          primaryColor: Color(0xFFC8C8BB),
          accentColor: Color(0xFFF7F5EE),
          scaffoldBackgroundColor: Color(0xFFF7F5EE),
          fontFamily: 'Dialog',
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 11.0, fontFamily: 'Verdana'),
            subtitle1: TextStyle(fontSize: 11.0, fontFamily: 'Verdana'),
          ),
        ),
        actions: <Type, Action<Intent>>{
          ...WidgetsApp.defaultActions,
          AboutIntent: AboutAction(),
          AddTimesheetIntent: AddTimesheetAction(),
          CreateInvoiceIntent: CreateInvoiceAction(),
          DeleteInvoiceIntent: DeleteInvoiceAction(),
          ExportInvoiceIntent: ExportInvoiceAction(),
          LoginIntent: LoginAction(),
          OpenInvoiceIntent: OpenInvoiceAction(),
          SaveInvoiceIntent: SaveInvoiceAction(),
        },
        shortcuts: <LogicalKeySet, Intent>{
          ...WidgetsApp.defaultShortcuts,
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): CreateInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyD): DeleteInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyE): ExportInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyO): OpenInvoiceIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS): SaveInvoiceIntent(),
        },
        navigatorObservers: [
          pivot.NavigatorListener.of(context).observer,
        ],
        home: PayoutsScaffold(),
      );
    } else {
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
}

class PayoutsScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: TaskMonitor(
        child: RequireUser(
          child: PayoutsHome(),
        ),
      ),
    );
  }
}
