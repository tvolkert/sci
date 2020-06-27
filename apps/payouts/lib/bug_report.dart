import 'package:flutter/widgets.dart';

void main() {
  runApp(BugReport());
}

class BugReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(0xffffffff),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xff000000), width: 0),
          ),
        ),
      ),
    );
  }
}

class RawPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: BugReportBoxPainter(),
        );
      },
    );
  }
}

class BugReportBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double borderWidth = 1;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..style = PaintingStyle.fill
        ..color = Color(0xffffffff),
    );
    canvas.drawRect(
        Rect.fromLTWH(10.0, 10.0, size.width - 20.0, size.height - 20.0).deflate(borderWidth / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = Color(0xff000000));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
