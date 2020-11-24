import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:payouts/src/actions.dart';
import 'package:payouts/src/model/debug.dart';
import 'package:payouts/src/model/payouts.dart';
import 'package:payouts/src/pivot.dart' as pivot;
import 'package:payouts/src/ui/asset_image_precache.dart';
import 'package:payouts/src/ui/home.dart';

import 'package:payouts/ui/auth/require_user.dart';
import 'package:payouts/ui/common/task_monitor.dart';

const LogicalKeyboardKey _meta = LogicalKeyboardKey.meta;

void main() {
  PayoutsBinding.ensureInitialized();
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
  static final Map<Type, Action<Intent>> defaultActions = <Type, Action<Intent>>{
    AboutIntent: AboutAction.instance,
    CreateInvoiceIntent: CreateInvoiceAction.instance,
    DeleteInvoiceIntent: DeleteInvoiceAction.instance,
    ExportInvoiceIntent: ExportInvoiceAction.instance,
    LoginIntent: LoginAction.instance,
    OpenInvoiceIntent: OpenInvoiceAction.instance,
    SaveInvoiceIntent: SaveInvoiceAction.instance,
  };

  static final Map<LogicalKeySet, Intent> defaultShortcuts = <LogicalKeySet, Intent>{
    LogicalKeySet(_meta, LogicalKeyboardKey.keyN): const CreateInvoiceIntent(),
    LogicalKeySet(_meta, LogicalKeyboardKey.keyD): const DeleteInvoiceIntent(),
    LogicalKeySet(_meta, LogicalKeyboardKey.keyE): const ExportInvoiceIntent(),
    LogicalKeySet(_meta, LogicalKeyboardKey.keyO): const OpenInvoiceIntent(),
    LogicalKeySet(_meta, LogicalKeyboardKey.keyS): const SaveInvoiceIntent(),
  };

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
        ...defaultActions,
      },
      shortcuts: <LogicalKeySet, Intent>{
        ...WidgetsApp.defaultShortcuts,
        ...defaultShortcuts,
      },
      navigatorObservers: <NavigatorObserver>[
        pivot.NavigatorListener.of(context).observer,
      ],
      home: const AssetImagePrecache(
        child: PayoutsScaffold(),
        paths: <String>[
          'assets/cross.png',
          'assets/dialog-cancel.png',
          'assets/document-new.png',
          'assets/document-open.png',
          'assets/media-floppy.png',
          'assets/money_add.png',
          'assets/pencil.png',
          'assets/table_add.png',
          'assets/x-office-presentation.png',
        ],
      ),
    );
  }
}

class PayoutsScaffold extends StatelessWidget {
  const PayoutsScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: remove Material if and when it is no longer needed
    Widget result = const TaskMonitor(
      child: RequireUser(
        child: PayoutsHome(),
      ),
    );

    if (debugUseFakeHttpLayer) {
      result = Banner(
        location: BannerLocation.topStart,
        message: 'FAKE DATA',
        child: result,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: result,
    );
  }
}
