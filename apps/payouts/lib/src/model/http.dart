import 'package:flutter/foundation.dart';

import 'constants.dart';

@immutable
class HttpStatusException implements Exception {
  HttpStatusException(this.statusCode, [String message])
      : this.message = message ?? httpStatusCodes[statusCode];

  final int statusCode;
  final String message;
}
