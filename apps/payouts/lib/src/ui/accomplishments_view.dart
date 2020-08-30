import 'package:flutter/material.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class AccomplishmentsView extends StatelessWidget {
  const AccomplishmentsView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              pivot.LinkButton(
                image: AssetImage('assets/note_add.png'),
                text: 'Add accomplishment',
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text('BSS, NNV8-913197 (COSC)'),
                  ),
                  Expanded(
                    child: AccomplishmentsEntryField(
                      minLines: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccomplishmentsEntryField extends StatefulWidget {
  const AccomplishmentsEntryField({
    Key key,
    this.minLines = 2,
    this.maxLines = 20,
    this.readOnly = false,
    this.initialText,
  }) : super(key: key);

  final int minLines;
  final int maxLines;
  final bool readOnly;
  final String initialText;

  @override
  _AccomplishmentsEntryFieldState createState() => _AccomplishmentsEntryFieldState();
}

class _AccomplishmentsEntryFieldState extends State<AccomplishmentsEntryField> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff999999), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(1),
        child: TextField(
          controller: controller,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          cursorWidth: 1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 7),
            hoverColor: Colors.transparent,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
