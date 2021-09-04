import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class ProvideFeedbackIntent extends Intent {
  const ProvideFeedbackIntent({this.context});

  final BuildContext? context;
}

class ProvideFeedbackAction extends ContextAction<ProvideFeedbackIntent> {
  ProvideFeedbackAction._();

  static final ProvideFeedbackAction instance = ProvideFeedbackAction._();

  @override
  Future<void> invoke(ProvideFeedbackIntent intent, [BuildContext? context]) async {
    await url.launch('mailto:keith@satelliteconsulting.com');
  }
}
