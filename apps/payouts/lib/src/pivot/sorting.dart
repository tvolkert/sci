import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

enum SortDirection {
  ascending,
  descending,
}

class SortIndicatorPainter extends CustomPainter {
  const SortIndicatorPainter({
    this.sortDirection,
    this.isAntiAlias = true,
    this.color = const Color(0xff999999),
  });

  final SortDirection sortDirection;
  final bool isAntiAlias;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = isAntiAlias;
    Path path = Path();
    const double zero = 0;
    final double x1 = (size.width - 1) / 2;
    final double x2 = size.width - 1;
    final double y1 = size.height - 1;
    switch (sortDirection) {
      case SortDirection.ascending:
        path
          ..moveTo(zero, y1)
          ..lineTo(x1, zero)
          ..lineTo(x2, y1);
        break;
      case SortDirection.descending:
        path
          ..moveTo(zero, zero)
          ..lineTo(x1, y1)
          ..lineTo(x2, zero);
        break;
    }

    path.close();
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    assert(old is SortIndicatorPainter);
    SortIndicatorPainter oldPainter = old;
    return sortDirection != oldPainter.sortDirection;
  }
}
