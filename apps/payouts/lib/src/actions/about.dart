import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:payouts/src/pivot.dart' as pivot;

class AboutIntent extends Intent {
  const AboutIntent({this.context});

  final BuildContext? context;
}

class AboutAction extends ContextAction<AboutIntent> {
  AboutAction._();

  static final AboutAction instance = AboutAction._();

  @override
  Future<void> invoke(AboutIntent intent, [BuildContext? context]) async {
    context ??= intent.context ?? primaryFocus!.context;
    if (context == null) {
      throw StateError('No context in which to invoke $runtimeType');
    }

    await AboutSheet.open(context: context);
  }
}

class AboutSheet extends StatelessWidget {
  const AboutSheet({
    Key? key,
    required this.flutterVersionData,
  })  : super(key: key);

  final Map<String, String> flutterVersionData;

  @override
  Widget build(BuildContext context) {
    final TextStyle bodyTextStyle = Theme.of(context).textTheme.bodyText2!;
    return SizedBox(
      width: 300,
      child: Padding(
        padding: EdgeInsets.only(left: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Payouts',
                        style: bodyTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xff2b5580),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Version 2.0.0',
                        style: bodyTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff999999),
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/logo-large.png',
                  width: 168,
                  height: 168,
                  alignment: Alignment.bottomLeft,
                  fit: BoxFit.none,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('\u00A9 2001-2020 Satellite Consulting, Inc. All Rights Reserved. SCI Payouts '
                      'and the Satellite Consulting, Inc. logo are trademarks of Satellite Consulting, '
                      'Inc. All rights reserved.'),
                  SizedBox(height: 16),
                  FlutterVersion(data: flutterVersionData),
                  SizedBox(height: 16),
                  pivot.LinkButton(text: 'View licenses', onPressed: () => showLicensePage(context: context)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      pivot.CommandPushButton(
                        label: 'OK',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> open({required BuildContext context}) async {
    Map<String, String> flutterVersionData = await rootBundle.loadStructuredData<Map<String, String>>(
      'assets/flutter_version.json',
          (String value) async {
        Map<String, dynamic> decoded = json.decode(value);
        return decoded.cast<String, String>();
      },
    );
    return pivot.Sheet.open<void>(
      context: context,
      padding: EdgeInsets.zero,
      content: AboutSheet(
        flutterVersionData: flutterVersionData,
      ),
    );
  }
}

class FlutterVersion extends StatefulWidget {
  const FlutterVersion({required this.data});

  final Map<String, String> data;

  @override
  _FlutterVersionState createState() => _FlutterVersionState();
}

class _FlutterVersionState extends State<FlutterVersion> {
  late TextEditingController _controller;

  static final _dartSdkVersion = RegExp(r'[0-9.]+ \(build [^ ]+ ([0-9a-f]+)\)');

  void _setupController() {
    StringBuffer buf = StringBuffer()
      ..writeln('Flutter version: ${widget.data['frameworkVersion']}')
      ..writeln('Flutter channel: ${widget.data['channel']}')
      ..writeln('Flutter revision: ${widget.data['frameworkRevision']!.substring(0, 7)}')
      ..writeln('Flutter engine revision: ${widget.data['engineRevision']!.substring(0, 7)}')
      ..writeln('Flutter Dart revision: ${_dartSdkVersion.firstMatch(widget.data['dartSdkVersion']!)!.group(1)}');
    _controller.text = buf.toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _setupController();
  }

  @override
  void didUpdateWidget(FlutterVersion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      maxLines: 5,
      controller: _controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hoverColor: Colors.transparent,
        border: InputBorder.none,
      ),
    );
  }
}
