import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class LaunchUrlIntent extends Intent {
  const LaunchUrlIntent(this.url);

  final String url;
}

class LaunchUrlAction extends ContextAction<LaunchUrlIntent> {
  LaunchUrlAction._();

  static final LaunchUrlAction instance = LaunchUrlAction._();

  @override
  Future<void> invoke(LaunchUrlIntent intent, [BuildContext? context]) async {
    await url.launch(intent.url);
  }
}
