class TextInputValidators {
  const TextInputValidators._();

  static bool validateHoursInDay(String text) {
    bool valid = true;
    double? value = text.isEmpty ? 0 : double.tryParse(text);
    if (value == null) {
      valid = false;
    } else if (value < 0 || value > 24) {
      valid = false;
    } else if (text.contains('.')) {
      final String afterDecimal = text.substring(text.indexOf('.') + 1);
      assert(!afterDecimal.contains('.'));
      if (afterDecimal.length > 2) {
        valid = false;
      }
    }
    return valid;
  }

  static bool validateCurrency(String text) {
    bool valid = true;
    double? value = text.isEmpty ? 0 : double.tryParse(text);
    if (value == null) {
      valid = false;
    } else if (value < 0) {
      valid = false;
    } else if (text.contains('.')) {
      final String afterDecimal = text.substring(text.indexOf('.') + 1);
      assert(!afterDecimal.contains('.'));
      if (afterDecimal.length > 2) {
        valid = false;
      }
    }
    return valid;
  }
}
