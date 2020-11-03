// @dart=2.9

import 'dart:math' as math;

import 'package:flutter/painting.dart';

Color brighten(Color color) {
  return _adjustBrightness(color, 0.1);
}

Color darken(Color color) {
  return _adjustBrightness(color, -0.1);
}

Color _adjustBrightness(Color color, double adjustment) {
  HSVColor hsv = HSVColor.fromColor(color);
  HSVColor adjusted = HSVColor.fromAHSV(
    hsv.alpha,
    hsv.hue,
    hsv.saturation,
    math.min(math.max(hsv.value + adjustment, 0), 1),
  );
  return adjusted.toColor();
}
