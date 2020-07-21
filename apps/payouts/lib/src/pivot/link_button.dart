import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class LinkButton extends StatefulWidget {
  const LinkButton({
    Key key,
    this.image,
    this.text,
    this.onPressed,
  }) : super(key: key);

  final ImageProvider image;
  final String text;
  final VoidCallback onPressed;

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          hover = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          hover = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.image != null)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Image(image: widget.image),
              ),
            Text(
              widget.text,
              style: TextStyle(
                color: Color(0xff2b5580),
                decoration: hover ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
