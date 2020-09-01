import 'dart:math' as math;

/// Rounds the specified [value] to the specified number of significant digits.
///
/// For example, `roundToSignificantDigits(1.234567, 2)` will return `1.23`.
double roundToSignificantDigits(double value, int significantDigits) {
  int rounder = math.pow(10, significantDigits);
  return (value * rounder).roundToDouble() / rounder;
}
