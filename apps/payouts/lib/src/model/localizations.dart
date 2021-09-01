import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';

abstract class PayoutsLocalizations {
  const PayoutsLocalizations._();

  /// Localized strings.
  ///
  /// This map is guaranteed to contain all the keys defined in [Strings].
  Map<String, String> get strings;

  String string(String key) => strings[key]!;

  /// The mileage reimbursement rate.
  String get mileageRate => string(Strings.mileageRate);

  /// Error message specifying that a user input field is required.
  String get requiredField => string(Strings.requiredField);

  /// The `PayoutsLocalizations` from the closest [Localizations] instance
  /// that encloses the given context.
  ///
  /// This method is just a convenient shorthand for:
  /// `Localizations.of<PayoutsLocalizations>(context, PayoutsLocalizations)!`.
  ///
  /// References to the localized resources defined by this class are typically
  /// written in terms of this method. For example:
  ///
  /// ```dart
  /// textDirection: PayoutsLocalizations.of(context).mileageRate,
  /// ```
  static PayoutsLocalizations of(BuildContext context) {
    assert(debugCheckHasWidgetsLocalizations(context));
    return Localizations.of<PayoutsLocalizations>(context, PayoutsLocalizations)!;
  }
}

class DefaultPayoutsLocalizations extends PayoutsLocalizations {
  const DefaultPayoutsLocalizations() : super._();

  Map<String, String> get strings => const <String, String>{
    Strings.mileageRate: '(\$0.50/mile)',
    Strings.requiredField: 'This field is required.',
  };

  /// Creates an object that provides US English resource values for the
  /// Payouts library.
  ///
  /// The [locale] parameter is ignored.
  ///
  /// This method is typically used to create a [LocalizationsDelegate].
  /// The [PayoutsApp] does so by default.
  static Future<PayoutsLocalizations> load(Locale locale) {
    return SynchronousFuture<PayoutsLocalizations>(const DefaultPayoutsLocalizations());
  }

  /// A [LocalizationsDelegate] that uses [DefaultPayoutsLocalizations.load]
  /// to create an instance of this class.
  ///
  /// [PayoutsApp] automatically adds this value to [WidgetsApp.localizationsDelegates].
  static const LocalizationsDelegate<PayoutsLocalizations> delegate = _PayoutsLocalizationsDelegate();
}

class _PayoutsLocalizationsDelegate extends LocalizationsDelegate<PayoutsLocalizations> {
  const _PayoutsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<PayoutsLocalizations> load(Locale locale) => DefaultPayoutsLocalizations.load(locale);

  @override
  bool shouldReload(_PayoutsLocalizationsDelegate old) => false;

  @override
  String toString() => 'DefaultPayoutsLocalizations.delegate(en_US)';
}
