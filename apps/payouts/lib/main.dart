import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/src/ui/asset_image_precache.dart';
import 'package:payouts/src/ui/home.dart';

import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/common/task_monitor.dart';

const LogicalKeyboardKey _meta = LogicalKeyboardKey.meta;

void main() {
  FlutterError.onError = (FlutterErrorDetails details, {bool forceReport = false}) {
    FlutterError.dumpErrorToConsole(details, forceReport: true);
  };

  runApp(
    pivot.NavigatorListener(
      child: PayoutsApp(),
    ),
  );
}

class PayoutsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payouts',
      theme: ThemeData(
        brightness: Brightness.light,
        visualDensity: VisualDensity.compact,
        primaryColor: const Color(0xFFC8C8BB),
        accentColor: const Color(0xFFF7F5EE),
        scaffoldBackgroundColor: const Color(0xFFF7F5EE),
        fontFamily: 'Dialog',
        textTheme: const TextTheme(
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
        LogicalKeySet(_meta, LogicalKeyboardKey.keyN): const CreateInvoiceIntent(),
        LogicalKeySet(_meta, LogicalKeyboardKey.keyD): const DeleteInvoiceIntent(),
        LogicalKeySet(_meta, LogicalKeyboardKey.keyE): const ExportInvoiceIntent(),
        LogicalKeySet(_meta, LogicalKeyboardKey.keyO): const OpenInvoiceIntent(),
        LogicalKeySet(_meta, LogicalKeyboardKey.keyS): const SaveInvoiceIntent(),
      },
      navigatorObservers: <NavigatorObserver>[
        pivot.NavigatorListener.of(context).observer,
      ],
      home: const AssetImagePrecache(
        child: PayoutsScaffold(),
        paths: <String>[
          'assets/document-new.png',
          'assets/document-open.png',
          'assets/media-floppy.png',
          'assets/dialog-cancel.png',
          'assets/x-office-presentation.png',
        ],
      ),
    );
  }
}

class PayoutsScaffold extends StatelessWidget {
  const PayoutsScaffold({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: remove Material if and when it is no longer needed
    return const Material(
      type: MaterialType.transparency,
      child: TaskMonitor(
        child: RequireUser(
          child: PayoutsHome(),
        ),
      ),
    );
  }
}
