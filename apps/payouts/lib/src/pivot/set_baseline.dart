import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SetBaseline extends SingleChildRenderObjectWidget {
  SetBaseline({
    Key? key,
    required Widget child,
    required this.baseline,
  }) : super(key: key, child: child);

  final double baseline;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSetBaseline(baseline: baseline);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSetBaseline renderObject) {
    renderObject.baseline = baseline;
  }
}

class RenderSetBaseline extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderSetBaseline({required double baseline}) {
    this.baseline = baseline;
  }

  double? _baseline;
  double get baseline => _baseline!;
  set baseline(double value) {
    if (value == _baseline) return;
    _baseline = value;
    markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return this.baseline;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return child == null ? 0 : child!.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return child == null ? 0 : child!.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return child == null ? 0 : child!.getMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return child == null ? 0 : child!.getMaxIntrinsicHeight(width);
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
    } else {
      performResize();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    if (child == null) return false;
    return child!.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
