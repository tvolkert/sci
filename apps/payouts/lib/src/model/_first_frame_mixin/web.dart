import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart';

mixin FirstFrameMixin {
  @protected
  @mustCallSuper
  void handleFirstFrame(Duration timeStamp) {
    html.document.getElementById('splashscreen')?.remove();
  }
}
