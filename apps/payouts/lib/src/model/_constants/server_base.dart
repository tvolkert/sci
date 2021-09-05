mixin ServerBase {
  String get scheme => 'https';
  String get host => 'www.satelliteconsulting.com';

  String get loginUrl => 'payoutsLogin';
  String get tokenUrl => 'token';
  String get invoiceUrl => 'invoice';
  String get fooUrl => 'clientLog';
  String get billPdfUrl => 'billPDF';
  String get passwordUrl => 'password';
  String get invoicePdfUrl => 'invoicePDF';
  String get feedbackUrl => 'feedback';
  String get expenseTypesUrl => 'expenseTypes';
  String get userAssignmentsUrl => 'userAssignments';
  String get invoicesUrl => 'invoices';
  String get newInvoiceParametersUrl => 'newInvoiceParameters';

  Uri uri(String path, {Map<String, String>? query}) {
    return Uri(scheme: scheme, host: host, path: path, queryParameters: query);
  }
}
