import 'package:flutter/material.dart';

enum MessageType {
  error,
  warning,
  question,
  info,
}

class Sheet extends StatelessWidget {
  const Sheet({
    Key key,
    @required this.content,
  }) : super(key: key);

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xebf6f4ed),
        border: Border.all(width: 1, color: const Color(0xff999999)),
      ),
      child: Padding(
        padding: EdgeInsets.all(9),
        child: content,
      ),
    );
  }

  static Future<T> open<T>({BuildContext context, Widget content}) {
    return _openDialog<T>(
      context: context,
      child: Sheet(
        content: content,
      ),
    );
  }
}

class Prompt extends StatelessWidget {
  const Prompt({
    Key key,
    @required this.messageType,
    @required this.message,
    this.body,
    this.options = const <String>[],
    this.selectedOption,
  })  : assert(messageType != null),
        assert(message != null),
        super(key: key);

  final MessageType messageType;
  final String message;
  final Widget body;
  final List<String> options;
  final int selectedOption;

  void _setSelectedOption(BuildContext context, int index) {
    Navigator.of(context).pop<int>(index);
  }

  static String _messageTypeToAsset(MessageType messageType) {
    switch (messageType) {
      case MessageType.error:
        return 'message_type-error-32x32.png';
      case MessageType.warning:
        return 'message_type-warning-32x32.png';
      case MessageType.question:
        return 'message_type-question-32x32.png';
      case MessageType.info:
        return 'message_type-info-32x32.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xff999999),
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 280,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/${_messageTypeToAsset(messageType)}'),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
                            ),
                            body,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(options.length, (int index) {
              // TODO: switch to Terra styled button.
              return OutlineButton(
                onPressed: () => _setSelectedOption(context, index),
                child: Text(options[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  static Future<int> open({
    BuildContext context,
    @required MessageType messageType,
    @required String message,
    Widget body,
    List<String> options = const <String>[],
    int selectedOption,
  }) {
    assert(messageType != null);
    assert(message != null);
    return _openDialog<int>(
      context: context,
      barrierDismissible: false,
      child: Prompt(
        messageType: messageType,
        message: message,
        body: body,
        options: options,
        selectedOption: selectedOption,
      ),
    );
  }
}

Future<T> _openDialog<T>({
  BuildContext context,
  bool barrierDismissible = true,
  String barrierLabel = 'Dismiss',
  Widget child,
}) {
  final ThemeData theme = Theme.of(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      Widget result = child;
      if (theme != null) {
        result = Theme(
          data: theme,
          child: result,
        );
      }
      return result;
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        ),
      );
    },
  );
}
