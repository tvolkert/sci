// @dart=2.9

import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'package:payouts/src/model/track_invoice_dirty_mixin.dart';
import 'package:payouts/src/pivot.dart' as pivot;

import 'save_invoice.dart';

mixin WarnOnUnsavedChangesMixin on TrackInvoiceDirtyMixin {
  /// Ensures that the user is ok proceeding if there are unsaved changes.
  ///
  /// Callers should consult this method when they are about to take action
  /// that would cause the user to lose unsaved work. If there is unsaved work,
  /// this will present the user with the option of saving their changes,
  /// discarding their changes and proceeding anyway, or canceling the action
  /// altogether.
  ///
  /// The returned future completes with true once the caller is cleared to
  /// proceed, or false if the user canceled the action, and the caller should
  /// avoid the action altogether.
  ///
  /// If there is no unsaved work, the returned future will complete
  /// immediately (in the next microtask loop) with true.
  Future<bool> checkForUnsavedChanges(BuildContext context) async {
    if (!isInvoiceDirty) {
      return true;
    }

    int selectedOption = await pivot.Prompt.open(
      context: context,
      messageType: pivot.MessageType.warning,
      message: 'Save Changes?',
      body: Text(
        'This invoice has been modified.  Do you want to save your changes?',
        style: Theme.of(context).textTheme.bodyText2.copyWith(height: 1.25),
      ),
      options: ['Save', 'Discard', 'Cancel'],
    );

    switch (selectedOption) {
      case 0:
        // Save
        final SaveInvoiceIntent intent = SaveInvoiceIntent(context: context);
        final Future<void> saveFuture = Actions.invoke<SaveInvoiceIntent>(context, intent);
        await saveFuture;
        return true;
      case 1:
        // Discard
        return true;
      case 2:
        // Cancel
        return false;
    }
  }
}
