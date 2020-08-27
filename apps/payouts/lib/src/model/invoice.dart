import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:http/http.dart' as http;

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
  Invoice(this.id, this.data)
      : assert(id != null),
        assert(data[Keys.invoiceId] == id);

  final int id;
  final Map<String, dynamic> data;

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
