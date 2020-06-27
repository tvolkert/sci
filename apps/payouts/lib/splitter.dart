import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum ResizeMode {
  splitRatio,
  primaryRegion,
}

enum PrimaryRegion {
  before,
  after,
}

class Splitter extends StatefulWidget {
  Splitter({
    Key key,
    @required this.before,
    @required this.after,
    @required this.axis,
    this.initialSplitRatio = 0.5,
    this.resizeMode,
    this.primaryRegion,
    this.locked,
  }) : super(key: key);

  final Widget before;
  final Widget after;
  final Axis axis;
  final double initialSplitRatio;
  final ResizeMode resizeMode;
  final PrimaryRegion primaryRegion;
  final bool locked;

  @override
  _SplitterState createState() => _SplitterState();
}

class _SplitterState extends State<Splitter> {
  double splitRatio;

  @override
  void initState() {
    super.initState();
    splitRatio = widget.initialSplitRatio;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.axis) {
      case Axis.horizontal:
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double split = (constraints.maxWidth * splitRatio).floorToDouble();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: split, child: widget.before),
                MouseRegion(
                  cursor: SystemMouseCursors.horizontalDoubleArrow,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    dragStartBehavior: DragStartBehavior.down,
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      final double newSplit = split + details.delta.dx;
                      final double newSplitRatio =
                          newSplit / context.size.width;
                      setState(() {
                        splitRatio = newSplitRatio;
                      });
                    },
                    child: SizedBox(
                      width: 6,
                      child: Container(),
                    ),
                  ),
                ),
                Expanded(child: widget.after),
              ],
            );
          },
        );
        break;
      case Axis.vertical:
        break;
    }
    return SizedBox.expand(
      key: widget.key,
      child: Row(
        children: [],
      ),
    );
  }
}
