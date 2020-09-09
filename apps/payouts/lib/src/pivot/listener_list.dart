import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef ListenerVisitor<T> = void Function(T listener);

class _ListenerEntry<T> extends LinkedListEntry<_ListenerEntry<T>> {
  _ListenerEntry(this.listener);
  final T listener;
}

mixin ListenerNotifier<T> {
  LinkedList<_ListenerEntry<T>> _listeners = LinkedList<_ListenerEntry<T>>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError(
            'A $runtimeType was used after being disposed.\n'
                'Once you have called dispose() on a $runtimeType, it can no longer be used.'
        );
      }
      return true;
    }());
    return true;
  }

  void addListener(T listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(_ListenerEntry<T>(listener));
  }

  void removeListener(T listener) {
    assert(_debugAssertNotDisposed());
    for (final _ListenerEntry<T> entry in _listeners) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  @protected
  void notifyListeners(ListenerVisitor<T> visitor) {
    assert(_debugAssertNotDisposed());
    if (_listeners.isEmpty)
      return;

    final List<_ListenerEntry<T>> localListeners = List<_ListenerEntry<T>>.from(_listeners);

    for (final _ListenerEntry<T> entry in localListeners) {
      try {
        if (entry.list != null) {
          visitor(entry.listener);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'pivot library',
          context: ErrorDescription('while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ListenerNotifier<T>>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }
}
