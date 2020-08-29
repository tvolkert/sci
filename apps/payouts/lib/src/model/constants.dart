import 'dart:io' show HttpStatus;

import 'package:intl/intl.dart' as intl;

class DateFormats {
  static final intl.DateFormat iso8601Short = intl.DateFormat('yyyy-MM-dd');
}

class NumberFormats {
  static final intl.NumberFormat currency = intl.NumberFormat.currency(symbol: r'$');
  static final intl.NumberFormat decimal = intl.NumberFormat(r'#,##0.00');
}

class Keys {
  const Keys._();

  static const String name = 'name';
  static const String expenseTypeId = 'expense_type_id';
  static const String fromDate = 'from_date';
  static const String toDate = 'to_date';
  static const String expenses = 'expenses';
  static const String date = 'date';
  static const String expenseType = 'expense_type';
  static const String expensesType = 'expense_types';
  static const String amount = 'amount';
  static const String expenseReports = 'expense_reports';
  static const String timesheets = 'timesheets';
  static const String accomplishments = 'tasks';
  static const String submitted = 'submitted';
  static const String resubmit = 'resubmit';
  static const String chargeNumber = 'charge_number';
  static const String chargeNumbers = 'charge_numbers';
  static const String taskDescription = 'task_description';
  static const String requestor = 'requestor';
  static const String program = 'program';
  static const String assignmentId = 'assignment_id';
  static const String rate = 'rate';
  static const String hours = 'hours';
  static const String description = 'description';
  static const String programId = 'program_id';
  static const String customerId = 'customer_id';
  static const String active = 'active';
  static const String requiresChargeNumber = 'requires_charge_number';
  static const String requiresRequestor = 'requires_requestor';
  static const String invoiceId = 'invoice_id';
  static const String invoiceNumber = 'invoice_number';
  static const String billingPeriod = 'billing_period';
  static const String billingStart = 'billing_start';
  static const String billingDuration = 'billing_duration';
  static const String billingPeriods = 'billing_periods';
  static const String createDate = 'create_date';
  static const String lastModifiedDate = 'last_modified_date';
  static const String lastOpenDate = 'last_open_date';
  static const String travel = 'travel';
  static const String travelDestination = 'travel_destination';
  static const String travelParties = 'travel_parties';
  static const String travelPurpose = 'travel_purpose';
  static const String type = 'type';
  static const String vendor = 'vendor';
  static const String expense = 'expense';
  static const String income = 'income';
  static const String company = 'company';
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String email = 'email';
  static const String alias = 'alias';
  static const String itemName = 'item_name';
  static const String password = 'password';
  static const String passwordRequiresReset = 'password_temporary';
  static const String billable = 'billable';
  static const String reimbursable = 'reimbursable';
  static const String parentExpenseTypeId = 'parent_expense_type_id';
  static const String comment = 'comment';
  static const String depth = 'depth';
  static const String ordinal = 'ordinal';
  static const String visible = 'visible';
  static const String longName = 'long_name';
  static const String enabled = 'enabled';
  static const String lastInvoiceId = 'last_invoice_id';
  static const String count = 'count';
  static const String notToExceedHours = 'not_to_exceed_hours';
  static const String notToExceedDollars = 'not_to_exceed_dollars';
}

class Server {
  static const String scheme = 'https';
  static const String host = 'www.satelliteconsulting.com';

  static const String loginUrl = 'payoutsLogin';
  static const String invoiceUrl = 'invoice';
  static const String fooUrl = 'clientLog';
  static const String billPdfUrl = 'billPDF';
  static const String passwordUrl = 'password';
  static const String invoicePdfUrl = 'invoicePDF';
  static const String feedbackUrl = 'feedback';
  static const String expenseTypesUrl = 'expenseTypes';
  static const String userAssignmentsUrl = 'userAssignments';
  static const String invoicesUrl = 'invoices';
  static const String newInvoiceParametersUrl = 'newInvoiceParameters';

  static Uri uri(String path, {Map<String, String> query}) {
    return Uri(scheme: scheme, host: host, path: path, queryParameters: query);
  }
}

class QueryParameters {
  static const String invoiceId = 'invoiceId';
}

const Duration httpTimeout = Duration(seconds: 20);

const Map<int, String> httpStatusCodes = <int, String>{
  HttpStatus.badRequest: 'bad request',
  HttpStatus.unauthorized: 'unauthorized',
  HttpStatus.notFound: 'not found',
  HttpStatus.internalServerError: 'internal server error',
  HttpStatus.notImplemented: 'not implemented',
  HttpStatus.badGateway: 'bad gateway',
  HttpStatus.serviceUnavailable: 'service unavailable',
  HttpStatus.gatewayTimeout: 'gateway timeout',
};
