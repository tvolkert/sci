import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:http/http.dart' as http;

import 'collections.dart';
import 'constants.dart';
import 'http.dart';
import 'user.dart';

class InvoiceBinding {
  InvoiceBinding._();

  /// The singleton binding instance.
  static final InvoiceBinding instance = InvoiceBinding._();

  /// The currently open invoice, or null if no invoice is opened.
  Invoice _invoice;
  Invoice get invoice => _invoice;

  Future<Invoice> openInvoice(int invoiceId, {Duration timeout = httpTimeout}) async {
    final Uri uri = Server.uri(Server.invoiceUrl);
    final http.Response response =
        await UserBinding.instance.user.authenticate().get(uri).timeout(timeout);
    if (response.statusCode == HttpStatus.ok) {
      Map<String, dynamic> invoiceData = json.decode(response.body).cast<String, dynamic>();
      _invoice = Invoice(invoiceId, invoiceData);
      return _invoice;
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }
}

class Invoice {
  Invoice(this.id, Map<String, dynamic> data)
      : assert(id != null),
        assert(data != null),
        assert(data[Keys.invoiceId] == id),
        _data = NotifyingMap(data),
        _timesheets = _extractTimesheets(data) {
    _data.addListener(MapListener<String, dynamic>(
      onValueAdded: null,
      onValueRemoved: null,
      onValueUpdated: null,
      onCleared: null,
    ));
    _timesheets.addListener(ListListener<NotifyingMap<String, dynamic>>(
      onItemsUpdated: null,
      onCleared: null,
      onReordered: null,
    ));
    for (NotifyingMap<String, dynamic> timesheet in _timesheets) {
      timesheet.addListener(MapListener<String, dynamic>(
        onValueAdded: null,
        onValueRemoved: null,
        onValueUpdated: null,
        onCleared: null,
      ));
    }
  }

  final int id;
  final NotifyingMap<String, dynamic> _data;
  final NotifyingList<NotifyingMap<String, dynamic>> _timesheets;

  static List<NotifyingMap<String, dynamic>> _extractTimesheets(Map<String, dynamic> data) {
    final List<dynamic> timesheets = data[Keys.timesheets];
    final List<NotifyingMap<String, dynamic>> notifyingTimesheet = timesheets
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> timesheet) => NotifyingMap<String, dynamic>(timesheet))
        .toList();
    return NotifyingList<NotifyingMap<String, dynamic>>(notifyingTimesheet);
  }

  // TODO: remove
  Map<String, dynamic> get data => _data.delegate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Invoice $id';
}
