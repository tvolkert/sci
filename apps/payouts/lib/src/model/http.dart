import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'debug.dart';

abstract class HttpBinding {
  const HttpBinding._();

  static HttpBinding _instance;
  static HttpBinding get instance {
    _instance ??= debugUseFakeHttpLayer ? FakeHttpBinding() : RealHttpBinding();
    return _instance;
  }

  http.BaseClient get client;
}

@immutable
class HttpStatusException implements Exception {
  HttpStatusException(this.statusCode, [this.message])
      : statusMessage = httpStatusCodes[statusCode];

  final int statusCode;
  final String statusMessage;
  final String message;
}

@visibleForTesting
class FakeHttpBinding extends HttpBinding {
  FakeHttpBinding() : super._();

  @override
  final http.BaseClient client = _FakeHttpClient();
}

class _FakeHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print(request.url.path);
    final String content = _urlToFakeContent[request.url.path];
    if (content == null) {
      return http.StreamedResponse(Stream<List<int>>.empty(), HttpStatus.notFound);
    }
    final List<int> encodedContent = utf8.encode(content);
    if (debugHttpLatency != null) {
      await Future<void>.delayed(debugHttpLatency);
    }
    return http.StreamedResponse(
      Stream<List<int>>.value(encodedContent),
      debugHttpStatusCode,
      contentLength: encodedContent.length,
    );
  }
}

@visibleForTesting
class RealHttpBinding extends HttpBinding {
  RealHttpBinding() : super._();

  @override
  final http.BaseClient client = http.Client();
}

const Map<String, String> _urlToFakeContent = <String, String>{
  '/payoutsLogin': '{"last_invoice_id": 516, "password_temporary": false}',
  '/invoice': '{"timesheets": [], "billing_start": "2010-02-22", "billing_duration": 14, "expense_reports": [{"requestor": "", "from_date": "2010-02-01", "expenses": [{"expense_type": {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 28, "name": "Server", "parent_expense_type_id": 27, "long_name": "Internet Expense:Server", "enabled": true, "comment": null}, "description": "", "amount": 63.32, "date": "2010-02-01", "ordinal": 0}], "travel_purpose": "", "travel_destination": "", "program": {"rate": 0.0, "billable": false, "requires_charge_number": false, "name": "SCI - Overhead", "assignment_id": 77, "requires_requestor": false}, "charge_number": "", "task_description": "AWS 10-02", "to_date": "2010-02-05", "travel_parties": ""}, {"requestor": "", "from_date": "2010-03-01", "expenses": [{"expense_type": {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 28, "name": "Server", "parent_expense_type_id": 27, "long_name": "Internet Expense:Server", "enabled": true, "comment": null}, "description": "", "amount": 57.31, "date": "2010-03-01", "ordinal": 0}], "travel_purpose": "", "travel_destination": "", "program": {"rate": 0.0, "billable": false, "requires_charge_number": false, "name": "SCI - Overhead", "assignment_id": 77, "requires_requestor": false}, "charge_number": "", "task_description": "AWS 10-03", "to_date": "2010-03-05", "travel_parties": ""}], "vendor": "Volkert, Todd", "invoice_number": "TCV-10-02", "submitted": true, "invoice_id": 516, "tasks": []}',
};