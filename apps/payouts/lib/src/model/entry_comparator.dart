import 'package:payouts/src/pivot.dart' as pivot;

import 'constants.dart';

typedef _EntryComparator = int Function(Map<String, dynamic> a, Map<String, dynamic> b);

int _compareInvoiceNumber(Map<String, dynamic> a, Map<String, dynamic> b) {
  final String aVal = a[Keys.invoiceNumber];
  final String bVal = b[Keys.invoiceNumber];
  return aVal.compareTo(bVal);
}

int _compareBillingPeriod(Map<String, dynamic> a, Map<String, dynamic> b) {
  final String aVal = a[Keys.billingStart];
  final String bVal = b[Keys.billingStart];
  // String comparison should work since we're using YYYY-MM-DD format.
  return aVal.compareTo(bVal);
}

int _compareSubmitted(Map<String, dynamic> a, Map<String, dynamic> b) {
  final int? aVal = a[Keys.submitted];
  final int? bVal = b[Keys.submitted];
  if (aVal == bVal) {
    return 0;
  } else if (aVal == null) {
    return 1;
  } else if (bVal == null) {
    return -1;
  } else {
    return aVal.compareTo(bVal);
  }
}

int _compareResubmit(Map<String, dynamic> a, Map<String, dynamic> b) {
  final bool aVal = a[Keys.resubmit];
  final bool bVal = b[Keys.resubmit];
  if (aVal == bVal) {
    return 0;
  } else if (aVal) {
    return -1;
  } else {
    return 1;
  }
}

const Map<String, _EntryComparator> _entryComparators = <String, _EntryComparator>{
  Keys.invoiceNumber: _compareInvoiceNumber,
  Keys.billingStart: _compareBillingPeriod,
  Keys.submitted: _compareSubmitted,
  Keys.resubmit: _compareResubmit,
};

class EntryComparator {
  const EntryComparator({
    required this.key,
    this.direction = pivot.SortDirection.ascending,
  });

  final String key;
  final pivot.SortDirection direction;

  int compare(Map<String, dynamic> a, Map<String, dynamic> b) {
    final _EntryComparator basicComparator = _entryComparators[key]!;
    int result = basicComparator(a, b);
    if (direction == pivot.SortDirection.descending) {
      result *= -1;
    }
    return result;
  }
}
