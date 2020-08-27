import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorWidth: 1,
      cursorColor: Colors.black,
      style: TextStyle(fontFamily: 'Verdana', fontSize: 11),
      decoration: InputDecoration(
        fillColor: Colors.white,
        hoverColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.fromLTRB(3, 13, 0, 4),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff999999)),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff999999)),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
