// @dart=2.9

import 'package:flutter/foundation.dart';

class Signal extends ChangeNotifier {
  void notify() => notifyListeners();
}
