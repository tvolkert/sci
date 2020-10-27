import 'package:payouts/src/pivot.dart';

import 'binding.dart';
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
        AssignmentsBinding {
  /// Creates and initializes the application binding if necessary.
  ///
  /// Applications should call this method before calling [runApp].
  static void ensureInitialized() {
    if (UserBinding.instance == null) {
      PayoutsBinding();
    }
  }
}
