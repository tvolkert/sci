import 'dart:math' as math;

import 'package:intl/intl.dart' as intl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:payouts/src/model/invoice.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart' as ib;
import 'package:payouts/ui/invoice/invoice_scaffold.dart';

class BillableHoursPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InvoiceScaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _BillableHoursTable(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add a new timesheet',
        onPressed: null,
      ),
    );
  }
}

class _BillableHoursTable extends StatelessWidget {
  const _BillableHoursTable({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Invoice invoice = ib.InvoiceBinding.of(context).invoice;
    DateTime billingStart = invoice.billingPeriod.start;
    int billingDuration = invoice.billingPeriod.duration.inDays;
    TextStyle textStyle = DefaultTextStyle.of(context).style;
    TextStyle dateCellStyle = textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18);

    RenderBox paragraph = RenderParagraph(
      TextSpan(text: '10/28', style: dateCellStyle),
      textDirection: TextDirection.ltr,
    );
    double dateCellWidth = paragraph.getMaxIntrinsicWidth(100) + 1;

    List<Widget> rows = <Widget>[
      HeaderRow(dateCellWidth: dateCellWidth, timesheets: invoice.timesheets),
      Divider(height: 8),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: Iterable<int>.generate(billingDuration).map<Widget>((int offset) {
              return BodyRow(
                timesheets: invoice.timesheets,
                billingStart: billingStart,
                dayOffset: offset,
                dateCellWidth: dateCellWidth,
                dateCellStyle: dateCellStyle,
              );
            }).toList(),
          ),
        ),
      ),
    ];

    return Column(
      children: rows,
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({
    Key key,
    @required this.dateCellWidth,
    @required this.timesheets,
  }) : super(key: key);

  final double dateCellWidth;
  final Timesheets timesheets;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(width: dateCellWidth),
        ...timesheets.map<Widget>((Timesheet timesheet) {
          String program = timesheet.program.name;
          Uid uid = Uid(
            timesheet.program.assignmentId,
            timesheet.chargeNumber,
            timesheet.requestor,
          );
          return ProgramHeader(program: program, tag: uid);
        }),
      ],
    );
  }
}

class BodyRow extends StatefulWidget {
  const BodyRow({
    Key key,
    @required this.timesheets,
    @required this.billingStart,
    @required this.dayOffset,
    @required this.dateCellWidth,
    @required this.dateCellStyle,
  })  : assert(timesheets != null),
        assert(billingStart != null),
        assert(dayOffset != null),
        assert(dateCellWidth != null),
        assert(dateCellStyle != null),
        super(key: key);

  final Timesheets timesheets;
  final DateTime billingStart;
  final int dayOffset;
  final double dateCellWidth;
  final TextStyle dateCellStyle;

  @override
  _BodyRowState createState() => _BodyRowState();
}

// TODO: fix smell of this not having any state (see calls to [setState])
class _BodyRowState extends State<BodyRow> {
  @override
  Widget build(BuildContext context) {
    // bool isWeekend = day.weekday > 5;
    DateTime day = widget.billingStart.add(Duration(days: widget.dayOffset));
    num sum = widget.timesheets.fold<num>(0, (num previous, Timesheet timesheet) {
      return previous + timesheet.hours[widget.dayOffset];
    });

    return Row(
      // decoration: isWeekend ? BoxDecoration(color: Color.fromARGB(0xff, 0xee, 0xee, 0xff)) : null,
      children: <Widget>[
        DateHeader(
          day: day,
          width: widget.dateCellWidth,
          style: widget.dateCellStyle,
        ),
        ...widget.timesheets.map<Widget>((Timesheet timesheet) {
          Hours hours = timesheet.hours;
          int assignmentId = timesheet.program.assignmentId;
          String chargeNumber = timesheet.chargeNumber;
          String requestor = timesheet.requestor;
          TimeValue value = TimeValue.fromValue(hours[widget.dayOffset]);
          Uid uid = Uid(assignmentId, chargeNumber, requestor);

          return Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push<TimeValue>(HeroDialogRoute(
                  builder: (BuildContext context) {
                    return EditHoursDialog(
                      tag: uid.copyWith(dayOffset: widget.dayOffset),
                      value: value,
                    );
                  },
                )).then((TimeValue newValue) {
                  if (newValue == null) {
                    // The user canceled.
                    return;
                  }
                  setState(() {
                    hours[widget.dayOffset] = newValue.value;
                  });
                });
              },
              child: FixedHoursBox(
                value: value,
                tag: uid.copyWith(dayOffset: widget.dayOffset),
              ),
            ),
          );
        }),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FixedHoursBox(
            value: TimeValue.fromValue(sum),
            summary: true,
          ),
        ),
      ],
    );
  }
}

class EditHoursDialog extends StatefulWidget {
  const EditHoursDialog({
    Key key,
    @required this.tag,
    @required this.value,
    this.min = 0,
    this.max = 24,
  })  : assert(value != null),
        assert(min >= 0),
        assert(max <= 24),
        assert(min <= max),
        super(key: key);

  final Uid tag;
  final TimeValue value;
  final double min;
  final double max;

  @override
  _EditHoursDialogState createState() => _EditHoursDialogState();
}

class _EditHoursDialogState extends State<EditHoursDialog> {
  TimeValue value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop<TimeValue>(value);
          },
        ),
        Center(
          child: EditableHoursBox(
            initialValue: value,
            tag: widget.tag,
            onChanged: (TimeValue value) {
              this.value = value;
            },
          ),
        ),
      ],
    );
  }
}

class ProgramHeader extends StatelessWidget {
  const ProgramHeader({
    Key key,
    @required this.program,
    @required this.tag,
  })  : assert(program != null),
        assert(tag != null),
        super(key: key);

  final String program;
  final Uid tag;

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.subhead;

    return Transform.translate(
      offset: Offset(-6, -6),
      child: Transform.rotate(
        alignment: Alignment.bottomCenter,
        angle: math.pi / 9,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 40,
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(
                  program,
                  style: style,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateHeader extends StatelessWidget {
  const DateHeader({
    Key key,
    @required this.day,
    @required this.width,
    @required this.style,
  }) : super(key: key);

  final DateTime day;
  final double width;
  final TextStyle style;

  static final intl.DateFormat formattedDate = intl.DateFormat('MM/dd');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 56,
      child: Center(
        child: Text(
          formattedDate.format(day),
          style: style,
        ),
      ),
    );
  }
}

class HoursBoxHero extends StatelessWidget {
  HoursBoxHero({
    @required this.child,
    this.leaveChildInPlace = true,
    @required this.tag,
    Key key,
  })  : assert(child != null),
        assert(tag != null),
        super(key: key);

  final Widget child;
  final bool leaveChildInPlace;
  final Uid tag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (Rect begin, Rect end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      placeholderBuilder: leaveChildInPlace ? (BuildContext context, Size heroSize, Widget child) => child : null,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

class FixedHoursBox extends StatelessWidget {
  const FixedHoursBox({
    Key key,
    @required this.value,
    this.tag,
    this.summary = false,
  })  : assert(value != null),
        assert(summary != null),
        super(key: key);

  final TimeValue value;
  final Uid tag;
  final bool summary;

  static final intl.NumberFormat hoursFormat = intl.NumberFormat(r'#0');
  static final intl.NumberFormat minutesFormat = intl.NumberFormat(r'00');

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    if (summary) {
      style = DefaultTextStyle.of(context).style;
      style = style.copyWith(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
      );
    }

    StringBuffer buf = StringBuffer()
      ..write(hoursFormat.format(value.hours))
      ..write(':')
      ..write(minutesFormat.format(value.minutes));
    Widget result = RoundedBox(
      summary: summary,
      child: value.value == 0 ? Container() : Text(buf.toString(), style: style),
    );

    if (tag != null) {
      result = HoursBoxHero(
        tag: tag,
        child: result,
      );
    }

    return result;
  }
}

class EditableHoursBox extends StatelessWidget {
  const EditableHoursBox({
    Key key,
    @required this.initialValue,
    @required this.tag,
    @required this.onChanged,
    this.scale = 4,
  })  : assert(initialValue != null),
        assert(tag != null),
        assert(scale != null),
        assert(scale > 0),
        super(key: key);

  final TimeValue initialValue;
  final Uid tag;
  final ValueChanged<TimeValue> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return HoursBoxHero(
      tag: tag,
      leaveChildInPlace: false,
      child: RoundedBox(
        scale: scale,
        child: HoursAndMinutesPicker(
          initialValue: initialValue,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class RoundedBox extends StatelessWidget {
  RoundedBox({
    Key key,
    @required this.child,
    this.size = 40,
    this.scale = 1,
    this.borderWidth = 1,
    this.borderRadius = 5,
    this.summary = false,
  })  : assert(child != null),
        assert(scale != null),
        assert(scale > 0),
        assert(borderWidth != null),
        assert(borderWidth > 0),
        assert(summary != null),
        super(key: key);

  final Widget child;
  final double size;
  final double scale;
  final double borderWidth;
  final double borderRadius;
  final bool summary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * scale,
      height: size * scale,
      child: FittedBox(
        fit: BoxFit.fill,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              width: borderWidth,
              color: summary ? Colors.blue : Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius - 1)),
              child: SizedBox(
                width: size - 2 * borderWidth,
                height: size - 2 * borderWidth,
                child: Center(
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimeValue implements Comparable<num> {
  const TimeValue(this.hours, this.minutes);

  factory TimeValue.fromValue(num value) {
    int hours = value.toInt();
    num fractionalHour = hours > 0 ? value.remainder(hours) : value;
    int minutes = (fractionalHour * Duration.minutesPerHour).toInt();
    return TimeValue(hours, minutes);
  }

  final int hours;
  final int minutes;

  TimeValue operator +(int minutes) {
    int newMinutes = this.minutes + minutes % Duration.minutesPerHour;
    int newHours = this.hours + minutes ~/ Duration.minutesPerHour;
    if (newMinutes == Duration.minutesPerHour) {
      newMinutes = 0;
      newHours += 1;
    }
    return TimeValue(newHours, newMinutes);
  }

  num get value => hours + minutes / Duration.minutesPerHour;

  @override
  int compareTo(num other) => value.compareTo(other);

  bool operator <(num value) => compareTo(value) < 0;

  bool operator <=(num value) => compareTo(value) <= 0;

  bool operator >(num value) => compareTo(value) > 0;

  bool operator >=(num value) => compareTo(value) >= 0;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    TimeValue timeValue = other;
    return hours == timeValue.hours && minutes == timeValue.minutes;
  }

  @override
  int get hashCode => hashValues(hours, minutes);

  TimeValue copyWith({
    int hours,
    int minutes,
  }) {
    return TimeValue(hours ?? this.hours, minutes ?? this.minutes);
  }
}

class HoursAndMinutesPicker extends StatefulWidget {
  const HoursAndMinutesPicker({
    Key key,
    @required this.initialValue,
    @required this.onChanged,
  })  : assert(initialValue != null),
        assert(initialValue >= 0),
        assert(initialValue <= Duration.hoursPerDay),
        assert(onChanged != null),
        super(key: key);

  final TimeValue initialValue;
  final ValueChanged<TimeValue> onChanged;

  @override
  _HoursAndMinutesPickerState createState() => _HoursAndMinutesPickerState();
}

class _HoursAndMinutesPickerState extends State<HoursAndMinutesPicker> {
  TimeValue _value;

  static const int _minutesInterval = 5;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    while (_value.minutes % _minutesInterval != 0) {
      // Legacy invoice support; adjust minutes to be divisible by 5.
      _value++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: IntPicker(
            initialValue: _value.hours,
            max: Duration.hoursPerDay - 1,
            onChanged: (int hours) {
              _value = _value.copyWith(hours: hours);
              widget.onChanged(_value);
            },
          ),
        ),
        Align(
          alignment: FractionalOffset(0, 0.37),
          child: Text(
            ':',
            style: Theme.of(context).textTheme.body1,
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          child: IntPicker(
            initialValue: _value.minutes,
            max: Duration.minutesPerHour - _minutesInterval,
            interval: _minutesInterval,
            textAlign: TextAlign.left,
            onChanged: (int minutes) {
              _value = _value.copyWith(minutes: minutes);
              widget.onChanged(_value);
            },
          ),
        ),
      ],
    );
  }
}

class IntPicker extends StatefulWidget {
  const IntPicker({
    Key key,
    @required this.initialValue,
    this.min = 0,
    @required this.max,
    this.interval = 1,
    @required this.onChanged,
    this.textAlign = TextAlign.right,
  })  : assert(initialValue != null),
        assert(min != null),
        assert(max != null),
        assert(interval != null),
        assert(onChanged != null),
        assert(textAlign != null),
        assert(min <= max),
        assert(initialValue >= min),
        assert(initialValue <= max),
        assert((initialValue - min) % interval == 0),
        assert((max - min) % interval == 0),
        super(key: key);

  final int initialValue;
  final int min;
  final int max;
  final int interval;
  final ValueChanged<int> onChanged;
  final TextAlign textAlign;

  int get count => (max - min) ~/ interval + 1;

  @override
  _IntPickerState createState() => _IntPickerState();
}

class _IntPickerState extends State<IntPicker> {
  ScrollController controller;

  /// We present [widget.max] as the first index (0) and [widget.min] as the
  /// last index ([widget.count] - 1) in order for the user to drag their
  /// finger down to pick higher numbers.
  int _flipIndex(int index) {
    return widget.count - 1 - index;
  }

  /// Converts an item index into the value that's presented to the user.
  int _indexToValue(int index) {
    assert(index >= 0);
    assert(index < widget.count);
    return _flipIndex(index) * widget.interval + widget.min;
  }

  /// Converts a value that's presented to the user into an item index.
  int _valueToIndex(int value) {
    assert((value - widget.min) % widget.interval == 0);
    int index = (value - widget.min) ~/ widget.interval;
    return _flipIndex(index);
  }

  @override
  void initState() {
    controller = FixedExtentScrollController(
      initialItem: _valueToIndex(widget.initialValue),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView(
      controller: controller,
      physics: FixedExtentScrollPhysics(),
      offAxisFraction: 2,
      squeeze: 0.7,
      itemExtent: 20,
      perspective: 0.005,
      onSelectedItemChanged: (int index) {
        widget.onChanged(_indexToValue(index));
      },
      children: <Widget>[
        ...Iterable<int>.generate(widget.count).map<Widget>((int index) {
          String displayValue = _indexToValue(index).toString().padLeft(2, '0');
          return SizedBox.expand(
            child: Text(
              displayValue,
              style: Theme.of(context).textTheme.body1,
              textAlign: widget.textAlign,
            ),
          );
        }),
      ],
    );
  }
}

class Uid {
  const Uid(this.assignmentId, this.chargeNumber, this.requestor, [this.dayOffset]);

  final int assignmentId;
  final String chargeNumber;
  final String requestor;
  final int dayOffset;

  Uid copyWith({
    int assignmentId,
    String chargeNumber,
    String requestor,
    int dayOffset,
  }) {
    return Uid(
      assignmentId ?? this.assignmentId,
      chargeNumber ?? this.chargeNumber,
      requestor ?? this.requestor,
      dayOffset ?? this.dayOffset,
    );
  }

  @override
  bool operator ==(dynamic other) {
    return other.runtimeType == runtimeType &&
        assignmentId == other.assignmentId &&
        chargeNumber == other.chargeNumber &&
        requestor == other.requestor &&
        dayOffset == other.dayOffset;
  }

  @override
  int get hashCode => hashValues(assignmentId, chargeNumber, requestor, dayOffset);
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    @required this.builder,
  });

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }
}
