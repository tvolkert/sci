import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/src/model/invoice.dart' as ib show InvoiceBinding;
import 'package:payouts/src/model/user.dart';
import 'package:payouts/ui/loading.dart';
import 'package:payouts/ui/auth/user_binding.dart' as ub;

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

    User user = ub.UserBinding.of(context);
    assert(user != null, 'Attempt to load an invoice while the user was logged out');

    ib.InvoiceBinding.instance.loadInvoice(invoiceId).then<void>((Invoice invoice) {
      if (mounted) {
        setState(() {
          this._invoice = invoice;
        });
      }
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
