import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Checkbox extends StatelessWidget {
  const Checkbox({
    Key key,
    this.spacing,
    this.child,
  }) : super(key: key);

  final double spacing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              border: Border.fromBorderSide(BorderSide(color: const Color(0xff999999))),
            ),
            child: SizedBox(width: 14, height: 14),
          ),
          SizedBox(width: spacing),
          child,
        ],
      ),
    );
  }
}
