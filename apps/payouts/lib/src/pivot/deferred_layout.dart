import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

mixin DeferredLayoutMixin on RenderObject {
  bool _needsLayoutDeferred = false;
  void markNeedsLayoutDeferred() {
    if (!_needsLayoutDeferred) {
      _needsLayoutDeferred = true;
      SchedulerBinding.instance.scheduleFrameCallback((Duration timeStamp) {
        if (_needsLayoutDeferred) {
          _needsLayoutDeferred = false;
          markNeedsLayout();
        }
      });
    }
  }
}
