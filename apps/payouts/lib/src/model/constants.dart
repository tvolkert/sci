import 'dart:io' show HttpStatus;

class Keys {
  const Keys._();

  static const String lastInvoiceId = 'last_invoice_id';
  static const String passwordRequiresReset = 'password_temporary';
}

class Server {
  static const String scheme = 'https';
  static const String host = 'www.satelliteconsulting.com';

  static const String loginUrl = 'payoutsLogin';
  static const String invoiceUrl = 'invoice';

  static Uri uri(String path) => Uri(scheme: scheme, host: host, path: path);
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
