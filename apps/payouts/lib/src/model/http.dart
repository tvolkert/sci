import 'dart:convert';
import 'dart:io' show HttpHeaders, HttpStatus;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'binding.dart';
import 'constants.dart';
import 'debug.dart';

mixin HttpBinding on AppBindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The singleton instance of this object.
  static HttpBinding? _instance;
  static HttpBinding? get instance => _instance;

  http.BaseClient? _client;
  http.BaseClient get client {
    assert(() {
      if (debugUseFakeHttpLayer) {
        _client ??= _FakeHttpClient();
      }
      return true;
    }());
    return _client ??= http.Client() as http.BaseClient;
  }
}

@immutable
class HttpStatusException implements Exception {
  HttpStatusException(this.statusCode, [this.message])
      : statusMessage = httpStatusCodes[statusCode];

  final int statusCode;
  final String? statusMessage;
  final String? message;

  @override
  String toString() {
    StringBuffer buf = StringBuffer()
      ..writeAll([
        'HTTP $statusCode',
        if (statusMessage != null) ' ($statusMessage)',
        if (message != null) ': $message',
      ]);
    return buf.toString();
  }
}

class _FakeHttpClient extends http.BaseClient {
  static http.StreamedResponse _notFound() {
    return http.StreamedResponse(Stream<List<int>>.empty(), HttpStatus.notFound);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    debugPrint('${request.method} ${request.url.path}');
    if (!_urlToFakeContent.containsKey(request.method)) {
      return _notFound();
    }
    final dynamic content = _urlToFakeContent[request.method]![request.url.path];
    if (content == null) {
      return _notFound();
    }
    String body;
    Map<String, String> responseHeaders = const <String, String>{};
    int statusCode = debugHttpStatusCode;
    if (content is _FakeResponse) {
      statusCode = content.statusCode;
      body = content.body;
      responseHeaders = content.headers;
    } else {
      body = '$content';
    }
    final List<int> encodedBody = utf8.encode(body);
    if (debugHttpLatency != null) {
      await Future<void>.delayed(debugHttpLatency!);
    }
    return http.StreamedResponse(
      Stream<List<int>>.value(encodedBody),
      statusCode,
      headers: responseHeaders,
      contentLength: encodedBody.length,
    );
  }
}

// last invoice id: 516
const Map<String, Map<String, dynamic>> _urlToFakeContent = <String, Map<String, dynamic>>{
  'GET': <String, dynamic>{
    '/payoutsLogin': '{"last_invoice_id": 1, "password_temporary": false}',
    '/invoice': '{"timesheets": [{"requestor": "", "program": {"rate": 235.0, "billable": true, "requires_charge_number": false, "name": "HNS Jupiter", "assignment_id": 90, "requires_requestor": false}, "charge_number": "", "task_description": "WEBEX FMR Anomaly Status", "hours": [0, 0, 0, 1.0, 0, 0, 0, 0, 0, 0, 0.75, 0, 0, 0]}, {"requestor": "", "program": {"rate": 235.0, "billable": true, "requires_charge_number": false, "name": "SpaceCom - AMOS 17", "assignment_id": 461, "requires_requestor": false}, "charge_number": "", "task_description": "IS29e Anomaly", "hours": [0, 0, 0, 0, 0, 0, 0, 3.7, 1.7, 3.0, 1.7, 0, 0, 0]}, {"requestor": "", "program": {"rate": 235.0, "billable": true, "requires_charge_number": false, "name": "JCSAT-18", "assignment_id": 488, "requires_requestor": false}, "charge_number": "", "task_description": "Feed Panel Failure", "hours": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0, 0, 0]}, {"requestor": "", "program": {"rate": 235.0, "billable": true, "requires_charge_number": false, "name": "JCSAT-18", "assignment_id": 488, "requires_requestor": false}, "charge_number": "", "task_description": "IS29e Anomaly", "hours": [0, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 1.5, 0.25, 0, 0, 0]}], "billing_start": "2010-02-22", "billing_duration": 14, "expense_reports": [{"requestor": "", "from_date": "2010-02-01", "expenses": [{"expense_type": {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 28, "name": "Server", "parent_expense_type_id": 27, "long_name": "Internet Expense:Server", "enabled": true, "comment": null}, "description": "", "amount": 63.32, "date": "2010-02-01", "ordinal": 0}], "travel_purpose": "", "travel_destination": "", "program": {"rate": 0.0, "billable": false, "requires_charge_number": false, "name": "SCI - Overhead", "assignment_id": 77, "requires_requestor": false}, "charge_number": "", "task_description": "AWS 10-02", "to_date": "2010-02-05", "travel_parties": ""}, {"requestor": "", "from_date": "2010-03-01", "expenses": [{"expense_type": {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 28, "name": "Server", "parent_expense_type_id": 27, "long_name": "Internet Expense:Server", "enabled": true, "comment": null}, "description": "", "amount": 57.31, "date": "2010-03-01", "ordinal": 0}], "travel_purpose": "", "travel_destination": "", "program": {"rate": 0.0, "billable": false, "requires_charge_number": false, "name": "SCI - Overhead", "assignment_id": 77, "requires_requestor": false}, "charge_number": "", "task_description": "AWS 10-03", "to_date": "2010-03-05", "travel_parties": ""}], "vendor": "Volkert, Todd", "invoice_number": "TCV-10-02", "submitted": true, "invoice_id": 516, "tasks": []}',
    '/invoices': '[{"billing_start": "2008-02-25", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-08-01", "submitted": 1252367383491, "invoice_id": 65}, {"billing_start": "2008-03-24", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-08-02", "submitted": 1252367781502, "invoice_id": 66}, {"billing_start": "2009-02-23", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-09-01", "submitted": 1252367003325, "invoice_id": 67}, {"billing_start": "2009-07-13", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-09-03", "submitted": 1249295854823, "invoice_id": 33}, {"billing_start": "2009-07-27", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-09-02", "submitted": 1249194276046, "invoice_id": 32}, {"billing_start": "2009-08-10", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-09-04", "submitted": 1250099538922, "invoice_id": 35}, {"billing_start": "2009-08-24", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-09-05", "submitted": 1252373740578, "invoice_id": 54}, {"billing_start": "2009-09-21", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-09-06", "submitted": 1254439104933, "invoice_id": 105}, {"billing_start": "2009-10-19", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-09-07", "submitted": 1257247734745, "invoice_id": 202}, {"billing_start": "2009-12-28", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-01", "submitted": 1262496920789, "invoice_id": 339}, {"billing_start": "2010-02-22", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-02", "submitted": 1268941298809, "invoice_id": 516}, {"billing_start": "2010-03-22", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-04", "submitted": 1270957011976, "invoice_id": 570}, {"billing_start": "2010-04-05", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-03", "submitted": 1270580789671, "invoice_id": 560}, {"billing_start": "2010-04-19", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-05", "submitted": 1272896039899, "invoice_id": 624}, {"billing_start": "2010-05-31", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-06", "submitted": 1275915515416, "invoice_id": 700}, {"billing_start": "2010-06-28", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-07", "submitted": 1279079308335, "invoice_id": 771}, {"billing_start": "2010-07-26", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-10-08", "submitted": 1281899676803, "invoice_id": 842}, {"billing_start": "2011-01-10", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-11-01", "submitted": 1295194544361, "invoice_id": 1160}, {"billing_start": "2011-02-07", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-11-02", "submitted": 1297170886802, "invoice_id": 1211}, {"billing_start": "2011-02-21", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-11-03", "submitted": 1299375981047, "invoice_id": 1269}, {"billing_start": "2011-10-31", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-11-04", "submitted": 1322149278742, "invoice_id": 1813}, {"billing_start": "2011-11-14", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-11-05", "submitted": 1322670744382, "invoice_id": 1834}, {"billing_start": "2013-11-11", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-13-01", "submitted": 1384730376421, "invoice_id": 3235}, {"billing_start": "2014-09-01", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-14-01", "submitted": 1409984241086, "invoice_id": 3645}, {"billing_start": "2015-04-27", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-15-02", "submitted": 1442966288681, "invoice_id": 4221}, {"billing_start": "2015-09-14", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-15-01", "submitted": 1442851163357, "invoice_id": 4219}, {"billing_start": "2015-09-28", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-15-03", "submitted": 1444150699566, "invoice_id": 4240}, {"billing_start": "2015-10-26", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-15-04", "submitted": 1446658122622, "invoice_id": 4279}, {"billing_start": "2015-11-23", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-15-05", "submitted": 1449785900901, "invoice_id": 4337}, {"billing_start": "2015-12-21", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-16-01", "submitted": 1451968322139, "invoice_id": 4366}, {"billing_start": "2016-01-04", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-16-02", "submitted": 1452788447967, "invoice_id": 4382}, {"billing_start": "2016-02-01", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-16-03", "submitted": 1454604092702, "invoice_id": 4416}, {"billing_start": "2017-09-11", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-17-01", "submitted": 1506294968475, "invoice_id": 5217}, {"billing_start": "2017-09-25", "resubmit": false, "billing_duration": 14, "invoice_number": "TCV-17-02", "submitted": 1508440798862, "invoice_id": 5262}]',
    '/newInvoiceParameters': '{"billing_periods": [{"billing_period": "2020-03-09"}, {"billing_period": "2020-03-23"}, {"billing_period": "2020-04-06"}, {"billing_period": "2020-04-20"}, {"billing_period": "2020-05-04"}, {"billing_period": "2020-05-18"}, {"billing_period": "2020-06-01"}, {"billing_period": "2020-06-15"}, {"billing_period": "2020-06-29"}, {"billing_period": "2020-07-13"}, {"billing_period": "2020-07-27"}, {"billing_period": "2020-08-10", "invoice_number": "TEST1"}, {"billing_period": "2020-08-24"}], "invoice_number": ""}',
    '/userAssignments': '[{"rate": 0.0, "billable": false, "requires_charge_number": false, "name": "SCI - Overhead", "assignment_id": 77, "requires_requestor": false}, {"rate": 95.0, "billable": true, "requires_charge_number": true, "name": "BSS, NNV8-913197 (COSC)", "assignment_id": 185, "requires_requestor": true}, {"rate": 110.0, "billable": true, "requires_charge_number": true, "name": "Orbital Sciences", "assignment_id": 219, "requires_requestor": false}, {"rate": 110.0, "billable": true, "requires_charge_number": false, "name": "Loral - T14R", "assignment_id": 425, "requires_requestor": false}, {"rate": 120.0, "billable": true, "requires_charge_number": false, "name": "Sirius FM 6", "assignment_id": 426, "requires_requestor": true}]',
    '/expenseTypes': '[{"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 4, "name": "Travel & Ent", "parent_expense_type_id": null, "long_name": "Travel & Ent", "enabled": false, "comment": null}, {"visible": false, "depth": 1, "reimbursable": false, "expense_type_id": 5, "name": "Reimbursable T&E", "parent_expense_type_id": 4, "long_name": "Travel & Ent:Reimbursable T&E", "enabled": false, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 6, "name": "Phone/Internet", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Phone/Internet", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 7, "name": "Other", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Other", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 8, "name": "Airfare/Trainfare", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Airfare/Trainfare", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 9, "name": "Lodging", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Lodging", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 10, "name": "Meals", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Meals", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 11, "name": "Car Rental", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Car Rental", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 12, "name": "Fuel", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Fuel", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 13, "name": "Parking", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Parking", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 14, "name": "Tolls", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Tolls", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 15, "name": "Taxi/Shuttle/Bus/Ferry", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Taxi/Shuttle/Bus/Ferry", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 16, "name": "Gratuities", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Gratuities", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 17, "name": "Laundry", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Laundry", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 18, "name": "Currency Exchange", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Currency Exchange", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": true, "expense_type_id": 19, "name": "Mileage", "parent_expense_type_id": 5, "long_name": "Travel & Ent:Reimbursable T&E:Mileage", "enabled": true, "comment": "mileageRate"}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 26, "name": "Conferences/Seminars", "parent_expense_type_id": null, "long_name": "Conferences/Seminars", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 27, "name": "Internet Expense", "parent_expense_type_id": null, "long_name": "Internet Expense", "enabled": false, "comment": null}, {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 28, "name": "Server", "parent_expense_type_id": 27, "long_name": "Internet Expense:Server", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 29, "name": "Meeting Expense", "parent_expense_type_id": null, "long_name": "Meeting Expense", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 30, "name": "Miscellaneous", "parent_expense_type_id": null, "long_name": "Miscellaneous", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 31, "name": "Office Furniture", "parent_expense_type_id": null, "long_name": "Office Furniture", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 32, "name": "Office Supplies", "parent_expense_type_id": null, "long_name": "Office Supplies", "enabled": true, "comment": null}, {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 33, "name": "Computer", "parent_expense_type_id": 32, "long_name": "Office Supplies:Computer", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 34, "name": "Postage and Delivery", "parent_expense_type_id": null, "long_name": "Postage and Delivery", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 35, "name": "Printing and Reproduction", "parent_expense_type_id": null, "long_name": "Printing and Reproduction", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 36, "name": "Promotion Expense", "parent_expense_type_id": null, "long_name": "Promotion Expense", "enabled": true, "comment": null}, {"visible": true, "depth": 0, "reimbursable": false, "expense_type_id": 37, "name": "Telephone", "parent_expense_type_id": null, "long_name": "Telephone", "enabled": true, "comment": null}, {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 38, "name": "Entertainment", "parent_expense_type_id": 4, "long_name": "Travel & Ent:Entertainment", "enabled": true, "comment": null}, {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 39, "name": "Meals", "parent_expense_type_id": 4, "long_name": "Travel & Ent:Meals", "enabled": true, "comment": null}, {"visible": true, "depth": 1, "reimbursable": false, "expense_type_id": 40, "name": "Travel", "parent_expense_type_id": 4, "long_name": "Travel & Ent:Travel", "enabled": false, "comment": null}, {"visible": true, "depth": 2, "reimbursable": false, "expense_type_id": 41, "name": "Business Travel", "parent_expense_type_id": 40, "long_name": "Travel & Ent:Travel:Business Travel", "enabled": true, "comment": null}, {"visible": true, "depth": 2, "reimbursable": false, "expense_type_id": 42, "name": "Local Travel", "parent_expense_type_id": 40, "long_name": "Travel & Ent:Travel:Local Travel", "enabled": true, "comment": null}]',
  },
  'POST': <String, dynamic>{
    '/invoice': _FakeResponse(
      statusCode: HttpStatus.created,
      headers: <String, String>{
        HttpHeaders.locationHeader: '/invoice#invoiceId=516',
      },
    ),
  },
  'PUT': <String, dynamic>{
    '/invoice': _FakeResponse(
      statusCode: HttpStatus.noContent,
    ),
    '/password': '',
  },
};

@immutable
class _FakeResponse {
  const _FakeResponse({
    required this.statusCode,
    this.body = '',
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}
