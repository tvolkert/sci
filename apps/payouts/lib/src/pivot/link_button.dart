import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'hover_builder.dart';

class LinkButton extends StatelessWidget {
  const LinkButton({
    Key? key,
    this.image,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  final ImageProvider? image;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (BuildContext context, bool hover) {
        return GestureDetector(
          onTap: onPressed,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (image != null)
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Image(image: image!),
                ),
              Text(
                text,
                style: TextStyle(
                  color: Color(0xff2b5580),
                  decoration: hover ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
