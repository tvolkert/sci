import 'dart:math' as math;

import 'package:intl/intl.dart' as intl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:payouts/model/invoice.dart';
import 'package:payouts/ui/invoice/invoice_binding.dart';
import 'package:payouts/ui/invoice/invoice_scaffold.dart';

class BillableHoursPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BillableHoursPageState();
  }
}

class _BillableHoursPageState extends State<BillableHoursPage> {
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

class _BillableHoursTable extends StatefulWidget {
  const _BillableHoursTable({Key key}) : super(key: key);

  @override
  _BillableHoursTableState createState() => _BillableHoursTableState();
}

class _BillableHoursTableState extends State<_BillableHoursTable> {
  @override
  Widget build(BuildContext context) {
    Invoice invoice = InvoiceBinding.of(context).invoice;
    DateTime billingStart = DateTime.parse(invoice.data['billing_start']);
    int billingDuration = invoice.data['billing_duration'];
    List<Map<String, dynamic>> timesheets = invoice.data['timesheets'].cast<Map<String, dynamic>>();
    TextStyle textStyle = DefaultTextStyle.of(context).style;
    TextStyle dateCellStyle = textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18);

    RenderBox paragraph = RenderParagraph(
      TextSpan(text: '10/28', style: dateCellStyle),
      textDirection: TextDirection.ltr,
    );
    double dateCellWidth = paragraph.getMaxIntrinsicWidth(100) + 1;

    List<Widget> rows = <Widget>[
      HeaderRow(dateCellWidth: dateCellWidth, timesheets: timesheets),
      Divider(height: 8),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: Iterable<int>.generate(billingDuration).map<Widget>((int offset) {
              return BodyRow(
                timesheets: timesheets,
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

  final List<Map<String, dynamic>> timesheets;
  final DateTime billingStart;
  final int dayOffset;
  final double dateCellWidth;
  final TextStyle dateCellStyle;

  @override
  _BodyRowState createState() => _BodyRowState();
}

class _BodyRowState extends State<BodyRow> {
  @override
  Widget build(BuildContext context) {
    // bool isWeekend = day.weekday > 5;
    DateTime day = widget.billingStart.add(Duration(days: widget.dayOffset));
    num sum = widget.timesheets.fold<num>(0, (num previous, Map<String, dynamic> timesheet) {
      List<num> hours = timesheet['hours'].cast<num>();
      return previous + hours[widget.dayOffset];
    });

    return Row(
      // decoration: isWeekend ? BoxDecoration(color: Color.fromARGB(0xff, 0xee, 0xee, 0xff)) : null,
      children: <Widget>[
        DateCell(
          day: day,
          width: widget.dateCellWidth,
          style: widget.dateCellStyle,
          stacked: true,
        ),
        ...widget.timesheets.map<Widget>((Map<String, dynamic> timesheet) {
          List<num> hours = timesheet['hours'].cast<num>();
          int assignmentId = timesheet['program']['assignment_id'];
          String chargeNumber = timesheet['charge_number'];
          String requestor = timesheet['requestor'];
          num value = hours[widget.dayOffset];
          Uid uid = Uid(assignmentId, chargeNumber, requestor);

          return Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push<num>(HeroDialogRoute(
                  builder: (BuildContext context) {
                    return EditHoursDialog(
                      day: day,
                      dateCellWidth: widget.dateCellWidth,
                      dateCellStyle: widget.dateCellStyle,
                      programTag: uid,
                      program: timesheet['program']['name'],
                      hoursTag: uid.copyWith(dayOffset: widget.dayOffset),
                      hoursValue: value,
                    );
                  },
                )).then((num newValue) {
                  if (newValue == null) {
                    // The user canceled.
                    return;
                  }
                  setState(() {
                    hours[widget.dayOffset] = newValue;
                  });
                });
              },
              child: HoursBox(
                tag: uid.copyWith(dayOffset: widget.dayOffset),
                value: value,
                stacked: true,
              ),
            ),
          );
        }),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: HoursBox(
            borderColor: Colors.blue,
            emphasized: true,
            value: sum,
          ),
        ),
      ],
    );
  }
}

class EditHoursDialog extends StatefulWidget {
  const EditHoursDialog({
    Key key,
    @required this.day,
    @required this.dateCellWidth,
    @required this.dateCellStyle,
    @required this.programTag,
    @required this.program,
    @required this.hoursTag,
    @required this.hoursValue,
  })  : assert(hoursValue != null),
        super(key: key);

  final DateTime day;
  final double dateCellWidth;
  final TextStyle dateCellStyle;
  final Uid programTag;
  final String program;
  final Uid hoursTag;
  final num hoursValue;

  @override
  _EditHoursDialogState createState() => _EditHoursDialogState();
}

class _EditHoursDialogState extends State<EditHoursDialog> with TickerProviderStateMixin {
  AnimationController controller;
  num value;

  static final intl.NumberFormat format = intl.NumberFormat(r'#,##0.00');

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(microseconds: 300),
      vsync: this,
    );
    value = widget.hoursValue;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Text('Edit Hours'),
        content: IntrinsicHeight(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 90,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Date:'),
                      ),
                    ),
                    DateCell(
                      width: widget.dateCellWidth,
                      day: widget.day,
                      style: widget.dateCellStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 90,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Program:'),
                      ),
                    ),
                    ProgramHeader(
                      program: widget.program,
                      tag: widget.programTag,
                      rotated: false,
                    ),
                  ],
                ),
              ),
              SizedBox(
                //height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 90,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Hours:'),
                      ),
                    ),
                    HoursBox(
                      editable: true,
                      tag: widget.hoursTag,
                      value: value,
                      format: format,
                    ),
                  ],
                ),
              ),
//              SizedBox(
//                height: 45,
//                child: Slider(
//                  min: 0,
//                  max: 16,
//                  value: value.toDouble(),
//                  divisions: 16 * 4,
//                  onChanged: (double newValue) {
//                    setState(() {
//                      value = newValue;
//                    });
//                  },
//                ),
//              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(value),
            child: Text('OK'),
          ),
        ],
      ),
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
  final List<Map<String, dynamic>> timesheets;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(width: dateCellWidth),
        ...timesheets.map<Widget>((Map<String, dynamic> timesheet) {
          String program = timesheet['program']['name'];
          Uid uid = Uid(
            timesheet['program']['assignment_id'],
            timesheet['charge_number'],
            timesheet['requestor'],
          );
          return ProgramHeader(program: program, tag: uid);
        }),
      ],
    );
  }
}

class ProgramHeader extends StatelessWidget {
  const ProgramHeader({
    Key key,
    @required this.program,
    @required this.tag,
    this.rotated = true,
  })  : assert(program != null),
        assert(tag != null),
        assert(rotated != null),
        super(key: key);

  final String program;
  final Uid tag;
  final bool rotated;

  Widget _newRotatedBox(TextStyle style) {
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

  Widget _newPlainBox(TextStyle style) {
    return SizedBox(
      height: 40,
      width: 120,
      child: Center(
        child: Text(
          program,
          style: style,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }

  RectTween _createRectTween(Rect begin, Rect end) {
    return MaterialRectArcMaxRectTween(begin: begin, end: end);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.subhead;
    Widget result = rotated ? _newRotatedBox(style) : _newPlainBox(style);

    result = Hero(
      tag: tag,
      child: result,
      createRectTween: _createRectTween,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        Tween<double> rotationTween = Tween<double>();
        if (flightDirection == HeroFlightDirection.push) {
          rotationTween.begin = 29 / 36;
          rotationTween.end = 1;
        } else {
          rotationTween.begin = 0;
          rotationTween.end = 7 / 36;
        }
        Tween<Offset> slideTween = Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0),
        );
        if (flightDirection == HeroFlightDirection.push) {
          slideTween.begin = Offset(0.141, -0.01);
        } else {
          slideTween.end = Offset(-0.065, -0.11);
        }
        final Hero toHero = toHeroContext.widget;
        return SlideTransition(
          position: slideTween.animate(animation),
          child: RotationTransition(
            turns: rotationTween.animate(animation),
            child: toHero.child,
          ),
        );
      },
    );

    if (rotated) {
      result = Stack(children: <Widget>[_newRotatedBox(style), result]);
    }

    return result;
  }
}

class MaterialRectArcMaxRectTween extends MaterialRectArcTween {
  MaterialRectArcMaxRectTween({
    Rect begin,
    Rect end,
  })  : _width = math.max(begin.width, end.width),
        _height = math.max(begin.height, end.height),
        super(begin: begin, end: end);

  final double _width;
  final double _height;

  @override
  Rect lerp(double t) {
    Rect unmodified = super.lerp(t);
    return Rect.fromCenter(
      center: unmodified.center,
      width: _width,
      height: _height,
    );
  }
}

class DateCell extends StatelessWidget {
  const DateCell({
    Key key,
    @required this.day,
    @required this.width,
    @required this.style,
    this.stacked = false,
  }) : super(key: key);

  final DateTime day;
  final double width;
  final TextStyle style;
  final bool stacked;

  static final intl.DateFormat formattedDate = intl.DateFormat('MM/dd');

  SizedBox _newBox() {
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

  @override
  Widget build(BuildContext context) {
    Widget result = Hero(
      tag: day,
      child: _newBox(),
    );

    if (stacked) {
      result = Stack(children: <Widget>[_newBox(), result]);
    }

    return result;
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

class HoursBox extends StatelessWidget {
  const HoursBox({
    Key key,
    @required this.value,
    this.tag,
    this.stacked = false,
    this.emphasized = false,
    this.editable = false,
    this.borderColor = Colors.grey,
    this.format,
  })  : assert(value != null),
        assert(stacked != null),
        assert(emphasized != null),
        assert(borderColor != null),
        super(key: key);

  final num value;
  final Uid tag;
  final bool stacked;
  final bool emphasized;
  final bool editable;
  final Color borderColor;
  final intl.NumberFormat format;

  Widget _newBox(BuildContext context) {
    TextStyle style;
    if (emphasized) {
      style = DefaultTextStyle.of(context).style;
      style = style.copyWith(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
      );
    }

    Widget child;
    if (editable) {
      style = Theme.of(context).textTheme.body1;
      child = ListWheelScrollView(
        offAxisFraction: 2,
        squeeze: 0.7,
        itemExtent: 20,
        perspective: 0.005,
        onSelectedItemChanged: (int index) {},
        children: <Widget>[
          ...Iterable<int>.generate(17 * 10).map<Widget>((int index) {
            return Text(format.format(index.toDouble() / 10), style: style);
          }),
        ],
      );
    } else {
      String formattedValue = format != null ? format.format(value) : '$value';
      child = value == 0 ? Container() : Text(formattedValue, style: style);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: SizedBox(
        width: 40,
        height: 40,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = _newBox(context);

    if (tag != null) {
      result = Hero(
        tag: tag,
        child: Material(
          child: result,
        ),
      );
    }

    if (stacked) {
      result = Stack(children: <Widget>[_newBox(context), result]);
    }

    return result;
  }
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    @required this.builder,
  });

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 1000);

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
