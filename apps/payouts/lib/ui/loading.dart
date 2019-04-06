import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(text),
          ],
        ),
      ),
    );
  }
}
