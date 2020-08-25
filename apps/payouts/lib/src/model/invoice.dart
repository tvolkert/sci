const String _idKey = 'invoice_id';

class InvoiceBinding {
  InvoiceBinding._();

  /// The singleton binding instance.
  static final InvoiceBinding instance = InvoiceBinding._();

  /// The currently open invoice, or null if no invoice is opened.
  Invoice _invoice;
  Invoice get invoice => _invoice;
}

class Invoice {
  Invoice(this.id, this.data)
      : assert(id != null),
        assert(data[_idKey] == id);

  final int id;
  final Map<String, dynamic> data;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other == null) {
      return false;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    Invoice invoice = other;
    return invoice.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Invoice $id';
}
