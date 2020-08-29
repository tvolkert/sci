import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:payouts/src/pivot.dart';

typedef ValueAddedHandler<K, V> = void Function(Map<K, V> map, K key);

typedef ValueUpdatedHandler<K, V> = void Function(Map<K, V> map, K key, V previousValue);

typedef ValueRemovedHandler<K, V> = void Function(Map<K, V> map, K key, V value);

typedef MapClearedHandler<K, V> = void Function(Map<K, V> map);

class MapListener<K, V> {
  const MapListener({
    this.onValueAdded,
    this.onValueUpdated,
    this.onValueRemoved,
    this.onCleared,
  });

  final ValueAddedHandler<K, V> onValueAdded;

  final ValueUpdatedHandler<K, V> onValueUpdated;

  final ValueRemovedHandler<K, V> onValueRemoved;

  final MapClearedHandler<K, V> onCleared;
}

mixin MapListenerNotifier<K, V> on ListenerNotifier<MapListener<K, V>> implements Map<K, V> {
  @protected
  void onValueAdded(K key) {
    notifyListeners((MapListener<K, V> listener) {
      if (listener.onValueAdded != null) {
        listener.onValueAdded(this, key);
      }
    });
  }

  @protected
  void onValueUpdated(K key, V previousValue) {
    notifyListeners((MapListener<K, V> listener) {
      if (listener.onValueUpdated != null) {
        listener.onValueUpdated(this, key, previousValue);
      }
    });
  }

  @protected
  void onValueRemoved(K key, V value) {
    notifyListeners((MapListener<K, V> listener) {
      if (listener.onValueRemoved != null) {
        listener.onValueRemoved(this, key, value);
      }
    });
  }

  @protected
  void onCleared() {
    notifyListeners((MapListener<K, V> listener) {
      if (listener.onCleared != null) {
        listener.onCleared(this);
      }
    });
  }
}

class NotifyingMap<K, V>
    with ListenerNotifier<MapListener<K, V>>, MapListenerNotifier<K, V>
    implements Map<K, V> {
  NotifyingMap(this.delegate);

  final Map<K, V> delegate;

  @override
  V operator [](Object key) => delegate[key];

  @override
  void operator []=(K key, V value) {
    final bool update = containsKey(key);
    V previousValue = delegate[key];
    delegate[key] = value;

    if (!update) {
      onValueAdded(key);
    } else if (value != previousValue) {
      onValueUpdated(key, previousValue);
    }
  }

  @override
  void addAll(Map<K, V> other) {
    for (MapEntry<K, V> entry in other.entries) {
      this[entry.key] = entry.value;
    }
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    for (MapEntry<K, V> entry in newEntries) {
      this[entry.key] = entry.value;
    }
  }

  @override
  NotifyingMap<RK, RV> cast<RK, RV>() {
    final Map<RK, RV> castMap = Map.castFrom<K, V, RK, RV>(this);
    return NotifyingMap<RK, RV>(castMap);
  }

  @override
  void clear() {
    if (!isEmpty) {
      delegate.clear();
      onCleared();
    }
  }

  @override
  bool containsKey(Object key) => delegate.containsKey(key);

  @override
  bool containsValue(Object value) => delegate.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => delegate.entries;

  @override
  void forEach(void Function(K key, V value) f) => delegate.forEach(f);

  @override
  bool get isEmpty => delegate.isEmpty;

  @override
  bool get isNotEmpty => delegate.isNotEmpty;

  @override
  Iterable<K> get keys => delegate.keys;

  @override
  int get length => delegate.length;

  @override
  NotifyingMap<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) f) {
    final Map<K2, V2> delegate2 = delegate.map<K2, V2>(f);
    return NotifyingMap<K2, V2>(delegate2);
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    if (containsKey(key)) {
      return this[key];
    }
    final V value = ifAbsent();
    this[key] = value;
    return value;
  }

  @override
  V remove(Object key) {
    V value;
    if (containsKey(key)) {
      value = delegate.remove(key);
      onValueRemoved(key, value);
    }
    return value;
  }

  @override
  void removeWhere(bool Function(K key, V value) predicate) {
    for (MapEntry<K, V> entry in entries.toList()) {
      if (predicate(entry.key, entry.value)) {
        remove(entry.key);
      }
    }
  }

  @override
  V update(K key, V Function(V value) update, {V Function() ifAbsent}) {
    V newValue;
    if (containsKey(key)) {
      newValue = update(this[key]);
    } else if (ifAbsent != null) {
      newValue = ifAbsent();
    } else {
      assert(false);
    }
    this[key] = newValue;
    return newValue;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    for (MapEntry<K, V> entry in entries.toList()) {
      V newValue = update(entry.key, entry.value);
      this[entry.key] = newValue;
    }
  }

  @override
  Iterable<V> get values => delegate.values;
}

/// Called when items in a [NotifyingList] are updated.
///
/// The `index` argument specifies the first affected index.
///
/// The `removedItems` argument specifies the items that have been removed
/// from the list (starting at `index`).
///
/// The `insertedCount` argument specifies how many new items were added in
/// place of the old items.
///
/// The pure insertion of items is a degenerate case whereby `removedItems`
/// will be empty.  Likewise, the pure removal of items is a degenerate case
/// whereby `insertedCount` will be zero.
///
/// See also:
///
///  * [ListListener.onItemsUpdated], the listener property that callers use to
///    register for these notifications.
typedef ItemsUpdatedHandler<T> = void Function(
  NotifyingList<T> list,
  int index,
  Iterable<T> removedItems,
  int insertedCount,
);

/// Called when a [NotifyingList] has been cleared and is now empty.
///
/// See also:
///
///  * [ListListener.onCleared], the listener property that callers use to
///    register for these notifications.
typedef ListClearedHandler<T> = void Function(NotifyingList<T> list);

/// Called when the order of the items in a [NotifyingList] has changed, but
/// the set of items in the list has not.
///
/// The ordering that triggers this event is unspecified. For example, this
/// will be called both when the list is shuffled and when it's sorted.
///
/// See also:
///
///  * [ListListener.onReordered], the listener property that callers use to
///    register for these notifications.
typedef ListReorderedHandler<T> = void Function(NotifyingList<T> list);

/// A class that can register to be notified for events fired by
/// [NotifyingList].
///
/// See also:
///
///  * [NotifyingList.addListener], which accepts instances of this class as
///    listeners.
class ListListener<T> {
  const ListListener({
    this.onItemsUpdated,
    this.onCleared,
    this.onReordered,
  });

  final ItemsUpdatedHandler<T> onItemsUpdated;

  final ListClearedHandler<T> onCleared;

  final ListReorderedHandler<T> onReordered;
}

mixin ListListenerNotifier<T> on ListenerNotifier<ListListener<T>> implements List<T> {
  @protected
  void onItemsUpdated(int index, Iterable<T> removedItems, int insertedCount) {
    notifyListeners((ListListener<T> listener) {
      if (listener.onItemsUpdated != null) {
        listener.onItemsUpdated(this as NotifyingList<T>, index, removedItems, insertedCount);
      }
    });
  }

  @protected
  void onCleared() {
    notifyListeners((ListListener<T> listener) {
      if (listener.onCleared != null) {
        listener.onCleared(this as NotifyingList<T>);
      }
    });
  }

  @protected
  void onReordered() {
    notifyListeners((ListListener<T> listener) {
      if (listener.onReordered != null) {
        listener.onReordered(this as NotifyingList<T>);
      }
    });
  }
}

class NotifyingList<T>
    with ListenerNotifier<ListListener<T>>, ListListenerNotifier<T>
    implements List<T> {
  NotifyingList(this.delegate);

  final List<T> delegate;

  @override
  T get first => delegate.first;
  set first(T value) {
    final T previousItem = first;
    delegate.first = value;
    onItemsUpdated(0, <T>[previousItem], 1);
  }

  @override
  T get last => delegate.last;
  set last(T value) {
    final T previousItem = last;
    delegate.last = value;
    onItemsUpdated(length - 1, <T>[previousItem], 1);
  }

  @override
  int get length => delegate.length;
  set length(int value) {
    final int previousLength = length;
    if (value < previousLength) {
      final Iterable<T> previousItems = sublist(value);
      delegate.length = value;
      onItemsUpdated(value, previousItems, 0);
    } else if (value > previousLength) {
      delegate.length = value;
      onItemsUpdated(previousLength, <T>[], value - previousLength);
    }
  }

  @override
  NotifyingList<T> operator +(List<T> other) {
    final List<T> concatenation = delegate + other;
    return NotifyingList<T>(concatenation);
  }

  @override
  T operator [](int index) => delegate[index];

  @override
  void operator []=(int index, T value) {
    final T previousItem = this[index];
    delegate[index] = value;
    onItemsUpdated(index, <T>[previousItem], 1);
  }

  @override
  void add(T value) {
    delegate.add(value);
    onItemsUpdated(length - 1, <T>[], 1);
  }

  @override
  void addAll(Iterable<T> iterable) {
    final int previousLength = length;
    delegate.addAll(iterable);
    onItemsUpdated(previousLength, <T>[], length - previousLength);
  }

  @override
  bool any(bool Function(T element) test) => delegate.any(test);

  @override
  Map<int, T> asMap() => delegate.asMap();

  @override
  NotifyingList<R> cast<R>() {
    final List<R> castList = List.castFrom<T, R>(this);
    return NotifyingList<R>(castList);
  }

  @override
  void clear() {
    if (!isEmpty) {
      delegate.clear();
      onCleared();
    }
  }

  @override
  bool contains(Object element) => delegate.contains(element);

  @override
  T elementAt(int index) => delegate.elementAt(index);

  @override
  bool every(bool Function(T element) test) => delegate.every(test);

  @override
  Iterable<R> expand<R>(Iterable<R> Function(T element) f) => delegate.expand<R>(f);

  @override
  void fillRange(int start, int end, [T fillValue]) {
    for (int i = start; i < end; i++) {
      this[i] = fillValue;
    }
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function() orElse}) {
    return delegate.firstWhere(test, orElse: orElse);
  }

  @override
  R fold<R>(R initialValue, R Function(R previousValue, T element) combine) {
    return delegate.fold<R>(initialValue, combine);
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) => delegate.followedBy(other);

  @override
  void forEach(void Function(T element) f) {
    delegate.forEach(f);
  }

  @override
  Iterable<T> getRange(int start, int end) => delegate.getRange(start, end);

  @override
  int indexOf(T element, [int start = 0]) => delegate.indexOf(element, start);

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    return delegate.indexWhere(test, start);
  }

  @override
  void insert(int index, T element) {
    delegate.insert(index, element);
    onItemsUpdated(index, <T>[], 1);
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    final int previousLength = length;
    delegate.insertAll(index, iterable);
    onItemsUpdated(index, <T>[], length - previousLength);
  }

  @override
  bool get isEmpty => delegate.isEmpty;

  @override
  bool get isNotEmpty => delegate.isNotEmpty;

  @override
  Iterator<T> get iterator => delegate.iterator;

  @override
  String join([String separator = ""]) => delegate.join(separator);

  @override
  int lastIndexOf(T element, [int start]) => delegate.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(T element) test, [int start]) {
    return delegate.lastIndexWhere(test, start);
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function() orElse}) {
    return delegate.lastWhere(test, orElse: orElse);
  }

  @override
  Iterable<R> map<R>(R Function(T e) f) => delegate.map<R>(f);

  @override
  T reduce(T Function(T value, T element) combine) => delegate.reduce(combine);

  @override
  bool remove(Object value) {
    final int index = indexOf(value);
    if (index >= 0) {
      delegate.removeAt(index);
      onItemsUpdated(index, <T>[value], 0);
      return true;
    }
    return false;
  }

  @override
  T removeAt(int index) {
    final T item = delegate.removeAt(index);
    onItemsUpdated(index, <T>[item], 0);
    return item;
  }

  @override
  T removeLast() {
    final T item = delegate.removeLast();
    onItemsUpdated(length - 1, <T>[item], 0);
    return item;
  }

  @override
  void removeRange(int start, int end) {
    List<T> items = sublist(start, end);
    delegate.removeRange(start, end);
    onItemsUpdated(start, items, 0);
  }

  @override
  void removeWhere(bool Function(T element) test) {
    for (int i = length - 1; i >= 0; i--) {
      final T element = this[i];
      if (test(element)) {
        removeAt(i);
      }
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacement) {
    final List<T> previousItems = sublist(start, end);
    delegate.replaceRange(start, end, replacement);
    onItemsUpdated(start, previousItems, replacement.length);
  }

  @override
  void retainWhere(bool Function(T element) test) {
    for (int i = length - 1; i >= 0; i--) {
      final T element = this[i];
      if (!test(element)) {
        removeAt(i);
      }
    }
  }

  @override
  Iterable<T> get reversed => delegate.reversed;

  @override
  void setAll(int index, Iterable<T> iterable) {
    final int count = iterable.length;
    final List<T> previousItems = sublist(index, index + count);
    delegate.setAll(index, iterable);
    onItemsUpdated(index, previousItems, count);
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    final List<T> previousItems = sublist(start, end);
    delegate.setRange(start, end, iterable, skipCount);
    onItemsUpdated(start, previousItems, end - start);
  }

  @override
  void shuffle([Random random]) {
    delegate.shuffle(random);
    onReordered();
  }

  @override
  T get single => delegate.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function() orElse}) {
    return delegate.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> skip(int count) => delegate.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => delegate.skipWhile(test);

  @override
  void sort([int Function(T a, T b) compare]) {
    delegate.sort(compare);
    onReordered();
  }

  @override
  NotifyingList<T> sublist(int start, [int end]) {
    final List<T> sublist = delegate.sublist(start, end);
    return NotifyingList<T>(sublist);
  }

  @override
  Iterable<T> take(int count) => delegate.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => delegate.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) {
    final List<T> newList = delegate.toList(growable: growable);
    return NotifyingList<T>(newList);
  }

  @override
  Set<T> toSet() => delegate.toSet();

  @override
  Iterable<T> where(bool Function(T element) test) => delegate.where(test);

  @override
  Iterable<R> whereType<R>() => delegate.whereType<R>();
}

mixin ForwardingIterable<T> implements Iterable<T> {
  @protected
  Iterable<T> get delegate;

  @override
  bool any(bool Function(T element) test) => delegate.any(test);

  @override
  Iterable<R> cast<R>() => Iterable.castFrom<T, R>(delegate);

  @override
  bool contains(Object element) => delegate.contains(element);

  @override
  T elementAt(int index) => delegate.elementAt(index);

  @override
  bool every(bool Function(T element) test) => delegate.every(test);

  @override
  Iterable<R> expand<R>(Iterable<R> Function(T element) f) => delegate.expand<R>(f);

  @override
  T get first => delegate.first;

  @override
  T firstWhere(bool Function(T element) test, {T Function() orElse}) {
    return delegate.firstWhere(test, orElse: orElse);
  }

  @override
  R fold<R>(R initialValue, R Function(R previousValue, T element) combine) {
    return delegate.fold<R>(initialValue, combine);
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) => delegate.followedBy(other);

  @override
  void forEach(void Function(T element) f) => delegate.forEach(f);

  @override
  bool get isEmpty => delegate.isEmpty;

  @override
  bool get isNotEmpty => delegate.isNotEmpty;

  @override
  Iterator<T> get iterator => delegate.iterator;

  @override
  String join([String separator = ""]) => delegate.join(separator);

  @override
  T get last => delegate.last;

  @override
  T lastWhere(bool Function(T element) test, {T Function() orElse}) {
    return delegate.lastWhere(test, orElse: orElse);
  }

  @override
  int get length => delegate.length;

  @override
  Iterable<R> map<R>(R Function(T e) f) => delegate.map<R>(f);

  @override
  T reduce(T Function(T value, T element) combine) => delegate.reduce(combine);

  @override
  T get single => delegate.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function() orElse}) {
    return delegate.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> skip(int count) => delegate.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => delegate.skipWhile(test);

  @override
  Iterable<T> take(int count) => delegate.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => delegate.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) => delegate.toList(growable: growable);

  @override
  Set<T> toSet() => delegate.toSet();

  @override
  Iterable<T> where(bool Function(T element) test) => delegate.where(test);

  @override
  Iterable<R> whereType<R>() => delegate.whereType<R>();
}
