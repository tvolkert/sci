// @dart=2.9

import 'package:flutter/foundation.dart';

@immutable
class Pair<T> {
  const Pair(this.first, this.second);

  factory Pair.fromIterable(Iterable<T> iterable) {
    assert(iterable.length == 2);
    return Pair<T>(iterable.first, iterable.last);
  }

  final T first;
  final T second;
}
