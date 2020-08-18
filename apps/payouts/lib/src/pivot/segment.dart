import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

@immutable
abstract class ViewportResolver {
  Rect resolve(Size size);
}

class StaticViewportResolver implements ViewportResolver {
  const StaticViewportResolver(this.viewport);

  StaticViewportResolver.fromParts({
    @required Offset offset,
    @required Size size,
  })  : assert(offset != null),
        assert(size != null),
        viewport = offset & size;

  final Rect viewport;

  @override
  Rect resolve(Size size) => viewport;
}

class SegmentConstraints extends BoxConstraints {
  const SegmentConstraints({
    double minWidth = 0,
    double maxWidth = double.infinity,
    double minHeight = 0,
    double maxHeight = double.infinity,
    @required this.viewportResolver,
  }) : super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  SegmentConstraints.tightFor({
    double width,
    double height,
    this.viewportResolver,
  }) : super.tightFor(width: width, height: height);

  final ViewportResolver viewportResolver;

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
    if (identical(this, other)) return true;
    return other is SegmentConstraints &&
        super == other &&
        other.viewportResolver == viewportResolver;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(super.hashCode, viewportResolver);
  }

  @override
  String toString() {
    return 'SegmentConstraints(base=${super.toString()}, viewportResolver=$viewportResolver)';
  }
}

abstract class RenderSegment extends RenderBox {
  @override
  SegmentConstraints get constraints {
    final BoxConstraints constraints = super.constraints;
    assert(() {
      if (constraints is! SegmentConstraints) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: 'RenderSegment was given constraints other than FooConstraints',
          stack: StackTrace.current,
          library: 'pivot',
        ));
      }
      return true;
    }());
    return constraints as SegmentConstraints;
  }
}
