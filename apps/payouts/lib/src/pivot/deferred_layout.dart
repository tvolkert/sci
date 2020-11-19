import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Mixin that allows subclasses to defer [markNeedsLayout] calls until the
/// next transient frame callback.
///
/// See also:
///
///  * https://github.com/flutter/flutter/issues/64661, which describes when
///    this might be necessary.
mixin DeferredLayoutMixin on RenderObject {
  bool _needsLayoutDeferred = false;

  @override
  void markNeedsLayout() {
    if (!_deferMarkNeedsLayout) {
      super.markNeedsLayout();
    } else if (!_needsLayoutDeferred) {
      _needsLayoutDeferred = true;
      SchedulerBinding.instance!.scheduleFrameCallback((Duration timeStamp) {
        if (_needsLayoutDeferred) {
          _needsLayoutDeferred = false;
          super.markNeedsLayout();
        }
      });
    }
  }

  bool _deferMarkNeedsLayout = false;

  void deferMarkNeedsLayout(VoidCallback callback) {
    assert(!_deferMarkNeedsLayout);
    _deferMarkNeedsLayout = true;
    try {
      callback();
    } finally {
      _deferMarkNeedsLayout = false;
    }
  }
}
