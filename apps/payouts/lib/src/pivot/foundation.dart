import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

int binarySearch<T>(
  List<T> sortedList,
  T value, {
  int Function(T, T) compare,
}) {
  compare ??= _defaultCompare<T>();
  int min = 0;
  int max = sortedList.length;
  while (min < max) {
    int mid = min + ((max - min) >> 1);
    T element = sortedList[mid];
    int comp = compare(element, value);
    if (comp == 0) {
      return mid;
    } else if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return -(min + 1);
}

/// Returns a [Comparator] that asserts that its first argument is comparable.
Comparator<T> _defaultCompare<T>() {
  return (T value1, T value2) => (value1 as Comparable<T>).compareTo(value2);
}

bool isShiftKeyPressed() {
  final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;
  return keys.contains(LogicalKeyboardKey.shiftLeft) ||
      keys.contains(LogicalKeyboardKey.shiftRight);
}

bool isPlatformCommandKeyPressed([TargetPlatform platform]) {
  platform ??= defaultTargetPlatform;
  final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;
  switch (platform) {
    case TargetPlatform.macOS:
      return keys.contains(LogicalKeyboardKey.metaLeft) ||
          keys.contains(LogicalKeyboardKey.metaRight);
    default:
      return keys.contains(LogicalKeyboardKey.controlLeft) ||
          keys.contains(LogicalKeyboardKey.controlRight);
  }
}
