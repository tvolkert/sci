import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    Key key,
    this.controller,
    this.backgroundColor = const Color(0xffffffff),
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController controller;

  final Color backgroundColor;

  final bool obscureText;

  static const InputBorder _inputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff999999)),
    borderRadius: BorderRadius.zero,
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorWidth: 1,
      obscureText: obscureText,
      cursorColor: const Color(0xff000000),
      style: const TextStyle(fontFamily: 'Verdana', fontSize: 11),
      decoration: InputDecoration(
        fillColor: backgroundColor,
        hoverColor: backgroundColor,
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(3, 13, 0, 4),
        isDense: true,
        enabledBorder: _inputBorder,
        focusedBorder: _inputBorder,
      ),
    );
  }
}
