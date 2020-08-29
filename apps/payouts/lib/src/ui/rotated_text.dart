import 'package:flutter/widgets.dart';

class RotatedText extends StatelessWidget {
  const RotatedText({
    Key key,
    @required this.offset,
    @required this.angle,
    @required this.text,
  })  : assert(offset != null),
        assert(angle != null),
        assert(text != null),
        super(key: key);

  final Offset offset;
  final double angle;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        alignment: Alignment.bottomCenter,
        angle: angle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 40,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(text, maxLines: 1),
            ),
          ),
        ),
      ),
    );
  }
}
