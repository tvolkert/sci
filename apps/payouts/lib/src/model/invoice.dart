import 'dart:convert';
import 'dart:io' show HttpHeaders, HttpStatus;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:payouts/src/pivot.dart';

import 'collections.dart';
import 'constants.dart';
import 'debug.dart';
import 'http.dart';
import 'pair.dart';
import 'user.dart';

class InvoiceBinding with ListenerNotifier<InvoiceListener>, InvoiceListenerNotifier {
  InvoiceBinding._();

  /// The singleton binding instance.
  static final InvoiceBinding instance = InvoiceBinding._();

  /// The currently open invoice, or null if no invoice is opened.
  Invoice _invoice;
  Invoice get invoice => _invoice;

  Future<Invoice> loadInvoice(int invoiceId, {Duration timeout = httpTimeout}) async {
    final Uri url = Server.uri(Server.invoiceUrl, query: <String, String>{
      QueryParameters.invoiceId: '$invoiceId',
    });
    final http.Response response =
        await UserBinding.instance.user.authenticate().get(url).timeout(timeout);
    if (response.statusCode == HttpStatus.ok) {
      final Map<String, dynamic> invoiceData = json.decode(response.body).cast<String, dynamic>();
      final Invoice previousInvoice = _invoice;
      _invoice = Invoice._(this, invoiceId, invoiceData);
      onInvoiceChanged(previousInvoice);
      if (previousInvoice != null) {
        previousInvoice._dispose();
      }
      return _invoice;
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }

  Future<Invoice> createInvoice(NewInvoiceProperties properties) async {
    final Uri url = Server.uri(Server.invoiceUrl);
    final http.Client client = UserBinding.instance.user.authenticate();
    final Map<String, dynamic> body = <String, dynamic>{
      Keys.invoiceNumber: properties.invoiceNumber,
      Keys.billingStart: properties.billingStart,
      Keys.billingDuration: properties.billingDuration.inDays,
    };
    final http.Response response = await client.post(url, body: json.encode(body));
    if (response.statusCode == HttpStatus.created) {
      final String location = response.headers[HttpHeaders.locationHeader];
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

  Future<void> save() async {
    final Uri url = Server.uri(Server.invoiceUrl);
    final http.Client client = UserBinding.instance.user.authenticate();
    final String serialized = invoice.serialize(markAsSubmitted: true);
    final http.Response response = await client.put(url, body: serialized);
    if (response.statusCode == HttpStatus.noContent) {
      invoice._setIsDirty(false);
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw const InvalidCredentials();
    } else {
      throw HttpStatusException(response.statusCode);
    }
  }

  Future<void> delete() async {
    // TODO
    await Future<void>.delayed(const Duration(seconds: 1));
    final Invoice previousInvoice = _invoice;
    _invoice = null;
    onInvoiceChanged(previousInvoice);
    if (previousInvoice != null) {
      previousInvoice._dispose();
    }
  }
}

@immutable
class NewInvoiceProperties {
  const NewInvoiceProperties({
    @required this.invoiceNumber,
    @required this.billingStart,
    this.billingDuration = const Duration(days: 14),
  })  : assert(invoiceNumber != null),
        assert(billingStart != null),
        assert(billingDuration != null);

  final String invoiceNumber;
  final String billingStart;
  final Duration billingDuration;
}

typedef InvoiceChangedHandler = void Function(Invoice oldInvoice);

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
    this.onInvoiceChanged,
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

  final InvoiceChangedHandler onInvoiceChanged;
  final InvoiceNumberChangedHandler onInvoiceNumberChanged;
  final InvoiceTotalChangedHandler onInvoiceTotalChanged;
  final InvoiceSubmittedHandler onSubmitted;
  final InvoiceDirtyChangedHandler onInvoiceDirtyChanged;
  final InvoiceTimesheetInsertedHandler onTimesheetInserted;
  final InvoiceTimesheetsRemovedHandler onTimesheetsRemoved;
  final InvoiceTimesheetUpdatedHandler onTimesheetUpdated;
  final InvoiceTimesheetHoursUpdatedHandler onTimesheetHoursUpdated;
  final InvoiceAccomplishmentInsertedHandler onAccomplishmentInserted;
  final InvoiceAccomplishmentTextUpdatedHandler onAccomplishmentTextUpdated;
  final InvoiceExpenseReportInsertedHandler onExpenseReportInserted;
  final InvoiceExpenseReportsRemovedHandler onExpenseReportsRemoved;
  final InvoiceExpenseInsertedHandler onExpenseInserted;
  final InvoiceExpenseUpdatedHandler onExpenseUpdated;
  final InvoiceExpensesRemovedHandler onExpensesRemoved;
}

mixin InvoiceListenerNotifier on ListenerNotifier<InvoiceListener> {
  @protected
  void onInvoiceChanged(Invoice oldInvoice) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceChanged != null) {
        listener.onInvoiceChanged(oldInvoice);
      }
    });
  }

  @protected
  void onInvoiceNumberChanged(String previousInvoiceNumber) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceNumberChanged != null) {
        listener.onInvoiceNumberChanged(previousInvoiceNumber);
      }
    });
  }

  @protected
  void onInvoiceTotalChanged(double previousTotal) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceTotalChanged != null) {
        listener.onInvoiceTotalChanged(previousTotal);
      }
    });
  }

  @protected
  void onSubmitted() {
    notifyListeners((InvoiceListener listener) {
      if (listener.onSubmitted != null) {
        listener.onSubmitted();
      }
    });
  }

  @protected
  void onInvoiceDirtyChanged() {
    notifyListeners((InvoiceListener listener) {
      if (listener.onInvoiceDirtyChanged != null) {
        listener.onInvoiceDirtyChanged();
      }
    });
  }

  @protected
  void onTimesheetInserted(int timesheetsIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetInserted != null) {
        listener.onTimesheetInserted(timesheetsIndex);
      }
    });
  }

  @protected
  void onTimesheetsRemoved(int timesheetsIndex, Iterable<Timesheet> removed) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetsRemoved != null) {
        listener.onTimesheetsRemoved(timesheetsIndex, removed);
      }
    });
  }

  @protected
  void onTimesheetUpdated(int timesheetsIndex, String key, dynamic previousValue) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetUpdated != null) {
        listener.onTimesheetUpdated(timesheetsIndex, key, previousValue);
      }
    });
  }

  @protected
  void onTimesheetHoursUpdated(int timesheetsIndex, int dayIndex, double previousHours) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onTimesheetHoursUpdated != null) {
        listener.onTimesheetHoursUpdated(timesheetsIndex, dayIndex, previousHours);
      }
    });
  }

  @protected
  void onAccomplishmentInserted(int accomplishmentsIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onAccomplishmentInserted != null) {
        listener.onAccomplishmentInserted(accomplishmentsIndex);
      }
    });
  }

  @protected
  void onAccomplishmentTextUpdated(int accomplishmentsIndex, String previousDescription) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onAccomplishmentTextUpdated != null) {
        listener.onAccomplishmentTextUpdated(accomplishmentsIndex, previousDescription);
      }
    });
  }

  @protected
  void onExpenseReportInserted(int expenseReportsIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseReportInserted != null) {
        listener.onExpenseReportInserted(expenseReportsIndex);
      }
    });
  }

  @protected
  void onExpenseReportsRemoved(int expenseReportsIndex, Iterable<ExpenseReport> removed) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseReportsRemoved != null) {
        listener.onExpenseReportsRemoved(expenseReportsIndex, removed);
      }
    });
  }

  @protected
  void onExpenseInserted(int expenseReportsIndex, int expensesIndex) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseInserted != null) {
        listener.onExpenseInserted(expenseReportsIndex, expensesIndex);
      }
    });
  }

  @protected
  void onExpenseUpdated(
    int expenseReportsIndex,
    int expensesIndex,
    String key,
    dynamic previousValue,
  ) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpenseUpdated != null) {
        listener.onExpenseUpdated(expenseReportsIndex, expensesIndex, key, previousValue);
      }
    });
  }

  @protected
  void onExpensesRemoved(int expenseReportsIndex, int expensesIndex, Iterable<Expense> removed) {
    notifyListeners((InvoiceListener listener) {
      if (listener.onExpensesRemoved != null) {
        listener.onExpensesRemoved(expenseReportsIndex, expensesIndex, removed);
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
  Invoice._(this._owner, this.id, this._data)
      : assert(id != null),
        assert(_data != null),
        assert(debugUseFakeHttpLayer || _data[Keys.invoiceId] == id);

  final InvoiceBinding _owner;
  bool _disposed = false;

  /// The invoice identifier, unique across all invoices.
  final int id;

  final Map<String, dynamic> _data;

  void _dispose() {
    _disposed = true;
  }

  T _checkDisposed<T>([T Function() callback]) {
    assert(!_disposed);
    if (callback != null) {
      return callback();
    }
    return null;
  }

  double _total;
  double get total {
    _checkDisposed();
    return _total ??= computeTotal();
  }

  @protected
  set total(double value) {
    assert(value != null);
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
  String get vendor => _checkDisposed(() => _data[Keys.vendor]);

  /// The invoice number.
  ///
  /// When this is changed, [InvoiceListener.onInvoiceNumberChanged] listeners
  /// will be notified.
  String get invoiceNumber => _checkDisposed(() => _data[Keys.invoiceNumber]);
  set invoiceNumber(String value) {
    _checkDisposed();
    assert(value != null);
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
  set isSubmitted(bool value) {
    _checkDisposed();
    assert(value != null && value);
    if (value != isSubmitted) {
      _data[Keys.submitted] = value;
      _owner.onSubmitted();
    }
  }

  /// The billing period for the invoice.
  DateRange _billingPeriod;
  DateRange get billingPeriod {
    _checkDisposed();
    _billingPeriod ??= DateRange._fromRawData(_data);
    return _billingPeriod;
  }

  /// This invoice's timesheets.
  ///
  /// Mutations on the list of timesheets or any individual timesheet will
  /// notify registered [InvoiceListener] listeners.
  Timesheets _timesheets;
  Timesheets get timesheets {
    _checkDisposed();
    _timesheets ??= Timesheets._fromRawData(this, _data);
    return _timesheets;
  }

  /// This invoice's expense reports.
  ///
  /// Mutations on the list of expense reports or any individual expense report
  /// will notify registered [InvoiceListener] listeners.
  ExpenseReports _expenseReports;
  ExpenseReports get expenseReports {
    _checkDisposed();
    _expenseReports ??= ExpenseReports._fromRawData(this, _data);
    return _expenseReports;
  }

  /// This invoice's accomplishments.
  ///
  /// Mutations on the list of accomplishments or any individual accomplishment
  /// will notify registered [InvoiceListener] listeners.
  Accomplishments _accomplishments;
  Accomplishments get accomplishments {
    _checkDisposed();
    _accomplishments ??= Accomplishments._fromRawData(this, _data);
    return _accomplishments;
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
    assert(markAsSubmitted != null);
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

  factory DateRange._fromRawData(Map<String, dynamic> invoiceData) {
    final DateTime start = DateTime.parse(invoiceData[Keys.billingStart]);
    final int durationInDays = invoiceData[Keys.billingDuration];
    return DateRange._(_generateRange(start, durationInDays));
  }

  factory DateRange._fromStartEnd(String startDate, String endDate) {
    final DateTime start = DateTime.parse(startDate);
    final DateTime end = DateTime.parse(endDate);
    final int durationInDays = end.difference(start).inDays + 1;
    return DateRange._(_generateRange(start, durationInDays));
  }

  final List<DateTime> _range;

  /// The first date in the range (inclusive).
  DateTime get start => _range.first;

  /// The last date in the range (inclusive).
  DateTime get end => _range.last;

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
}

/// Class that represents the list of timesheets in an invoice.
///
/// Mutations on this class will notify registered [InvoiceListener] listeners.
class Timesheets with ForwardingIterable<Timesheet>, DisallowCollectionConversion<Timesheet> {
  const Timesheets._(this._owner, this._data);

  factory Timesheets._fromRawData(Invoice owner, Map<String, dynamic> invoiceData) {
    final List<dynamic> rawTimesheets = invoiceData[Keys.timesheets];
    final List<Timesheet> timesheets = rawTimesheets
        .cast<Map<String, dynamic>>()
        .map<Timesheet>((Map<String, dynamic> data) => Timesheet._(owner, data))
        .toList();
    return Timesheets._(owner, timesheets);
  }

  final Invoice _owner;
  final List<Timesheet> _data;

  @override
  @protected
  Iterable<Timesheet> get delegate => _data;

  /// Computes the total dollar amount for this expense report.
  @protected
  @visibleForTesting
  double computeTotal() {
    return fold<double>(0, (double sum, Timesheet timesheet) => sum + timesheet.total);
  }

  /// Adds a timesheet with the specified metadata to this invoice's list of
  /// timesheets.
  ///
  /// Registered [InvoiceListener.onTimesheetInserted] listeners will
  /// be notified.
  Timesheet add({Program program, String chargeNumber, String requestor, String task}) {
    _owner._checkDisposed();
    // TODO: this list should probably be sorted.
    final int insertIndex = _data.length - 1;
    final Timesheet timesheet = Timesheet._fromParts(
      owner: _owner,
      program: program,
      chargeNumber: chargeNumber,
      requestor: requestor,
      taskDescription: task,
    );
    _data.insert(insertIndex, timesheet);
    _owner._owner.onTimesheetInserted(insertIndex);
    _owner._setIsDirty(true);
    return timesheet;
  }

  /// Removes the timesheet at the specified index.
  ///
  /// Registered [InvoiceListener.onTimesheetsRemoved] listeners will
  /// be notified.
  Timesheet removeAt(int index) {
    _owner._checkDisposed();
    final Timesheet removed = _data.removeAt(index);
    _owner._owner.onTimesheetsRemoved(index, <Timesheet>[removed]);
    _owner._setIsDirty(true);
    return removed;
  }

  /// Removes all timesheets for which the specified `test` returns true.
  ///
  /// Registered [InvoiceListener.onTimesheetsRemoved] listeners will
  /// be notified.
  void removeWhere(bool Function(Timesheet timesheet) test) {
    _owner._checkDisposed();
    for (int i = length - 1; i >= 0; i--) {
      if (test(_data[i])) {
        removeAt(i);
      }
    }
  }
}

/// Class that represents an individual timesheet within an invoice.
///
/// Mutations on this class will notify registered [InvoiceListener] listeners.
class Timesheet {
  Timesheet._(this._owner, this._data, [this._program]);

  factory Timesheet._fromParts({
    @required Invoice owner,
    @required Program program,
    @required String chargeNumber,
    @required String requestor,
    @required String taskDescription,
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

  /// The index of this timesheet in the invoice's list of timesheets.
  int get _index => _owner.timesheets._data.indexOf(this);

  double _total;
  double get total {
    _owner._checkDisposed();
    if (_total == null) {
      final double rate = program.rate;
      _total ??= hours.fold<double>(0, (double sum, double value) => sum + value) * rate;
    }
    return _total;
  }

  @protected
  set total(double value) {
    double previousValue = total;
    if (value != previousValue) {
      // Order is important here; set this first to force the parent to run its
      // lazy total calculation before updating our total.
      final double previousInvoiceTotal = _owner.total;
      _total = value;
      _owner.total = previousInvoiceTotal + (value - previousValue);
    }
  }

  /// The program (assignment data) against which this timesheet is to be
  /// billed.
  Program _program;
  Program get program {
    _owner._checkDisposed();
    _program ??= Program._(_data[Keys.program]);
    return _program;
  }

  /// The charge number of this timesheet.
  ///
  /// If [Program.requiresChargeNumber] is false this this timesheet's
  /// [program], then the charge number will be the empty string.
  String get chargeNumber => _owner._checkDisposed(() => _data[Keys.chargeNumber]);

  /// The name of the client who requested the work done in this timesheet.
  ///
  /// If [Program.requiresRequestor] is false this this timesheet's
  /// [program], then the requestor will be the empty string.
  String get requestor => _owner._checkDisposed(() => _data[Keys.requestor]);

  /// The task description for this timesheet.
  ///
  /// This optional field allows the consultant to describe the timesheet to
  /// help them organize their invoice.
  String get task => _owner._checkDisposed(() => _data[Keys.taskDescription]);

  /// The hour entries in this timesheet.
  ///
  /// The number of entries will match the billing duration
  /// ([DateRange.duration], in days) of the invoice.
  Hours _hours;
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
    String chargeNumber,
    String requestor,
    String taskDescription,
  }) {
    _owner._checkDisposed();
    final int timesheetsIndex = _owner.timesheets._data.indexOf(this);
    if (chargeNumber != null) {
      String previousValue = _data[Keys.chargeNumber];
      if (chargeNumber != previousValue) {
        _data[Keys.chargeNumber] = chargeNumber;
        _owner._owner.onTimesheetUpdated(timesheetsIndex, Keys.chargeNumber, previousValue);
        _owner._setIsDirty(true);
      }
    }
    if (requestor != null) {
      String previousValue = _data[Keys.requestor];
      if (requestor != previousValue) {
        _data[Keys.requestor] = requestor;
        _owner._owner.onTimesheetUpdated(timesheetsIndex, Keys.requestor, previousValue);
        _owner._setIsDirty(true);
      }
    }
    if (taskDescription != null) {
      String previousValue = _data[Keys.taskDescription];
      if (taskDescription != previousValue) {
        _data[Keys.taskDescription] = taskDescription;
        _owner._owner.onTimesheetUpdated(timesheetsIndex, Keys.taskDescription, previousValue);
        _owner._setIsDirty(true);
      }
    }
  }
}

/// Class representing the list of hours values within a timesheet.
///
/// Mutations on this class will cause registered [InvoiceListener] listeners
/// to be notified.
class Hours with ForwardingIterable<double>, DisallowCollectionConversion<double> {
  const Hours._(this._owner, this._parent, this._data);

  factory Hours._fromRawData(Invoice owner, Timesheet parent, Map<String, dynamic> timesheetData) {
    final List<dynamic> rawHours = timesheetData[Keys.hours];
    final List<double> hours =
        rawHours.cast<num>().map<double>((num value) => value.toDouble()).toList();
    return Hours._(owner, parent, hours);
  }

  final Invoice _owner;
  final Timesheet _parent;
  final List<double> _data;

  @override
  @protected
  Iterable<double> get delegate => _data;

  /// Gets the hours value at the specified index.
  double operator [](int index) => _owner._checkDisposed(() => _data[index]);

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
      final double previousTotal = _parent.total;
      _data[index] = value;
      _owner._owner.onTimesheetHoursUpdated(_parent._index, index, previousValue);
      _owner._setIsDirty(true);
      _parent.total = previousTotal + (value - previousValue) * _parent.program.rate;
    }
  }
}

/// Class that represents the list of expense reports in an invoice.
///
/// Mutations to the list of expense reports or to any expense report in the
/// list will notify registered [InvoiceListener] listeners.
class ExpenseReports
    with ForwardingIterable<ExpenseReport>, DisallowCollectionConversion<ExpenseReport> {
  const ExpenseReports._(this._owner, this._data);

  factory ExpenseReports._fromRawData(Invoice owner, Map<String, dynamic> invoiceData) {
    final List<dynamic> rawExpenseReports = invoiceData[Keys.expenseReports];
    final List<ExpenseReport> expenseReports = rawExpenseReports
        .cast<Map<String, dynamic>>()
        .map<ExpenseReport>((Map<String, dynamic> data) => ExpenseReport._(owner, data))
        .toList();
    return ExpenseReports._(owner, expenseReports);
  }

  final Invoice _owner;
  final List<ExpenseReport> _data;

  @override
  @protected
  Iterable<ExpenseReport> get delegate => _data;

  /// Computes the total dollar amount for this expense report.
  @protected
  @visibleForTesting
  double computeTotal() {
    return fold<double>(0, (double sum, ExpenseReport report) => sum + report.total);
  }

  /// Gets the expense report at the specified index.
  ExpenseReport operator [](int index) => _owner._checkDisposed(() => _data[index]);

  /// Adds an expense report with the specified metadata to this invoice's list
  /// of expense reports.
  ///
  /// Registered [InvoiceListener.onExpenseReportInserted] listeners will
  /// be notified.
  ExpenseReport add({
    Program program,
    String chargeNumber,
    String requestor,
    String task,
    DateRange period,
    String travelPurpose,
    String travelDestination,
    String travelParties,
  }) {
    _owner._checkDisposed();
    // TODO: this list should probably be sorted.
    final int insertIndex = _data.length - 1;
    final ExpenseReport expenseReport = ExpenseReport._fromParts(
      owner: _owner,
      program: program,
      chargeNumber: chargeNumber,
      requestor: requestor,
      task: task,
      period: period,
      travelPurpose: travelPurpose,
      travelDestination: travelDestination,
      travelParties: travelParties,
    );
    _data.insert(insertIndex, expenseReport);
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
    final ExpenseReport removed = _data.removeAt(index);
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
      if (test(_data[i])) {
        removeAt(i);
      }
    }
  }
}

/// An individual expense report in the invoice.
///
/// Mutations to the expense report or to any expenses in the report will
/// notify registered [InvoiceListener] listeners.
class ExpenseReport {
  ExpenseReport._(this._owner, this._data, [this._program, this._period]);

  factory ExpenseReport._fromParts({
    @required Invoice owner,
    @required Program program,
    @required String chargeNumber,
    @required String requestor,
    @required String task,
    @required DateRange period,
    @required String travelPurpose,
    @required String travelDestination,
    @required String travelParties,
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

  /// The index of this expense report in the list of expense reports.
  int get _index => _owner.expenseReports._data.indexOf(this);

  double _total;
  double get total {
    _owner._checkDisposed();
    return _total ??= expenses.fold<double>(0, (double sum, Expense exp) => sum + exp.amount);
  }

  @protected
  set total(double value) {
    double previousValue = total;
    if (value != previousValue) {
      // Order is important here; set this first to force the parent to run its
      // lazy total calculation before updating our total.
      final double previousInvoiceTotal = _owner.total;
      _total = value;
      _owner.total = previousInvoiceTotal + (value - previousValue);
    }
  }

  /// The program (assignment) against which this expense report is to be
  /// billed.
  Program _program;
  Program get program {
    _owner._checkDisposed();
    return _program ??= Program._(_data[Keys.program]);
  }

  /// The charge number of this expense report.
  ///
  /// If [Program.requiresChargeNumber] is false this this expense report's
  /// [program], then the charge number will be the empty string.
  String get chargeNumber => _owner._checkDisposed(_data[Keys.chargeNumber]);

  /// The name of the client who requested the work done in this expense
  /// report.
  ///
  /// If [Program.requiresRequestor] is false this this expense report's
  /// [program], then the requestor will be the empty string.
  String get requestor => _owner._checkDisposed(_data[Keys.requestor]);

  /// The task description for this expense report.
  ///
  /// This optional field allows the consultant to describe the expense report
  /// to help them organize their invoice.
  String get task => _owner._checkDisposed(_data[Keys.taskDescription]);

  /// The time period that this expense report covers.
  DateRange _period;
  DateRange get period {
    _owner._checkDisposed();
    return _period ??= DateRange._fromStartEnd(_data[Keys.fromDate], _data[Keys.toDate]);
  }

  /// The purpose of the travel, as indicated by the consultant.
  String get travelPurpose => _owner._checkDisposed(_data[Keys.travelPurpose]);

  /// The destination of the travel, as indicated by the consultant.
  String get travelDestination => _owner._checkDisposed(_data[Keys.travelDestination]);

  /// The client(s) visited as part of the travel, as indicated by the
  /// consultant.
  String get travelParties => _owner._checkDisposed(_data[Keys.travelParties]);

  /// The list of expenses in this expense report.
  ///
  /// Mutations on this list or to the expenses therein will notify registered
  /// [InvoiceListener] listeners.
  Expenses _expenses;
  Expenses get expenses {
    _owner._checkDisposed();
    return _expenses ??= Expenses._fromData(_owner, this, _data);
  }
}

/// The list of expenses in an expense report within an invoice.
///
/// Mutations to the list of expenses or to any expense in the list will
/// notify registered [InvoiceListener] listeners.
class Expenses with ForwardingIterable<Expense>, DisallowCollectionConversion<Expense> {
  const Expenses._(this._owner, this._parent, this._data);

  factory Expenses._fromData(
    Invoice owner,
    ExpenseReport parent,
    Map<String, dynamic> expenseReportData,
  ) {
    final List<dynamic> rawExpenses = expenseReportData[Keys.expenses];
    final List<Expense> expenses = rawExpenses
        .cast<Map<String, dynamic>>()
        .map<Expense>((Map<String, dynamic> expenseData) => Expense._(owner, parent, expenseData))
        .toList();
    return Expenses._(owner, parent, expenses);
  }

  final Invoice _owner;
  final ExpenseReport _parent;
  final List<Expense> _data;

  @override
  @protected
  Iterable<Expense> get delegate => _data;

  Expense add({DateTime date, ExpenseType type, double amount, String description}) {
    _owner._checkDisposed();
    // Order is important here; set this first to force the parent to run its
    // lazy total calculation before adding the expense to _data.
    final double previousTotal = _parent.total;
    // TODO: this list should probably be sorted.
    final int insertIndex = _data.length - 1;
    final Expense expense = Expense._fromParts(
      owner: _owner,
      parent: _parent,
      date: date,
      type: type,
      amount: amount,
      description: description,
    );
    _data.insert(insertIndex, expense);
    _owner._owner.onExpenseInserted(_parent._index, insertIndex);
    _owner._setIsDirty(true);
    _parent.total = previousTotal + amount;
    return expense;
  }

  Expense removeAt(int index) {
    _owner._checkDisposed();
    // Order is important here; set this first to force the parent to run its
    // lazy total calculation before removing the expense from _data.
    final double previousTotal = _parent.total;
    final Expense removed = _data.removeAt(index);
    _owner._owner.onExpensesRemoved(_parent._index, index, <Expense>[removed]);
    _owner._setIsDirty(true);
    _parent.total = previousTotal - removed.amount;
    return removed;
  }

  void removeWhere(bool Function(Expense expense) test) {
    _owner._checkDisposed();
    for (int i = length - 1; i >= 0; i--) {
      if (test(_data[i])) {
        removeAt(i);
      }
    }
  }
}

/// Class that represents an individual expense in an expense report.
///
/// Mutations on this class will notify registered [InvoiceListener]
/// listeners.
class Expense {
  Expense._(this._owner, this._parent, this._data);

  factory Expense._fromParts({
    @required Invoice owner,
    @required ExpenseReport parent,
    DateTime date,
    ExpenseType type,
    double amount,
    String description,
  }) {
    return Expense._(owner, parent, <String, dynamic>{
      Keys.date: date,
      Keys.expenseType: type,
      Keys.amount: amount,
      Keys.description: description,
      Keys.ordinal: 0, // TODO: monotonically increasing value
    });
  }

  final Invoice _owner;
  final ExpenseReport _parent;
  final Map<String, dynamic> _data;

  int get _index => _parent.expenses._data.indexOf(this);

  /// The date of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  DateTime _date;
  DateTime get date {
    _owner._checkDisposed();
    return _date ??= DateTime.parse(_data[Keys.date]);
  }

  set date(DateTime value) {
    _owner._checkDisposed();
    DateTime previousValue = date;
    if (value != previousValue) {
      _data[Keys.date] = value;
      _owner._owner.onExpenseUpdated(_parent._index, _index, Keys.date, previousValue);
      _owner._setIsDirty(true);
    }
  }

  /// The type of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  ExpenseType _type;
  ExpenseType get type {
    _owner._checkDisposed();
    return _type ??= ExpenseType._(_data[Keys.expenseType]);
  }

  set type(ExpenseType value) {
    _owner._checkDisposed();
    ExpenseType previousValue = type;
    if (value != previousValue) {
      _data[Keys.expenseType] = value;
      _owner._owner.onExpenseUpdated(_parent._index, _index, Keys.expenseType, previousValue);
      _owner._setIsDirty(true);
    }
  }

  /// The amount value of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  double get amount => _owner._checkDisposed(() => _data[Keys.amount].toDouble());
  set amount(double value) {
    _owner._checkDisposed();
    double previousAmount = amount;
    if (value != previousAmount) {
      // Order is important here; set this first to force the parent to run its
      // lazy total calculation before updating the amount.
      final double previousTotal = _parent.total;
      _data[Keys.amount] = value;
      _owner._owner.onExpenseUpdated(_parent._index, _index, Keys.amount, previousAmount);
      _owner._setIsDirty(true);
      _parent.total = previousTotal + (value - previousAmount);
    }
  }

  /// The user-entered description of the expense.
  ///
  /// When this is changed, [InvoiceListener.onExpenseUpdated] listeners
  /// will be notified.
  String get description => _owner._checkDisposed(() => _data[Keys.description]);
  set description(String value) {
    _owner._checkDisposed();
    String previousValue = description;
    if (value != previousValue) {
      _data[Keys.description] = value;
      _owner._owner.onExpenseUpdated(_parent._index, _index, Keys.description, previousValue);
      _owner._setIsDirty(true);
    }
  }

  /// The order in which the expense was originally added.
  int get ordinal => _owner._checkDisposed(() => _data[Keys.ordinal]);
}

/// Class representing the type of an expense line item.
///
/// This is the value of the [Expense.type] member.
@immutable
class ExpenseType {
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
  String get comment => _data[Keys.comment];

  @override
  int get hashCode => expenseTypeId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseType && other.expenseTypeId == expenseTypeId;
  }
}

/// Class representing the list of accomplishments in an invoice.
///
/// Mutations to the list of accomplishments or to any accomplishment in the
/// list will notify registered [InvoiceListener] listeners.
class Accomplishments
    with ForwardingIterable<Accomplishment>, DisallowCollectionConversion<Accomplishment> {
  const Accomplishments._(this._owner, this._data);

  factory Accomplishments._fromRawData(Invoice owner, Map<String, dynamic> invoiceData) {
    final List<dynamic> rawAccomplishments = invoiceData[Keys.accomplishments];
    final List<Accomplishment> accomplishments = rawAccomplishments
        .cast<Map<String, dynamic>>()
        .map<Accomplishment>((Map<String, dynamic> data) => Accomplishment._(owner, data))
        .toList();
    return Accomplishments._(owner, accomplishments);
  }

  final Invoice _owner;
  final List<Accomplishment> _data;

  @override
  @protected
  Iterable<Accomplishment> get delegate => _data;

  /// Adds an accomplishment to the list of this invoice's accomplishments.
  ///
  /// Registered [InvoiceListener.onAccomplishmentInserted] listeners will be
  /// notified.
  Accomplishment add({Program program}) {
    _owner._checkDisposed();
    // TODO: this list should probably be sorted.
    final int insertIndex = _data.length - 1;
    final Accomplishment accomplishment = Accomplishment._fromParts(
      owner: _owner,
      program: program,
    );
    _data.insert(insertIndex, accomplishment);
    _owner._owner.onAccomplishmentInserted(insertIndex);
    _owner._setIsDirty(true);
    return accomplishment;
  }
}

/// Class representing a single accomplishment in an invoice.
///
/// Mutations on this class will notify registered [InvoiceListener] listeners.
class Accomplishment {
  Accomplishment._(this._owner, this._data, [this._program]);

  factory Accomplishment._fromParts({
    @required Invoice owner,
    Program program,
  }) {
    Map<String, dynamic> data = <String, dynamic>{
      Keys.program: program._data,
      Keys.description: '',
    };
    return Accomplishment._(owner, data, program);
  }

  final Invoice _owner;
  final Map<String, dynamic> _data;

  /// The index of this accomplishment in the list of accomplishments.
  int get _index => _owner.accomplishments._data.indexOf(this);

  /// The program (assignment) against which this accomplishment is to be
  /// recorded.
  Program _program;
  Program get program {
    _owner._checkDisposed();
    return _program ??= Program._(_data[Keys.program]);
  }

  String get description => _owner._checkDisposed(() => _data[Keys.description]);
  set description(String value) {
    _owner._checkDisposed();
    String previousValue = description;
    if (value != previousValue) {
      _data[Keys.description] = value;
      _owner._owner.onAccomplishmentTextUpdated(_index, previousValue);
      _owner._setIsDirty(true);
    }
  }
}
