import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class SegmentConstraints extends BoxConstraints {
  const SegmentConstraints({
    double minWidth = 0,
    double maxWidth = double.infinity,
    double minHeight = 0,
    double maxHeight = double.infinity,
    this.viewport,
  }) : super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  SegmentConstraints.fromBoxConstraints({
    BoxConstraints boxConstraints,
    this.viewport,
  }) : super(
          minWidth: boxConstraints.minWidth,
          maxWidth: boxConstraints.maxWidth,
          minHeight: boxConstraints.minHeight,
          maxHeight: boxConstraints.maxHeight,
        );

  final Rect viewport;

  BoxConstraints asBoxConstraints() {
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    return other is SegmentConstraints && super == other && other.viewport == viewport;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(super.hashCode, viewport);
  }

  @override
  String toString() {
    return 'SegmentConstraints(base=${super.toString()}, viewport=$viewport)';
  }
}

abstract class RenderSegment extends RenderBox {
  @override
  SegmentConstraints get constraints {
    final BoxConstraints constraints = super.constraints;
    assert(() {
      if (constraints is! SegmentConstraints) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: 'RenderSegment was given constraints other than SegmentConstraints',
          stack: StackTrace.current,
          library: 'pivot',
        ));
      }
      return true;
    }());
    return constraints as SegmentConstraints;
  }
}
