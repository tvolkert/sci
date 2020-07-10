import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

class LinearGradientDecoration extends Decoration {
  const LinearGradientDecoration({
    this.axis = Axis.vertical,
    @required this.from,
    @required this.to,
    @required this.fromColor,
    @required this.toColor,
    this.backgroundBlendMode,
  })  : assert(from != null),
        assert(to != null),
        assert(fromColor != null),
        assert(toColor != null);

  final Axis axis;
  final Offset from;
  final Offset to;
  final Color fromColor;
  final Color toColor;

  /// The blend mode applied to the [gradient] background of the box.
  ///
  /// If no [backgroundBlendMode] is provided, then the default painting blend
  /// mode is used.
  final BlendMode backgroundBlendMode;

  /// Returns a new box decoration that is scaled by the given factor.
  LinearGradientDecoration scale(double factor) {
    return LinearGradientDecoration(
      from: from,
      to: to,
      fromColor: Color.lerp(null, fromColor, factor),
      toColor: Color.lerp(null, toColor, factor),
      backgroundBlendMode: backgroundBlendMode,
    );
  }

  @override
  LinearGradientDecoration lerpFrom(Decoration a, double t) {
    if (a == null) return scale(t);
    if (a is LinearGradientDecoration) return LinearGradientDecoration.lerp(a, this, t);
    return super.lerpFrom(a, t) as LinearGradientDecoration;
  }

  @override
  LinearGradientDecoration lerpTo(Decoration b, double t) {
    if (b == null) return scale(1.0 - t);
    if (b is LinearGradientDecoration) return LinearGradientDecoration.lerp(this, b, t);
    return super.lerpTo(b, t) as LinearGradientDecoration;
  }

  /// Linearly interpolate between two box decorations.
  ///
  /// Interpolates each parameter of the box decoration separately.
  ///
  /// The [shape] is not interpolated. To interpolate the shape, consider using
  /// a [ShapeDecoration] with different border shapes.
  ///
  /// If both values are null, this returns null. Otherwise, it returns a
  /// non-null value. If one of the values is null, then the result is obtained
  /// by applying [scale] to the other value. If neither value is null and `t ==
  /// 0.0`, then `a` is returned unmodified; if `t == 1.0` then `b` is returned
  /// unmodified. Otherwise, the values are computed by interpolating the
  /// properties appropriately.
  ///
  /// {@macro dart.ui.shadow.lerp}
  ///
  /// See also:
  ///
  ///  * [Decoration.lerp], which can interpolate between any two types of
  ///    [Decoration]s, not just [BoxDecoration]s.
  ///  * [lerpFrom] and [lerpTo], which are used to implement [Decoration.lerp]
  ///    and which use [BoxDecoration.lerp] when interpolating two
  ///    [BoxDecoration]s or a [BoxDecoration] to or from null.
  static LinearGradientDecoration lerp(LinearGradientDecoration a, LinearGradientDecoration b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null) return b.scale(t);
    if (b == null) return a.scale(1.0 - t);
    if (t == 0.0) return a;
    if (t == 1.0) return b;
    return LinearGradientDecoration(
      from: Offset.lerp(a.from, b.from, t),
      to: Offset.lerp(a.to, b.to, t),
      fromColor: Color.lerp(a.fromColor, b.fromColor, t),
      toColor: Color.lerp(a.toColor, b.toColor, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LinearGradientDecoration &&
        other.from == from &&
        other.to == to &&
        other.fromColor == fromColor &&
        other.toColor == toColor;
  }

  @override
  int get hashCode {
    return hashValues(from, to, fromColor, toColor);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.whitespace
      ..emptyBodyDescription = '<no decorations specified>';

    properties.add(DiagnosticsProperty<Offset>('from', from));
    properties.add(DiagnosticsProperty<Offset>('to', to));
    properties.add(ColorProperty('fromColor', fromColor, defaultValue: null));
    properties.add(ColorProperty('toColor', toColor, defaultValue: null));
  }

  @override
  _LinearGradientPainter createBoxPainter([VoidCallback onChanged]) {
    throw _LinearGradientPainter(this, onChanged);
  }
}

/// An object that paints a [LinearGradientDecoration] into a canvas.
class _LinearGradientPainter extends BoxPainter {
  _LinearGradientPainter(this._decoration, VoidCallback onChanged)
      : assert(_decoration != null),
        super(onChanged);

  final LinearGradientDecoration _decoration;

  Paint _cachedBackgroundPaint;
  Rect _rectForCachedBackgroundPaint;
  Paint _getBackgroundPaint(Rect rect, TextDirection textDirection) {
    assert(rect != null);

    if (_cachedBackgroundPaint == null || _rectForCachedBackgroundPaint != rect) {
      final Paint paint = Paint();
      if (_decoration.backgroundBlendMode != null) paint.blendMode = _decoration.backgroundBlendMode;
      paint.shader = ui.Gradient.linear(
        _decoration.from,
        _decoration.to,
        <Color>[_decoration.fromColor, _decoration.toColor],
      );
      _rectForCachedBackgroundPaint = rect;
      _cachedBackgroundPaint = paint;
    }

    return _cachedBackgroundPaint;
  }

  void _paintBackgroundColor(Canvas canvas, Rect rect, TextDirection textDirection) {
    canvas.drawRect(rect, _getBackgroundPaint(rect, textDirection));
  }

  /// Paint the box decoration into the given location on the given canvas
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;
    _paintBackgroundColor(canvas, rect, textDirection);
  }

  @override
  String toString() {
    return 'BoxPainter for $_decoration';
  }
}
