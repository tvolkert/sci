import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter

import 'server_base.dart';

class _Server with ServerBase {
  const _Server._();

  @override
  String get host => html.window.location.hostname!;
}

const _Server Server = _Server._();
