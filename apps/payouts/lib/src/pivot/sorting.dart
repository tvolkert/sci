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
    switch (sortDirection) {
      case SortDirection.ascending:
        path
          ..moveTo(0, 3)
          ..lineTo(3, 0)
          ..lineTo(6, 3);
        break;
      case SortDirection.descending:
        path
          ..moveTo(0, 0)
          ..lineTo(3, 3)
          ..lineTo(6, 0);
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
