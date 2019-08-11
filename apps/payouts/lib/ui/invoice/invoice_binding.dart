import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import 'package:payouts/model/invoice.dart';
import 'package:payouts/model/user.dart';
import 'package:payouts/ui/loading.dart';
import 'package:payouts/ui/auth/user_binding.dart';

class InvoiceBinding extends StatefulWidget {
  const InvoiceBinding({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _InvoiceBindingState();
  }

  static InvoiceContext of(BuildContext context) {
    _InvoiceBindingScope scope = context.inheritFromWidgetOfExactType(_InvoiceBindingScope);
    assert(scope != null, 'InvoiceBinding was not found in the widget ancestry.');
    return scope.invoiceBindingState;
  }
}

abstract class InvoiceContext {
  set invoiceId(int invoiceId);

  Invoice get invoice;
}

class _InvoiceBindingState extends State<InvoiceBinding> implements InvoiceContext {
  int _invoiceId;
  Invoice _invoice;

  @override
  set invoiceId(int invoiceId) {
    debugPrint('setting invoice id to $invoiceId');
    if (invoiceId == _invoiceId) {
      return;
    }

    setState(() {
      _invoiceId = invoiceId;
      _invoice = null;
    });

    if (invoiceId == null) {
      return;
    }

    User user = UserBinding.of(context);
    assert(user != null, 'Attempt to load an invoice while the user was logged out');

    Uri uri = Uri(
      scheme: 'https',
      host: 'www.satelliteconsulting.com',
      path: 'invoice',
      queryParameters: <String, String>{
        'invoiceId': '$invoiceId',
      },
    );
    Future<http.Response> responseFuture = http.get(uri, headers: user.authHeaders);
    debugPrint('sending request');
    responseFuture.then<http.Response>((http.Response response) {
      if (response.statusCode == 200) {
        debugPrint('received 200 invoice response');
        Map<String, dynamic> invoice = json.decode(response.body).cast<String, dynamic>();
        assert(invoice['invoice_id'] == invoiceId);
        if (invoice['invoice_id'] != _invoiceId) {
          debugPrint('${invoice['invoice_id']} versus $_invoiceId');
          // The current invoice has already been changed. Normally we would
          // have canceled the HTTP request, but since we have no facility by
          // which to cancel requests, we simply drop the response on the floor
          // here.
          return;
        }
        setState(() {
          this._invoice = Invoice(invoiceId, invoice);
        });
      }
    }).catchError((dynamic error, StackTrace stackTrace) {
      // TODO: notify the user?
      debugPrint('$error\n$stackTrace');
    });
  }

  @override
  Invoice get invoice => _invoice;

  @override
  Widget build(BuildContext context) {
    return _invoiceId != null && _invoice == null
        ? Loading('Initializing')
        : _InvoiceBindingScope(invoiceBindingState: this, child: widget.child);
  }
}

class _InvoiceBindingScope extends InheritedWidget {
  const _InvoiceBindingScope({
    Key key,
    this.invoiceBindingState,
    Widget child,
  }) : super(key: key, child: child);

  final _InvoiceBindingState invoiceBindingState;

  @override
  bool updateShouldNotify(_InvoiceBindingScope old) {
    // TODO figure out why the old scope getting passed here has the new credentials
    //return userBindingState.user != old.userBindingState.user;
    return true;
  }
}
