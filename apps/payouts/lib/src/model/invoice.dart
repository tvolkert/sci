import 'dart:convert';
import 'dart:io' show HttpHeaders, HttpStatus;

import 'package:chicago/chicago.dart';
import 'package:flutter/foundation.dart' hide binarySearch;
import 'package:http/http.dart' as http;

import 'binding.dart';
import 'collections.dart';
import 'constants.dart';
import 'foundation.dart';
import 'http.dart';
import 'pair.dart';
import 'user.dart';

mixin InvoiceBinding on AppBindingBase, ListenerNotifier<InvoiceListener>, InvoiceListenerNotifier {
  @override
  @protected
  @mustCallSuper
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The singleton instance of this object.
  static InvoiceBinding? _instance;
  static InvoiceBinding? get instance => _instance;

  /// The currently open invoice, or null if no invoice is opened.
  Invoice? _invoice;
  Invoice? get invoice => _invoice;

  Future<Invoice> loadInvoice(int invoiceId, {Duration timeout = httpTimeout}) async {
    final Uri url = Server.uri(Server.invoiceUrl, query: <String, String>{
      QueryParameters.invoiceId: '$invoiceId',
    });
    final http.Response response =
        await UserBinding.instance!.user!.authenticate().get(url).timeout(timeout);
    if (response.statusCode == HttpStatus.ok) {
      final Map<String, dynamic> invoiceData = json.decode(response.body).cast<String, dynamic>();
      final Invoice? previousInvoice = _invoice;
      final Invoice invoice = Invoice._(this, invoiceId, invoiceData);
      _invoice = invoice;
      onInvoiceOpened(previousInvoice);
      if (previousInvoice != null) {
        previousInvoice._dispose();
      }
      return invoice;
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }

  Future<Invoice> createInvoice(NewInvoiceProperties properties) async {
    final Uri url = Server.uri(Server.invoiceUrl);
    final http.Client client = UserBinding.instance!.user!.authenticate();
    final Map<String, dynamic> body = <String, dynamic>{
      Keys.invoiceNumber: properties.invoiceNumber,
      Keys.billingStart: properties.billingStart,
      Keys.billingDuration: properties.billingDuration.inDays,
    };
    final http.Response response = await client.post(url, body: json.encode(body));
    if (response.statusCode == HttpStatus.created) {
      final String location = response.headers[HttpHeaders.locationHeader]!;
      final String fragment = Uri.parse(location).fragment;
      Pair<String> pair = Pair<String>.fromIterable(fragment.split('='));
      assert(pair.first == QueryParameters.invoiceId);
      final int invoiceId = int.parse(pair.second);
      return await loadInvoice(invoiceId);
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }
}

mixin AssignmentsBinding on AppBindingBase, UserBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    addPostLoginCallback(_loadAssignments);
  }

  /// The singleton instance of this object.
  static AssignmentsBinding? _instance;
  static AssignmentsBinding? get instance => _instance;

  List<Program>? _assignments;
  List<Program>? get assignments => _assignments;

  Future<void> _loadAssignments() async {
    removePostLoginCallback(_loadAssignments);
    final Uri url = Server.uri(Server.userAssignmentsUrl);
    final http.Response response =
        await UserBinding.instance!.user!.authenticate().get(url).timeout(httpTimeout);
    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> rawData = json.decode(response.body);
      _assignments = rawData
          .cast<Map<String, dynamic>>()
          .map<Program>((Map<String, dynamic> data) => Program._(data))
          .toList(growable: false);
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }
}

mixin ExpenseTypesBinding on AppBindingBase, UserBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    addPostLoginCallback(_loadExpenseTypes);
  }

  /// The singleton instance of this object.
  static ExpenseTypesBinding? _instance;
  static ExpenseTypesBinding? get instance => _instance;

  List<ExpenseType>? _expenseTypes;
  List<ExpenseType>? get expenseTypes => _expenseTypes;

  Future<void> _loadExpenseTypes() async {
    removePostLoginCallback(_loadExpenseTypes);
    final Uri url = Server.uri(Server.expenseTypesUrl);
    final http.Response response =
        await UserBinding.instance!.user!.authenticate().get(url).timeout(httpTimeout);
    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> rawData = json.decode(response.body);
      _expenseTypes = rawData
          .cast<Map<String, dynamic>>()
          .map<ExpenseType>((Map<String, dynamic> data) => ExpenseType._(data))
          .toList(growable: false);
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }
}

@immutable
class NewInvoiceProperties {
  const NewInvoiceProperties({
    required this.invoiceNumber,
    required this.billingStart,
    this.billingDuration = const Duration(days: 14),
  });

  final String invoiceNumber;
  final String billingStart;
  final Duration billingDuration;
}

typedef InvoiceChangedHandler = void Function(Invoice? oldInvoice);

typedef InvoiceNumberChangedHandler = void Function(String previousInvoiceNumber);

typedef InvoiceTotalChangedHandler = void Function(double previousTotal);

typedef InvoiceSubmittedHandler = void Function();

typedef InvoiceDirtyChangedHandler = void Function();

typedef InvoiceTimesheetInsertedHandler = void Function(int timesheetsIndex);

typedef InvoiceTimesheetsRemovedHandler = void Function(
  int timesheetsIndex,
  Iterable<Timesheet> removed,
);

typedef InvoiceTimesheetUpdatedHandler = void Function(
  int timesheetsIndex,
  String key,
  dynamic previousValue,
);

typedef InvoiceTimesheetHoursUpdatedHandler = void Function(
  int timesheetsIndex,
  int dayIndex,
  double previousHours,
);

typedef InvoiceAccomplishmentInsertedHandler = void Function(
  int accomplishmentsIndex,
);

typedef InvoiceAccomplishmentTextUpdatedHandler = void Function(
  int accomplishmentsIndex,
  String previousDescription,
);

typedef InvoiceExpenseReportInsertedHandler = void Function(
  int expenseReportsIndex,
);

typedef InvoiceExpenseReportsRemovedHandler = void Function(
  int expenseReportsIndex,
  Iterable<ExpenseReport> removed,
);

typedef InvoiceExpenseInsertedHandler = void Function(
  int expenseReportsIndex,
  int expensesIndex,
);

typedef InvoiceExpenseUpdatedHandler = void Function(
  int expenseReportsIndex,
  int expensesIndex,
  String key,
  dynamic previousValue,
);

typedef InvoiceExpensesRemovedHandler = void Function(
  int expenseReportsIndex,
  int expensesIndex,
  Iterable<Expense> removed,
);

@immutable
class InvoiceListener {
  const InvoiceListener({
    this.onInvoiceOpened,
    this.onInvoiceClosed,
    this.onInvoiceNumberChanged,
    this.onInvoiceTotalChanged,
    this.onSubmitted,
    this.onInvoiceDirtyChanged,
    this.onTimesheetInserted,
    this.onTimesheetsRemoved,
    this.onTimesheetUpdated,
    this.onTimesheetHoursUpdated,
    this.onAccomplishmentInserted,
    this.onAccomplishmentTextUpdated,
    this.onExpenseReportInserted,
    this.onExpenseReportsRemoved,
    this.onExpenseInserted,
    this.onExpenseUpdated,
    this.onExpensesRemoved,
  });

  final InvoiceChangedHandler? onInvoiceOpened;
  final InvoiceChangedHandler? onInvoiceClosed;
  final InvoiceNumberChangedHandler? onInvoiceNumberChanged;
  final InvoiceTotalChangedHandler? onInvoiceTotalChanged;
  final InvoiceSubmittedHandler? onSubmitted;
  final InvoiceDirtyChangedHandler? onInvoiceDirtyChanged;
  final InvoiceTimesheetInsertedHandler? onTimesheetInserted;
  final InvoiceTimesheetsRemovedHandler? onTimesheetsRemoved;
  final InvoiceTimesheetUpdatedHandler? onTimesheetUpdated;
  final InvoiceTimesheetHoursUpdatedHandler? onTimesheetHoursUpdated;
  final InvoiceAccomplishmentInsertedHandler? onAccomplishmentInserted;
  final InvoiceAccomplishmentTextUpdatedHandler? onAccomplishmentTextUpdated;
  final InvoiceExpenseReportInsertedHandler? onExpenseReportInserted;
  final InvoiceExpenseReportsRemovedHandler? onExpenseReportsRemoved;
  final InvoiceExpenseInsertedHandler? onExpenseInserted;
  final InvoiceExpenseUpdatedHandler? onExpenseUpdated;
  final InvoiceExpensesRemovedHandler? onExpensesRemoved;
}

mixin InvoiceListenerNotifier on ListenerNotifier<InvoiceListener> {
  @protected
  @mustCallSuper
  void onInvoiceOpened(Invoice? oldInvoice) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceOpened != null) {
        listener.onInvoiceOpened!(oldInvoice);
      }
    });
  }

  @protected
  @mustCallSuper
  void onInvoiceClosed(Invoice? oldInvoice) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceClosed != null) {
        listener.onInvoiceClosed!(oldInvoice);
      }
    });
  }

  @protected
  @mustCallSuper
  void onInvoiceNumberChanged(String previousInvoiceNumber) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceNumberChanged != null) {
        listener.onInvoiceNumberChanged!(previousInvoiceNumber);
      }
    });
  }

  @protected
  @mustCallSuper
  void onInvoiceTotalChanged(double previousTotal) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceTotalChanged != null) {
        listener.onInvoiceTotalChanged!(previousTotal);
      }
    });
  }

  @protected
  @mustCallSuper
  void onSubmitted() {
    notifyListeners((InvoiceListener listener) {
      if (listener.onSubmitted != null) {
        listener.onSubmitted!();
      }
    });
  }

  @protected
  @mustCallSuper
  void onInvoiceDirtyChanged() {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceDirtyChanged != null) {
        listener.onInvoiceDirtyChanged!();
      }
    });
  }

  @protected
  @mustCallSuper
  void onTimesheetInserted(int timesheetsIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetInserted != null) {
        listener.onTimesheetInserted!(timesheetsIndex);
      }
    });
  }

  @protected
  @mustCallSuper
  void onTimesheetsRemoved(int timesheetsIndex, Iterable<Timesheet> removed) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetsRemoved != null) {
        listener.onTimesheetsRemoved!(timesheetsIndex, removed);
      }
    });
  }

  @protected
  @mustCallSuper
  void onTimesheetUpdated(int timesheetsIndex, String key, dynamic previousValue) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetUpdated != null) {
        listener.onTimesheetUpdated!(timesheetsIndex, key, previousValue);
      }
    });
  }

  @protected
  @mustCallSuper
  void onTimesheetHoursUpdated(int timesheetsIndex, int dayIndex, double previousHours) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetHoursUpdated != null) {
        listener.onTimesheetHoursUpdated!(timesheetsIndex, dayIndex, previousHours);
      }
    });
  }

  @protected
  @mustCallSuper
  void onAccomplishmentInserted(int accomplishmentsIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onAccomplishmentInserted != null) {
        listener.onAccomplishmentInserted!(accomplishmentsIndex);
      }
    });
  }

  @protected
  @mustCallSuper
  void onAccomplishmentTextUpdated(int accomplishmentsIndex, String previousDescription) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onAccomplishmentTextUpdated != null) {
        listener.onAccomplishmentTextUpdated!(accomplishmentsIndex, previousDescription);
      }
    });
  }

  @protected
  @mustCallSuper
  void onExpenseReportInserted(int expenseReportsIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseReportInserted != null) {
        listener.onExpenseReportInserted!(expenseReportsIndex);
      }
    });
  }

  @protected
  @mustCallSuper
  void onExpenseReportsRemoved(int expenseReportsIndex, Iterable<ExpenseReport> removed) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseReportsRemoved != null) {
        listener.onExpenseReportsRemoved!(expenseReportsIndex, removed);
      }
    });
  }

  @protected
  @mustCallSuper
  void onExpenseInserted(int expenseReportsIndex, int expensesIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseInserted != null) {
        listener.onExpenseInserted!(expenseReportsIndex, expensesIndex);
      }
    });
  }

  @protected
  @mustCallSuper
  void onExpenseUpdated(
    int expenseReportsIndex,
    int expensesIndex,
    String key,
    dynamic previousValue,
  ) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseUpdated != null) {
        listener.onExpenseUpdated!(expenseReportsIndex, expensesIndex, key, previousValue);
      }
    });
  }

  @protected
  @mustCallSuper
  void onExpensesRemoved(int expenseReportsIndex, int expensesIndex, Iterable<Expense> removed) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpensesRemoved != null) {
        listener.onExpensesRemoved!(expenseReportsIndex, expensesIndex, removed);
      }
    });
  }
}

/// Class representing an invoice.
///
/// This is the core data model object for Payouts and Payouts Administrator.
///
/// See also:
///
///  * [InvoiceBinding.invoice], which is how callers get a reference to the
///    currently-loaded invoice.
///  * [InvoiceBinding.loadInvoice], which is used to load a new invoice from
///    the SCI server.
class Invoice {
  Invoice._(this._owner, this.id, this._data) : assert(_data[Keys.invoiceId] == id) {
    _data.putIfAbsent(Keys.submitted, () => false);
  }

  final InvoiceBinding _owner;
  bool _disposed = false;

  /// The invoice identifier, unique across all invoices.
  final int id;

  final Map<String, dynamic> _data;

  void _dispose() {
    _disposed = true;
  }

  T? _checkDisposed<T>([T Function()? callback]) {
    assert(!_disposed);
    if (callback != null) {
      return callback();
    }
    return null;
  }

  bool get isEmpty => timesheets.isEmpty && expenseReports.isEmpty && accomplishments.isEmpty;

  double? _total;
  double get total {
    _checkDisposed();
    return _total ??= computeTotal();
  }

  @protected
  set total(double value) {
    value = roundToSignificantDigits(value, 3);
    double previousValue = total;
    if (value != previousValue) {
      _total = value;
      _owner.onInvoiceTotalChanged(previousValue);
      _setIsDirty(true);
    }
  }

  /// Computes the total dollar amount for this invoice.
  @protected
  @visibleForTesting
  double computeTotal() => expenseReports.computeTotal() + timesheets.computeTotal();

  /// Whether this invoice has been modified since it was last saved.
  bool _isDirty = false;
  bool get isDirty => _isDirty;
  void _setIsDirty(bool value) {
    if (value != _isDirty) {
      _isDirty = value;
      _owner.onInvoiceDirtyChanged();
    }
  }

  /// The invoice vendor (e.g. "Todd Volkert" or "RES Consulting").
  String get vendor => _checkDisposed(() => _data[Keys.vendor])!;

  /// The invoice number.
  ///
  /// When this is changed, [InvoiceListener.onInvoiceNumberChanged] listeners
  /// will be notified.
  String get invoiceNumber => _checkDisposed(() => _data[Keys.invoiceNumber])!;
  set invoiceNumber(String value) {
    _checkDisposed();
    final String previousValue = _data[Keys.invoiceNumber];
    if (value != previousValue) {
      _data[Keys.invoiceNumber] = value;
      _owner.onInvoiceNumberChanged(previousValue);
      _setIsDirty(true);
    }
  }

  /// Whether the invoice has been submitted.
  ///
  /// This value starts out false for nwe invoices and is only allowed to ever
  /// go from false to true; attempting to set this value to false is an error.
  ///
  /// When this is changed, [InvoiceListener.onSubmitted] listeners will
  /// be notified.
  bool get isSubmitted => _checkDisposed(() => _data[Keys.submitted]);

  /// The billing period for the invoice.
  DateRange? _billingPeriod;
  DateRange get billingPeriod {
    _checkDisposed();
    return _billingPeriod ??= DateRange._fromRawData(_data);
  }

  /// This invoice's timesheets.
  ///
  /// Mutations on the list of timesheets or any individual timesheet will
  /// notify registered [InvoiceListener] listeners.
  Timesheets? _timesheets;
  Timesheets get timesheets {
    _checkDisposed();
    return _timesheets ??= Timesheets._fromRawData(this, _data);
  }

  /// This invoice's expense reports.
  ///
  /// Mutations on the list of expense reports or any individual expense report
  /// will notify registered [InvoiceListener] listeners.
  ExpenseReports? _expenseReports;
  ExpenseReports get expenseReports {
    _checkDisposed();
    return _expenseReports ??= ExpenseReports._fromRawData(this, _data);
  }

  /// This invoice's accomplishments.
  ///
  /// Mutations on the list of accomplishments or any individual accomplishment
  /// will notify registered [InvoiceListener] listeners.
  Accomplishments? _accomplishments;
  Accomplishments get accomplishments {
    _checkDisposed();
    return _accomplishments ??= Accomplishments._fromRawData(this, _data);
  }

  Future<void> save({bool markAsSubmitted = false}) async {
    assert(!isSubmitted);
    _checkDisposed();
    final Uri url = Server.uri(Server.invoiceUrl);
    final http.Client client = UserBinding.instance!.user!.authenticate();
    final String serialized = serialize(markAsSubmitted: markAsSubmitted);
    final http.Response response = await client.put(url, body: serialized);
    if (response.statusCode == HttpStatus.noContent) {
      _setIsDirty(false);
      if (markAsSubmitted) {
        _data[Keys.submitted] = true;
        _owner.onSubmitted();
      }
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }

  Future<void> delete() async {
    assert(!isSubmitted);
    _checkDisposed();
    final Uri url = Server.uri(Server.invoiceUrl, query: <String, String>{
      QueryParameters.invoiceId: '$id',
    });
    final http.Client client = UserBinding.instance!.user!.authenticate();
    final http.Response response = await client.delete(url);
    if (response.statusCode == HttpStatus.noContent) {
      _owner._invoice = null;
      _owner.onInvoiceClosed(this);
      _dispose();
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Invoice $id';

  /// An unmodifiable view of the raw data that backs this invoice.
  Map<String, dynamic> get rawData => Map<String, dynamic>.unmodifiable(_data);

  /// Serializes this invoice to a format suitable for permanent storage or
  /// transit across the wire.
  ///
  /// If the `markAsSubmitted` argument is true, then the serialized
  /// representation of this invoice will specify that the invoice has been
  /// submitted. This is intended for callers who wish to mark the invoice as
  /// submitted on the server, but not update the client-side model until the
  /// server responds with success.
  String serialize({bool markAsSubmitted = false}) {
    _checkDisposed();
    Map<String, dynamic> data = _data;
    if (markAsSubmitted) {
      data = Map<String, dynamic>.from(data);
      data[Keys.submitted] = true;
    }
    return json.encode(data);
  }
}

/// Mixin that will cause an [Iterable] to throw [UnsupportedError] when
/// [Iterable.toList] or [Iterable.toSet] is called.
mixin DisallowCollectionConversion<T> on Iterable<T> {
  @override
  List<T> toList({bool growable = true}) {
    throw UnsupportedError('Unsupported operation');
  }

  @override
  Set<T> toSet() {
    throw UnsupportedError('Unsupported operation');
  }
}

/// Represents a date range (start to end, inclusive).
@immutable
class DateRange with ForwardingIterable<DateTime> {
  const DateRange._(this._range);

  factory DateRange.fromStartEnd(DateTime start, DateTime end) {
    final int durationInDays = end.difference(start).inDays + 1;
    return DateRange._(_generateRange(start, durationInDays));
  }

  factory DateRange._fromRawData(Map<String, dynamic> invoiceData) {
    final DateTime start = DateTime.parse(invoiceData[Keys.billingStart]);
    final int durationInDays = invoiceData[Keys.billingDuration];
    return DateRange._(_generateRange(start, durationInDays));
  }

  factory DateRange._fromValues(String startDate, String endDate) {
    final DateTime start = DateTime.parse(startDate);
    final DateTime end = DateTime.parse(endDate);
    return DateRange.fromStartEnd(start, end);
  }

  final List<DateTime> _range;

  /// The first date in the range (inclusive).
  DateTime get start => _range.first;

  /// The last date in the range (inclusive).
  DateTime get end => _range.last;

  /// The date at the specified index.
  DateTime operator [](int index) => _range[index];

  static List<DateTime> _generateRange(DateTime start, int durationInDays) {
    DateTime current = start;
    return List<DateTime>.generate(durationInDays, (int index) {
      final DateTime result = current;
      assert(result == start.add(Duration(days: index)));
      current = current.add(const Duration(days: 1));
      return result;
    });
  }

  @override
  @protected
  Iterable<DateTime> get delegate => _range;
}

/// Class that represents a consultant assignment (a.k.a. a program).
///
/// This data is specified in Payouts Administrator and is immutable within
/// Payouts.
@immutable
class Program {
  const Program._(this._data);

  final Map<String, dynamic> _data;

  String get name => _data[Keys.name];

  double get rate => _data[Keys.rate].toDouble();

  bool get isBillable => _data[Keys.billable];

  bool get requiresChargeNumber => _data[Keys.requiresChargeNumber];

  bool get requiresRequestor => _data[Keys.requiresRequestor];

  int get assignmentId => _data[Keys.assignmentId];

  Map<String, dynamic> serialize() => _data;

  @override
  int get hashCode => assignmentId.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Program && other.assignmentId == assignmentId;
  }
}

/// Class that represents the list of timesheets in an invoice.
///
/// Mutations on this class will notify registered [InvoiceListener] listeners.
class Timesheets with ForwardingIterable<Timesheet>, DisallowCollectionConversion<Timesheet> {
  const Timesheets._(this._owner, this._data, this._view);

  factory Timesheets._fromRawData(Invoice owner, Map<String, dynamic> invoiceData) {
    final List<dynamic> rawTimesheets = invoiceData.putIfAbsent(Keys.timesheets, () => []);
    final List<Map<String, dynamic>> timesheets = rawTimesheets.cast<Map<String, dynamic>>();
    final List<Timesheet> view =
        timesheets.map<Timesheet>((Map<String, dynamic> data) => Timesheet._(owner, data)).toList();
    return Timesheets._(owner, timesheets, view);
  }

  final Invoice _owner;
  final List<Map<String, dynamic>> _data;
  final List<Timesheet> _view;

  /// The invoice to which this timesheet belongs.
  Invoice get invoice => _owner;

  @override
  @protected
  Iterable<Timesheet> get delegate => _view;

  /// Gets the timesheet at the specified index.
  Timesheet operator [](int index) => _owner._checkDisposed(() => _view[index])!;

  /// Computes the total dollar amount for the sum of all timesheets.
  double computeTotal() {
    return fold<double>(0, (double sum, Timesheet timesheet) => sum + timesheet.total);
  }

  int indexOf(InvoiceEntryMetadata entry) {
    for (int i = 0; i < _view.length; i++) {
      final Timesheet timesheet = _view[i];
      if (timesheet.program == entry.program &&
          timesheet.chargeNumber == entry.chargeNumber &&
          timesheet.task == entry.task) {
        return i;
      }
    }
    return -1;
  }

  /// Adds a timesheet with the specified metadata to this invoice's list of
  /// timesheets.
  ///
  /// Registered [InvoiceListener.onTimesheetInserted] listeners will
  /// be notified.
  Timesheet add(InvoiceEntryMetadata entry) {
    _owner._checkDisposed();
    final int index = binarySearch(_view, entry, compare: InvoiceEntryMetadata.compare);
    assert(index < 0);
    final int insertIndex = -(index + 1);
    final Timesheet timesheet = Timesheet._fromParts(
      owner: _owner,
      program: entry.program,
      chargeNumber: entry.chargeNumber!,
      requestor: entry.requestor!,
      taskDescription: entry.task!,
    );
    _view.insert(insertIndex, timesheet);
    _data.insert(insertIndex, timesheet.serialize());
    _owner._owner.onTimesheetInserted(insertIndex);
    _owner._setIsDirty(true);
    return timesheet;
  }

  /// Removes the specified timesheet.
  ///
  /// Registered [InvoiceListener.onTimesheetsRemoved] listeners will
  /// be notified.
  void remove(Timesheet timesheet) {
    assert(_view[timesheet.index] == timesheet);
    removeAt(timesheet.index);
  }

  /// Removes the timesheet at the specified index.
  ///
  /// Registered [InvoiceListener.onTimesheetsRemoved] listeners will
  /// be notified.
  Timesheet removeAt(int index) {
    _owner._checkDisposed();
    // Order is important here; set this first to force the parent to run its
    // lazy total calculation before updating our model.
    final double previousInvoiceTotal = _owner.total;
    final Timesheet removed = _view.removeAt(index);
    _data.removeAt(index);
    _owner._owner.onTimesheetsRemoved(index, <Timesheet>[removed]);
    _owner._setIsDirty(true);
    _owner.total = previousInvoiceTotal - removed.total;
    return removed;
  }

  /// Removes all timesheets for which the specified `test` returns true.
  ///
  /// Registered [InvoiceListener.onTimesheetsRemoved] listeners will
  /// be notified.
  void removeWhere(bool Function(Timesheet timesheet) test) {
    _owner._checkDisposed();
    for (int i = length - 1; i >= 0; i--) {
      if (test(_view[i])) {
        removeAt(i);
      }
    }
  }
}

class InvoiceEntryMetadata {
  const InvoiceEntryMetadata({
    required this.program,
    required this.chargeNumber,
    required this.requestor,
    required this.task,
  });

  /// The program (assignment data) against which this entry is to be billed.
  final Program program;

  /// The charge number of this entry.
  ///
  /// No all entry types will populate this field (e.g. [Accomplishment]). For
  /// entry types that do populate the field, if [Program.requiresChargeNumber]
  /// is false for this entry's [program], then the charge number will be the
  /// empty string.
  final String? chargeNumber;

  /// The name of the client who requested the work done in this entry.
  ///
  /// No all entry types will populate this field (e.g. [Accomplishment]). For
  /// entry types that do populate the field, if [Program.requiresChargeNumber]
  /// is false for this entry's [program], then the requestor will be the empty
  /// string.
  final String? requestor;

  /// The task description for this entry.
  ///
  /// No all entry types will populate this field (e.g. [Accomplishment]). For
  /// entry types that do populate the field, it serves an an optional field
  /// that allows the consultant to describe the entry to help them organize
  /// their invoice.
  final String? task;

  static int compare(InvoiceEntryMetadata m1, InvoiceEntryMetadata m2) {
    final int assignmentId1 = m1.program.assignmentId;
    final int assignmentId2 = m2.program.assignmentId;
    int result = assignmentId1 - assignmentId2;
    if (result == 0) {
      final String chargeNumber1 = m1.chargeNumber ?? '';
      final String chargeNumber2 = m2.chargeNumber ?? '';
      result = chargeNumber1.compareTo(chargeNumber2);
      if (result == 0) {
        final String task1 = m1.task ?? '';
        final String task2 = m2.task ?? '';
        result = task1.compareTo(task2);
      }
    }
    return result;
  }
}

/// Class that represents an individual timesheet within an invoice.
///
/// Mutations on this class will notify registered [InvoiceListener] listeners.
class Timesheet implements InvoiceEntryMetadata {
  Timesheet._(this._owner, this._data, [this._program]);

  factory Timesheet._fromParts({
    required Invoice owner,
    required Program program,
    required String chargeNumber,
    required String requestor,
    required String taskDescription,
  }) {
    final Map<String, dynamic> data = <String, dynamic>{
      Keys.program: program._data,
      Keys.chargeNumber: chargeNumber,
      Keys.requestor: requestor,
      Keys.taskDescription: taskDescription,
      Keys.hours: List<double>.filled(owner.billingPeriod.length, 0),
    };
    return Timesheet._(owner, data, program);
  }

  final Invoice _owner;
  final Map<String, dynamic> _data;

  /// The invoice to which this timesheet belongs.
  Invoice get invoice => _owner;

  /// The index of this timesheet in the invoice's list of timesheets.
  int get index => _owner.timesheets._view.indexOf(this);

  /// The total billed value of this timesheet.
  double get total => totalHours * program.rate;

  /// The total number of hours in this timesheet.
  double? _totalHours;
  double get totalHours {
    _owner._checkDisposed();
    return _totalHours ??= hours.fold<double>(0, (double sum, double value) => sum + value);
  }

  @protected
  set totalHours(double value) {
    value = roundToSignificantDigits(value, 2);
    double previousValue = totalHours;
    if (value != previousValue) {
      // Order is important here; set this first to force the parent to run its
      // lazy total calculation before updating our total.
      final double previousInvoiceTotal = _owner.total;
      _totalHours = value;
      _owner.total = previousInvoiceTotal + (value - previousValue) * program.rate;
    }
  }

  /// The "name" of this timesheet.
  ///
  /// This is an amalgamation of the program name, the charge number (if
  /// supplied), and the task (if supplied).
  String? _name;
  String get name {
    _owner._checkDisposed();
    String computeName() {
      final StringBuffer buf = StringBuffer(program.name);
      final String chargeNumber = this.chargeNumber;
      if (chargeNumber.isNotEmpty) {
        buf.write(' ($chargeNumber)');
      }
      final String task = this.task;
      if (task.isNotEmpty) {
        buf.write(' ($task)');
      }
      return buf.toString();
    }

    return _name ??= computeName();
  }

  Program? _program;

  @override
  Program get program => _owner._checkDisposed(() => _program ??= Program._(_data[Keys.program]))!;

  @override
  String get chargeNumber => _owner._checkDisposed(() => _data[Keys.chargeNumber])!;

  @override
  String get requestor => _owner._checkDisposed(() => _data[Keys.requestor])!;

  @override
  String get task => _owner._checkDisposed(() => _data[Keys.taskDescription])!;

  /// The hour entries in this timesheet.
  ///
  /// The number of entries will match the billing duration
  /// ([DateRange.duration], in days) of the invoice.
  Hours? _hours;
  Hours get hours {
    _owner._checkDisposed();
    return _hours ??= Hours._fromRawData(_owner, this, _data);
  }

  /// Updates the specified metadata for this timesheet.
  ///
  /// Any arguments that are unspecified or null will be ignored.
  ///
  /// Registered [InvoiceListener.onTimesheetUpdated] listeners will be
  /// notified once for each field that was updated.
  void update({
    String? chargeNumber,
    String? requestor,
    String? taskDescription,
  }) {
    _owner._checkDisposed();
    final int timesheetsIndex = _owner.timesheets._view.indexOf(this);
    if (chargeNumber != null) {
      String previousValue = this.chargeNumber;
      if (chargeNumber != previousValue) {
        _data[Keys.chargeNumber] = chargeNumber;
        _name = null;
        _owner._owner.onTimesheetUpdated(timesheetsIndex, Keys.chargeNumber, previousValue);
        _owner._setIsDirty(true);
      }
    }
    if (requestor != null) {
      String previousValue = this.requestor;
      if (requestor != previousValue) {
        _data[Keys.requestor] = requestor;
        _name = null;
        _owner._owner.onTimesheetUpdated(timesheetsIndex, Keys.requestor, previousValue);
        _owner._setIsDirty(true);
      }
    }
    if (taskDescription != null) {
      String previousValue = this.task;
      if (taskDescription != previousValue) {
        _data[Keys.taskDescription] = taskDescription;
        _name = null;
        _owner._owner.onTimesheetUpdated(timesheetsIndex, Keys.taskDescription, previousValue);
        _owner._setIsDirty(true);
      }
    }
  }

  Map<String, dynamic> serialize() => _data;
}

/// Class representing the list of hours values within a timesheet.
///
/// Mutations on this class will cause registered [InvoiceListener] listeners
/// to be notified.
class Hours with ForwardingIterable<double>, DisallowCollectionConversion<double> {
  const Hours._(this._owner, this._parent, this._data);

  factory Hours._fromRawData(Invoice owner, Timesheet parent, Map<String, dynamic> timesheetData) {
    final List<dynamic> hours = timesheetData[Keys.hours];
    return Hours._(owner, parent, hours.cast<num>());
  }

  final Invoice _owner;
  final Timesheet _parent;
  final List<num> _data;

  @override
  @protected
  Iterable<double> get delegate => _data.map<double>((num value) => value.toDouble());

  /// Gets the hours value at the specified index.
  double operator [](int index) => _owner._checkDisposed(() => _data[index].toDouble())!;

  /// Sets the hours value at the specified index.
  ///
  /// Registered [InvoiceListener.onTimesheetHoursUpdated] listeners will be
  /// notified.
  void operator []=(int index, double value) {
    _owner._checkDisposed();
    double previousValue = this[index];
    if (value != previousValue) {
      // Order is important here; set this first to force the parent to run its
      // lazy total calculation before updating the hours value.
      final double previousTotal = _parent.totalHours;
      _data[index] = value;
      _owner._owner.onTimesheetHoursUpdated(_parent.index, index, previousValue);
      _owner._setIsDirty(true);
      _parent.totalHours = previousTotal + (value - previousValue);
    }
  }
}

/// Class that represents the list of expense reports in an invoice.
///
/// Mutations to the list of expense reports or to any expense report in the
/// list will notify registered [InvoiceListener] listeners.
class ExpenseReports
    with ForwardingIterable<ExpenseReport>, DisallowCollectionConversion<ExpenseReport> {
  const ExpenseReports._(this._owner, this._data, this._view);

  factory ExpenseReports._fromRawData(Invoice owner, Map<String, dynamic> invoiceData) {
    final List<dynamic> rawExpenseReports = invoiceData.putIfAbsent(Keys.expenseReports, () => []);
    final List<Map<String, dynamic>> expenseReports =
        rawExpenseReports.cast<Map<String, dynamic>>();
    final List<ExpenseReport> view = expenseReports
        .map<ExpenseReport>((Map<String, dynamic> data) => ExpenseReport._(owner, data))
        .toList();
    return ExpenseReports._(owner, expenseReports, view);
  }

  final Invoice _owner;
  final List<Map<String, dynamic>> _data;
  final List<ExpenseReport> _view;

  /// The invoice to which these expense reports belong.
  Invoice get invoice => _owner;

  @override
  @protected
  Iterable<ExpenseReport> get delegate => _view;

  /// Computes the total dollar amount for this expense report.
  double computeTotal() {
    return fold<double>(0, (double sum, ExpenseReport report) => sum + report.total);
  }

  /// Gets the expense report at the specified index.
  ExpenseReport operator [](int index) => _owner._checkDisposed(() => _view[index])!;

  int indexOf(ExpenseReportMetadata entry) {
    for (int i = 0; i < _data.length; i++) {
      final ExpenseReport expenseReport = _view[i];
      if (expenseReport.program == entry.program &&
          expenseReport.chargeNumber == entry.chargeNumber &&
          expenseReport.task == entry.task) {
        return i;
      }
    }
    return -1;
  }

  /// Adds an expense report with the specified metadata to this invoice's list
  /// of expense reports.
  ///
  /// Registered [InvoiceListener.onExpenseReportInserted] listeners will
  /// be notified.
  ExpenseReport add(ExpenseReportMetadata entry) {
    _owner._checkDisposed();
    final int index = binarySearch(_view, entry, compare: InvoiceEntryMetadata.compare);
    assert(index < 0);
    final int insertIndex = -(index + 1);
    final ExpenseReport expenseReport = ExpenseReport._fromParts(
      owner: _owner,
      program: entry.program,
      chargeNumber: entry.chargeNumber,
      requestor: entry.requestor,
      task: entry.task,
      period: entry.period,
      travelPurpose: entry.travelPurpose,
      travelDestination: entry.travelDestination,
      travelParties: entry.travelParties,
    );
    _view.insert(insertIndex, expenseReport);
    _data.insert(insertIndex, expenseReport.serialize());
    _owner._owner.onExpenseReportInserted(insertIndex);
    _owner._setIsDirty(true);
    return expenseReport;
  }

  /// Removes the expense report at the specified index.
  ///
  /// Registered [InvoiceListener.onExpenseReportsRemoved] listeners will
  /// be notified.
  ExpenseReport removeAt(int index) {
    _owner._checkDisposed();
    final ExpenseReport removed = _view.removeAt(index);
    _data.removeAt(index);
    _owner._owner.onExpenseReportsRemoved(index, <ExpenseReport>[removed]);
    _owner._setIsDirty(true);
    return removed;
  }

  /// Removes all expense reports for which the specified `test` returns true.
  ///
  /// Registered [InvoiceListener.onExpenseReportsRemoved] listeners will
  /// be notified.
  void removeWhere(bool Function(ExpenseReport expenseReport) test) {
    _owner._checkDisposed();
    for (int i = length - 1; i >= 0; i--) {
      if (test(_view[i])) {
        removeAt(i);
      }
    }
  }
}

class ExpenseReportMetadata extends InvoiceEntryMetadata {
  ExpenseReportMetadata({
    required Program program,
    required String? chargeNumber,
    required String? requestor,
    required String? task,
    required this.period,
    required this.travelPurpose,
    required this.travelDestination,
    required this.travelParties,
  }) : super(
          program: program,
          chargeNumber: chargeNumber,
          requestor: requestor,
          task: task,
        );

  /// The time period that this expense report covers.
  final DateRange period;

  /// The purpose of the travel, as indicated by the consultant.
  final String travelPurpose;

  /// The destination of the travel, as indicated by the consultant.
  final String travelDestination;

  /// The client(s) visited as part of the travel, as indicated by the
  /// consultant.
  final String travelParties;
}

/// An individual expense report in the invoice.
///
/// Mutations to the expense report or to any expenses in the report will
/// notify registered [InvoiceListener] listeners.
class ExpenseReport implements ExpenseReportMetadata {
  ExpenseReport._(this._owner, this._data, [this._program, this._period]);

  factory ExpenseReport._fromParts({
    required Invoice owner,
    required Program program,
    required String? chargeNumber,
    required String? requestor,
    required String? task,
    required DateRange period,
    required String travelPurpose,
    required String travelDestination,
    required String travelParties,
  }) {
    Map<String, dynamic> data = <String, dynamic>{
      Keys.program: program._data,
      Keys.chargeNumber: chargeNumber,
      Keys.requestor: requestor,
      Keys.taskDescription: task,
      Keys.fromDate: DateFormats.iso8601Short.format(period.start),
      Keys.toDate: DateFormats.iso8601Short.format(period.end),
      Keys.travelPurpose: travelPurpose,
      Keys.travelDestination: travelDestination,
      Keys.travelParties: travelParties,
      Keys.expenses: <Map<String, dynamic>>[],
    };
    return ExpenseReport._(owner, data, program, period);
  }

  final Invoice _owner;
  final Map<String, dynamic> _data;

  /// The invoice to which this expense report belongs.
  Invoice get invoice => _owner;

  /// The index of this expense report in the list of expense reports.
  int get index => _owner.expenseReports._view.indexOf(this);

  double? _total;
  double get total {
    _owner._checkDisposed();
    return _total ??= expenses.fold<double>(0, (double sum, Expense exp) => sum + exp.amount);
  }

  @protected
  set total(double value) {
    value = roundToSignificantDigits(value, 2);
    double previousValue = total;
    if (value != previousValue) {
      // Order is important here; set this first to force the parent to run its
      // lazy total calculation before updating our total.
      final double previousInvoiceTotal = _owner.total;
      _total = value;
      _owner.total = previousInvoiceTotal + (value - previousValue);
    }
  }

  /// The "name" of this expense report.
  ///
  /// This is an amalgamation of the program name, the charge number (if
  /// supplied), and the task (if supplied).
  String? _name;
  String get name {
    _owner._checkDisposed();
    return _name ??= () {
      final StringBuffer buf = StringBuffer(program.name);
      final String chargeNumber = this.chargeNumber;
      if (chargeNumber.isNotEmpty) {
        buf.write(' ($chargeNumber)');
      }
      final String task = this.task;
      if (task.isNotEmpty) {
        buf.write(' ($task)');
      }
      return buf.toString();
    }();
  }

  Program? _program;

  @override
  Program get program {
    _owner._checkDisposed();
    return _program ??= Program._(_data[Keys.program]);
  }

  @override
  String get chargeNumber => _owner._checkDisposed(() => _data[Keys.chargeNumber]);

  @override
  String get requestor => _owner._checkDisposed(() => _data[Keys.requestor]);

  @override
  String get task => _owner._checkDisposed(() => _data[Keys.taskDescription]);

  DateRange? _period;
  @override
  DateRange get period {
    _owner._checkDisposed();
    return _period ??= DateRange._fromValues(_data[Keys.fromDate], _data[Keys.toDate]);
  }

  @override
  String get travelPurpose => _owner._checkDisposed(() => _data[Keys.travelPurpose]);

  @override
  String get travelDestination => _owner._checkDisposed(() => _data[Keys.travelDestination]);

  @override
  String get travelParties => _owner._checkDisposed(() => _data[Keys.travelParties]);

  /// The list of expenses in this expense report.
  ///
  /// Mutations on this list or to the expenses therein will notify registered
  /// [InvoiceListener] listeners.
  Expenses? _expenses;
  Expenses get expenses {
    _owner._checkDisposed();
    return _expenses ??= Expenses._fromData(_owner, this, _data);
  }

  Map<String, dynamic> serialize() => _data;
}

class ExpenseMetadata {
  const ExpenseMetadata({
    required this.ordinal,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
  });

  final int ordinal;
  final DateTime date;
  final ExpenseType type;
  final double amount;
  final String description;

  ExpenseMetadata copyWith({
    required int ordinal,
    DateTime? date,
    ExpenseType? type,
    double? amount,
    String? description,
  }) {
    return ExpenseMetadata(
      ordinal: ordinal,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}

/// The list of expenses in an expense report within an invoice.
///
/// Mutations to the list of expenses or to any expense in the list will
/// notify registered [InvoiceListener] listeners.
class Expenses with ForwardingIterable<Expense>, DisallowCollectionConversion<Expense> {
  Expenses._(this._owner, this._parent, this._data, this._view);

  factory Expenses._fromData(
    Invoice owner,
    ExpenseReport parent,
    Map<String, dynamic> expenseReportData,
  ) {
    final List<dynamic> rawExpenses = expenseReportData[Keys.expenses];
    final List<Map<String, dynamic>> expenses = rawExpenses.cast<Map<String, dynamic>>();
    final List<Expense> view = expenses
        .map<Expense>((Map<String, dynamic> expenseData) => Expense._(owner, parent, expenseData))
        .toList();
    return Expenses._(owner, parent, expenses, view);
  }

  final Invoice _owner;
  final ExpenseReport _parent;
  final List<Map<String, dynamic>> _data;
  final List<Expense> _view;

  @override
  @protected
  Iterable<Expense> get delegate => _view;

  Expense operator [](int index) => _view[index];

  Expense add(ExpenseMetadata entry) {
    _owner._checkDisposed();
    // Order is important here; set this first to force the parent to run its
    // lazy total calculation before adding the expense to _data.
    final double previousTotal = _parent.total;
    final Expense expense = Expense._fromParts(
      owner: _owner,
      parent: _parent,
      ordinal: entry.ordinal,
      date: entry.date,
      type: entry.type,
      amount: entry.amount,
      description: entry.description,
    );
    int insertIndex = _data.length;
    if (_comparator != null) {
      insertIndex = binarySearch(_view, expense, compare: _comparator!);
      if (insertIndex < 0) {
        insertIndex = -(insertIndex + 1);
      }
    }
    _view.insert(insertIndex, expense);
    _data.insert(insertIndex, expense.serialize());
    _owner._owner.onExpenseInserted(_parent.index, insertIndex);
    _owner._setIsDirty(true);
    _parent.total = previousTotal + entry.amount;
    return expense;
  }

  void remove(Iterable<Span> ranges) {
    _owner._checkDisposed();
    // Order is important here; set this first to force the parent to run its
    // lazy total calculation before removing the expense from _data.
    final double previousTotal = _parent.total;
    double totalRemoved = 0;
    for (Span span in ranges.toList().reversed) {
      assert(span.isNormalized);
      final List<Expense> removed = _view.sublist(span.start, span.end + 1);
      _view.removeRange(span.start, span.end + 1);
      _data.removeRange(span.start, span.end + 1);
      _owner._owner.onExpensesRemoved(_parent.index, span.start, removed);
      totalRemoved += removed
          .map<double>((Expense e) => e.amount)
          .reduce((double total, double amount) => total + amount);
    }
    _parent.total = previousTotal - totalRemoved;
    _owner._setIsDirty(true);
  }

  ExpenseComparator? _comparator;
  ExpenseComparator? get comparator => _comparator;
  set comparator(ExpenseComparator? value) {
    _owner._checkDisposed();
    _comparator = value;
    if (_comparator != null) {
      _view.sort(_comparator);
      _data.sort((Map<String, dynamic> m1, Map<String, dynamic> m2) {
        Expense e1 = Expense._(_owner, _parent, m1);
        Expense e2 = Expense._(_owner, _parent, m2);
        return _comparator!(e1, e2);
      });
    }
    // No need to notify listeners or mark dirty since nothing substantively
    // changed about the invoice (the caller is responsible for updating UI).
    // Further, the user can sort the expenses after the invoice is submitted,
    // which doesn't count as modifying the (read-only) invoice.
  }
}

typedef ExpenseComparator = int Function(Expense a, Expense b);

/// Class that represents an individual expense in an expense report.
///
/// Mutations on this class will notify registered [InvoiceListener]
/// listeners.
class Expense implements ExpenseMetadata {
  Expense._(this._owner, this._parent, this._data);

  factory Expense._fromParts({
    required Invoice owner,
    required ExpenseReport parent,
    required int ordinal,
    required DateTime date,
    required ExpenseType type,
    required double amount,
    required String description,
  }) {
    return Expense._(owner, parent, <String, dynamic>{
      Keys.ordinal: ordinal,
      Keys.date: DateFormats.iso8601Short.format(date),
      Keys.expenseType: type._data,
      Keys.amount: amount,
      Keys.description: description,
    });
  }

  final Invoice _owner;
  final ExpenseReport _parent;
  final Map<String, dynamic> _data;

  /// The index of this expense in the list of expenses.
  int get index => _parent.expenses._view.indexOf(this);

  DateTime? _date;

  /// The date of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  @override
  DateTime get date {
    _owner._checkDisposed();
    return _date ??= DateTime.parse(_data[Keys.date]);
  }

  set date(DateTime value) {
    _owner._checkDisposed();
    DateTime previousValue = date;
    if (value != previousValue) {
      _date = null;
      _data[Keys.date] = DateFormats.iso8601Short.format(value);
      _owner._owner.onExpenseUpdated(_parent.index, index, Keys.date, previousValue);
      _owner._setIsDirty(true);
    }
  }

  ExpenseType? _type;

  /// The type of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  @override
  ExpenseType get type {
    _owner._checkDisposed();
    return _type ??= ExpenseType._(_data[Keys.expenseType]);
  }

  set type(ExpenseType value) {
    _owner._checkDisposed();
    ExpenseType previousValue = type;
    if (value != previousValue) {
      _type = null;
      _data[Keys.expenseType] = value._data;
      _owner._owner.onExpenseUpdated(_parent.index, index, Keys.expenseType, previousValue);
      _owner._setIsDirty(true);
    }
  }

  /// The amount value of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  @override
  double get amount => _owner._checkDisposed(() => _data[Keys.amount].toDouble())!;

  set amount(double value) {
    _owner._checkDisposed();
    double previousAmount = amount;
    if (value != previousAmount) {
      // Order is important here; set this first to force the parent to run its
      // lazy total calculation before updating the amount.
      final double previousTotal = _parent.total;
      _data[Keys.amount] = value;
      _owner._owner.onExpenseUpdated(_parent.index, index, Keys.amount, previousAmount);
      _owner._setIsDirty(true);
      _parent.total = previousTotal + (value - previousAmount);
    }
  }

  /// The user-entered description of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  @override
  String get description => _owner._checkDisposed(() => _data[Keys.description])!;

  set description(String value) {
    _owner._checkDisposed();
    String previousValue = description;
    if (value != previousValue) {
      _data[Keys.description] = value;
      _owner._owner.onExpenseUpdated(_parent.index, index, Keys.description, previousValue);
      _owner._setIsDirty(true);
    }
  }

  /// The order in which the expense was originally added.
  int get ordinal => _owner._checkDisposed(() => _data[Keys.ordinal])!;

  @override
  ExpenseMetadata copyWith({
    required int ordinal,
    DateTime? date,
    ExpenseType? type,
    double? amount,
    String? description,
  }) {
    return Expense._fromParts(
      owner: _owner,
      parent: _parent,
      ordinal: ordinal,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> serialize() => _data;
}

/// Class representing the type of an expense line item.
///
/// This is the value of the [Expense.type] member.
@immutable
class ExpenseType implements Comparable<ExpenseType> {
  const ExpenseType._(this._data);

  final Map<String, dynamic> _data;

  /// A unique identified for this expense type.
  int get expenseTypeId => _data[Keys.expenseTypeId];

  /// The unique identifier for this expense type's parent.
  ///
  /// Not all expense types have a parent. Those that do form a taxonomy of
  /// expense types (e.g. "Office Supplies" > "Computer")
  int get parentExpenseTypeId => _data[Keys.parentExpenseTypeId];

  /// Whether this expense type should ever be shown to the user.
  bool get isVisible => _data[Keys.visible];

  /// Whether this expense type is selectable by the user.
  bool get isEnabled => _data[Keys.enabled];

  /// Whether this expense type constitutes reimbursable expenses.
  bool get isReimbursable => _data[Keys.reimbursable];

  /// The human-readable name of the expense type.
  String get name => _data[Keys.name];

  /// The long-form name of the expense type, not intended to be shown to
  /// the user.
  String get longName => _data[Keys.longName];

  /// The depth of the expense type in the tree of expense types.
  ///
  /// See also:
  ///
  ///  * [parentExpenseTypeId], which lays out how the tree is formed.
  int get depth => _data[Keys.depth];

  /// Administrative comment about the expense type.
  String? get comment => _data[Keys.comment];

  @override
  int get hashCode => expenseTypeId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseType && other.expenseTypeId == expenseTypeId;
  }

  @override
  int compareTo(ExpenseType other) {
    return name.compareTo(other.name);
  }
}

/// Class representing the list of accomplishments in an invoice.
///
/// Mutations to the list of accomplishments or to any accomplishment in the
/// list will notify registered [InvoiceListener] listeners.
class Accomplishments
    with ForwardingIterable<Accomplishment>, DisallowCollectionConversion<Accomplishment> {
  const Accomplishments._(this._owner, this._data, this._view);

  factory Accomplishments._fromRawData(Invoice owner, Map<String, dynamic> invoiceData) {
    final List<dynamic> rawAccomplishments = invoiceData.putIfAbsent(Keys.accomplishments, () => []);
    final List<Map<String, dynamic>> accomplishments =
        rawAccomplishments.cast<Map<String, dynamic>>();
    final List<Accomplishment> view = accomplishments
        .map<Accomplishment>((Map<String, dynamic> data) => Accomplishment._(owner, data))
        .toList();
    return Accomplishments._(owner, accomplishments, view);
  }

  final Invoice _owner;
  final List<Map<String, dynamic>> _data;
  final List<Accomplishment> _view;

  @override
  @protected
  Iterable<Accomplishment> get delegate => _view;

  /// Adds an accomplishment to the list of this invoice's accomplishments.
  ///
  /// Registered [InvoiceListener.onAccomplishmentInserted] listeners will be
  /// notified.
  Accomplishment add({required Program program}) {
    _owner._checkDisposed();
    final Accomplishment accomplishment = Accomplishment._fromParts(
      owner: _owner,
      program: program,
    );
    final int index = binarySearch(_view, accomplishment, compare: InvoiceEntryMetadata.compare);
    assert(index < 0);
    final int insertIndex = -(index + 1);
    _view.insert(insertIndex, accomplishment);
    _data.insert(insertIndex, accomplishment.serialize());
    _owner._owner.onAccomplishmentInserted(insertIndex);
    _owner._setIsDirty(true);
    return accomplishment;
  }

  int indexOf(Program program) {
    for (int i = 0; i < _data.length; i++) {
      final Accomplishment accomplishment = _view[i];
      if (accomplishment.program == program) {
        return i;
      }
    }
    return -1;
  }
}

/// Class representing a single accomplishment in an invoice.
///
/// Mutations on this class will notify registered [InvoiceListener] listeners.
class Accomplishment implements InvoiceEntryMetadata {
  Accomplishment._(this._owner, this._data, [this._program]);

  factory Accomplishment._fromParts({
    required Invoice owner,
    required Program program,
  }) {
    Map<String, dynamic> data = <String, dynamic>{
      Keys.program: program._data,
      Keys.description: '',
    };
    return Accomplishment._(owner, data, program);
  }

  final Invoice _owner;
  final Map<String, dynamic> _data;

  /// The invoice to which this accomplishment belongs.
  Invoice get invoice => _owner;

  /// The index of this accomplishment in the list of accomplishments.
  int get index => _owner.accomplishments._view.indexOf(this);

  Program? _program;

  /// The program (assignment) against which this accomplishment is to be
  /// recorded.
  Program get program {
    _owner._checkDisposed();
    return _program ??= Program._(_data[Keys.program]);
  }

  @override
  String? get chargeNumber => null;

  @override
  String? get requestor => null;

  @override
  String? get task => null;

  String get description => _owner._checkDisposed(() => _data[Keys.description])!;
  set description(String value) {
    _owner._checkDisposed();
    String previousValue = description;
    if (value != previousValue) {
      _data[Keys.description] = value;
      _owner._owner.onAccomplishmentTextUpdated(index, previousValue);
      _owner._setIsDirty(true);
    }
  }

  Map<String, dynamic> serialize() => _data;
}
