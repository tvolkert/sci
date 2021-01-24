import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const double _checkboxSize = 14;
const double _checkmarkSize = 10;

class Checkbox extends StatelessWidget {
  const Checkbox({
    Key? key,
    this.spacing = 6,
    this.checked = true,
    this.onChange,
    required this.child,
  }) : super(key: key);

  final double spacing;
  final bool checked;
  final VoidCallback? onChange;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onChange,
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(BorderSide(color: const Color(0xff999999))),
              ),
              child: SizedBox(
                width: _checkboxSize,
                height: _checkboxSize,
                child: CustomPaint(painter: _CheckPainter(checked)),
              ),
            ),
            SizedBox(width: spacing),
            child,
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.checked);

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    if (checked) {
      final Paint paint = Paint()
        ..color = const Color(0xff2b5580)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      double n = _checkmarkSize / 2;
      double m = _checkmarkSize / 4;
      double dx = (_checkboxSize - (n + m)) / 2;
      double dy = (_checkboxSize - n) / 2;
      canvas.translate(0, (size.height - _checkboxSize) / 2);
      canvas.drawLine(Offset(dx, (n - m) + dy), Offset(m + dx, n + dy), paint);
      canvas.drawLine(Offset(m + dx, n + dy), Offset((m + n) + dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => checked != oldDelegate.checked;
}
