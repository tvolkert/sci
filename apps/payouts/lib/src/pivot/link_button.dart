import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'action_tracker.dart';
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

  Widget _buildContent({
    required Color color,
    bool hover = false,
  }) {
    Widget? imageWidget;
    if (image != null) {
      imageWidget = Padding(
        padding: EdgeInsets.only(right: 4),
        child: Image(image: image!),
      );
      if (onPressed == null) {
        imageWidget = Opacity(
          opacity: 0.5,
          child: imageWidget,
        );
      }
    }

    Widget link = Text(text, style: TextStyle(color: color));
    if (hover) {
      link = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: color)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: link,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (imageWidget != null) imageWidget,
        link,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return _buildContent(
        color: const Color(0xff999999),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HoverBuilder(
            cursor: SystemMouseCursors.click,
            builder: (BuildContext context, bool hover) {
              return GestureDetector(
                onTap: onPressed,
                child: _buildContent(
                  color: const Color(0xff2b5580),
                  hover: hover,
                ),
              );
            },
          ),
        ],
      );
    }
  }
}

class ActionLinkButton<I extends Intent> extends ActionTracker<I> {
  const ActionLinkButton({
    Key? key,
    required I intent,
    this.image,
    required this.text,
  }) : super(key: key, intent: intent);

  final ImageProvider? image;
  final String text;

  @override
  _ActionLinkButtonState<I> createState() => _ActionLinkButtonState<I>();
}

class _ActionLinkButtonState<I extends Intent> extends State<ActionLinkButton<I>>
    with ActionTrackerStateMixin<I, ActionLinkButton<I>> {
  @override
  Widget build(BuildContext context) {
    return LinkButton(
      text: widget.text,
      image: widget.image,
      onPressed: isEnabled ? invokeAction : null,
    );
  }
}
