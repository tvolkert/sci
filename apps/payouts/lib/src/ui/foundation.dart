import 'package:flutter/foundation.dart';

class Signal extends ChangeNotifier {
  void notify() => notifyListeners();
}
