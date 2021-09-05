import 'package:chicago/chicago.dart';

import 'binding.dart';
import 'confirm_exit_mixin.dart';
import 'http.dart';
import 'invoice.dart';
import 'user.dart';

class PayoutsBinding extends AppBindingBase
    with
        ListenerNotifier<InvoiceListener>,
        InvoiceListenerNotifier,
        HttpBinding,
        UserBinding,
        InvoiceBinding,
        AssignmentsBinding,
        ExpenseTypesBinding,
        ConfirmExitMixin {
  /// Creates and initializes the application binding if necessary.
  ///
  /// Applications should call this method before calling [runApp].
  static void ensureInitialized() {
    if (UserBinding.instance == null) {
      PayoutsBinding();
    }
  }
}
