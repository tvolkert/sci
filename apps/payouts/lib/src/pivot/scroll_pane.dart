import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'scroll_bar.dart';

class ScrollPaneTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ScrollPane(
        horizontalScrollBarPolicy: ScrollBarPolicy.auto,
        verticalScrollBarPolicy: ScrollBarPolicy.auto,
        corner: Image.asset('assets/IMG_20200701_131732.jpg', fit: BoxFit.cover),
        columnHeader: ColoredBox(
          color: Color(0xffff0000),
          child: Table(
            defaultColumnWidth: FixedColumnWidth(100),
            children: [
              TableRow(
                children: [
                  Text('HAAA'),
                  Text('Hb'),
                  Text('Hc'),
                  Text('Hd'),
                  Text('He'),
                  Text('Hf'),
                  Text('Hg'),
                  Text('Hh'),
                  Text('Hi'),
                  Text('Hj'),
                  Text('Hk'),
                ],
              ),
            ],
          ),
        ),
        rowHeader: ColoredBox(
          color: Color(0xff00ff00),
          child: Table(
            defaultColumnWidth: FixedColumnWidth(100),
            columnWidths: {0: IntrinsicColumnWidth()},
            children: [
              TableRow(children: [SizedBox(height: 100), Text('0H')]),
              TableRow(children: [SizedBox(height: 100), Text('1H')]),
              TableRow(children: [SizedBox(height: 100), Text('2H')]),
              TableRow(children: [SizedBox(height: 100), Text('3H')]),
              TableRow(children: [SizedBox(height: 100), Text('4H')]),
              TableRow(children: [SizedBox(height: 100), Text('5H')]),
            ],
          ),
        ),
//        view: ColoredBox(
//          color: Color(0xff0000ff),
//          child: Table(
//            defaultColumnWidth: FixedColumnWidth(100),
//            columnWidths: {0: IntrinsicColumnWidth(), 12: FixedColumnWidth(2)},
//            children: [
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('0a'),
//                  Text('0b'),
//                  Text('0c'),
//                  Text('0d'),
//                  Text('0e'),
//                  Text('0f'),
//                  Text('0g'),
//                  Text('0h'),
//                  Text('0i'),
//                  Text('0j'),
//                  Text('0k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('1a'),
//                  Text('1b'),
//                  Text('1c'),
//                  Text('1d'),
//                  Text('1e'),
//                  Text('1f'),
//                  Text('1g'),
//                  Text('1h'),
//                  Text('1i'),
//                  Text('1j'),
//                  Text('1k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('2a'),
//                  Text('2b'),
//                  Text('2c'),
//                  Text('2d'),
//                  Text('2e'),
//                  Text('2f'),
//                  Text('2g'),
//                  Text('2h'),
//                  Text('2i'),
//                  Text('2j'),
//                  Text('2k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('3a'),
//                  Text('3b'),
//                  Text('3c'),
//                  Text('3d'),
//                  Text('3e'),
//                  Text('3f'),
//                  Text('3g'),
//                  Text('3h'),
//                  Text('3i'),
//                  Text('3j'),
//                  Text('3k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('4a'),
//                  Text('4b'),
//                  Text('4c'),
//                  Text('4d'),
//                  Text('4e'),
//                  Text('4f'),
//                  Text('4g'),
//                  Text('4h'),
//                  Text('4i'),
//                  Text('4j'),
//                  Text('4k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('5a'),
//                  Text('5b'),
//                  Text('5c'),
//                  Text('5d'),
//                  Text('5e'),
//                  Text('5f'),
//                  Text('5g'),
//                  Text('5h'),
//                  Text('5i'),
//                  Text('5j'),
//                  Text('5k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//            ],
//          ),
//        ),
        view: Image.asset('assets/IMG_20200701_131732.jpg'),
      ),
    );
  }
}

/// The policy that dictates how a [ScrollPane] will lay its [ScrollPane.view]
/// out within a given [Axis], which directly affects how and when the
/// scrollbar is shown in that axis.
///
/// See also:
///
///  * [ScrollPane.horizontalScrollBarPolicy], which specifies the policy for a
///    [ScrollPane]'s horizontal axis.
///  * [ScrollPane.verticalScrollBarPolicy], which specifies the policy for a
///    [ScrollPane]'s vertical axis.
enum ScrollBarPolicy {
  /// Lays the view out with unconstrained size in the axis, and shows a
  /// scrollbar only when the viewport's size is less than needed to display
  /// the entirety of the view.
  ///
  /// This policy is somewhat expensive in terms of layout performance.
  auto,

  /// Lays the view out with unconstrained size in the axis, and never shows
  /// a scrollbar, even if the viewport's size is less than needed to display
  /// the entirety of the view.
  ///
  /// The scroll pane will still respond to trackpad / mouse wheel events by
  /// scrolling.
  ///
  /// Along with the [always] and [stretch] policies, this policy is the
  /// cheapest in terms of  layout performance.
  never,

  /// Lays the view out with unconstrained size in the axis, and always shows a
  /// scrollbar, even if the viewport's size is large enough to display the
  /// entirety of the view.
  ///
  /// If the viewport's size is large enough to display the entirety of the
  /// view, the scrollback will be disabled.
  ///
  /// Along with the [never] and [stretch] policies, this policy is the
  /// cheapest in terms of  layout performance.
  always,

  /// Lays the view out with tight constraints such that the view will be
  /// exactly the same size in the axis as the viewport.
  ///
  /// With this policy, a scrollbar will never be shown because the view is
  /// always exactly as big as the viewport, even if that size is less than
  /// the view's intrinsic size.
  ///
  /// Along with the [always] and [never] policies, this policy is the
  /// cheapest in terms of  layout performance.
  stretch,

  /// Gives the view at least its min intrinsic size, and stretches the view
  /// to match the viewport's size in the axis if there's any excess space.
  ///
  /// The existence of the scrollbar is the same with this policy as with the
  /// [auto] policy. The difference between the two policies is that with this
  /// policy, when the scrollbar is not needed, the view will be stretched to
  /// exactly fit the size of the viewport in the axis.
  ///
  /// This policy can necessitate two layout passes of the view and is the most
  /// expensive policy in terms of layout performance.
  expand,
}

class ScrollPane extends StatelessWidget {
  const ScrollPane({
    Key key,
    this.horizontalScrollBarPolicy = ScrollBarPolicy.auto,
    this.verticalScrollBarPolicy = ScrollBarPolicy.auto,
    this.rowHeader,
    this.columnHeader,
    this.corner,
    @required this.view,
  })  : assert(horizontalScrollBarPolicy != null),
        assert(verticalScrollBarPolicy != null),
        assert(view != null),
        super(key: key);

  /// The policy for how to lay the view out and show a scroll bar in the
  /// horizontal axis.
  ///
  /// Must be non-null. Defaults to [ScrollBarPolicy.auto].
  final ScrollBarPolicy horizontalScrollBarPolicy;

  /// The policy for how to lay the view out and show a scroll bar in the
  /// vertical axis.
  ///
  /// Must be non-null. Defaults to [ScrollBarPolicy.auto].
  final ScrollBarPolicy verticalScrollBarPolicy;

  /// Optional widget that will be laid out to the left of the view, vertically
  /// aligned with the top of the view.
  ///
  /// The row header will scroll vertically with the scroll pane, but it will
  /// remain fixed in place in the horizontal axis, even when the view is
  /// scrolled horizontally.
  final Widget rowHeader;

  /// Optional widget that will be laid out to the top of the view,
  /// horizontally aligned with the left of the view.
  ///
  /// The column header will scroll horizontally with the scroll pane, but it
  /// will remain fixed in place in the vertical axis, even when the view is
  /// scrolled vertically.
  final Widget columnHeader;

  /// Optional widget that will be laid out above the row header and to the
  /// left of the column header.
  ///
  /// If this widget is not specified, and the row header and column header
  /// are non-null, then a default "empty" corner will be automatically
  /// created and laid out in this spot.
  final Widget corner;

  /// The main scrollable widget to be shown in the viewport of this scroll
  /// pane.
  final Widget view;

  @override
  Widget build(BuildContext context) {
    return _ScrollPane(
      view: view,
      rowHeader: rowHeader,
      columnHeader: columnHeader,
      corner: corner,
      horizontalScrollBarPolicy: horizontalScrollBarPolicy,
      verticalScrollBarPolicy: verticalScrollBarPolicy,
      topLeftCorner: const _EmptyCorner(),
      bottomLeftCorner: const _EmptyCorner(),
      bottomRightCorner: const _EmptyCorner(),
      topRightCorner: const _EmptyCorner(),
      horizontalScrollBar: ScrollBar(
        orientation: Axis.horizontal,
        unitIncrement: 10,
      ),
      verticalScrollBar: ScrollBar(
        orientation: Axis.vertical,
        unitIncrement: 10,
      ),
    );
  }
}

class _EmptyCorner extends LeafRenderObjectWidget {
  const _EmptyCorner({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEmptyCorner();
}

class _RenderEmptyCorner extends RenderBox {
  static const Color backgroundColor = Color(0xfff0ece7);

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    context.canvas.drawRect(offset & size, paint);
  }
}

class _ScrollPane extends RenderObjectWidget {
  const _ScrollPane({
    Key key,
    @required this.view,
    @required this.rowHeader,
    @required this.columnHeader,
    @required this.corner,
    @required this.topLeftCorner,
    @required this.bottomLeftCorner,
    @required this.bottomRightCorner,
    @required this.topRightCorner,
    @required this.horizontalScrollBar,
    @required this.verticalScrollBar,
    @required this.horizontalScrollBarPolicy,
    @required this.verticalScrollBarPolicy,
  }) : super(key: key);

  final Widget view;
  final Widget rowHeader;
  final Widget columnHeader;
  final Widget corner;
  final Widget topLeftCorner;
  final Widget bottomLeftCorner;
  final Widget bottomRightCorner;
  final Widget topRightCorner;
  final Widget horizontalScrollBar;
  final Widget verticalScrollBar;
  final ScrollBarPolicy horizontalScrollBarPolicy;
  final ScrollBarPolicy verticalScrollBarPolicy;

  @override
  RenderObjectElement createElement() => _ScrollPaneElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScrollPane(
      horizontalScrollBarPolicy: horizontalScrollBarPolicy,
      verticalScrollBarPolicy: verticalScrollBarPolicy,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderScrollPane renderScrollPane) {
    renderScrollPane
      ..horizontalScrollBarPolicy = horizontalScrollBarPolicy
      ..verticalScrollBarPolicy = verticalScrollBarPolicy;
  }
}

enum _ScrollPaneSlot {
  view,
  rowHeader,
  columnHeader,
  corner,
  topLeftCorner,
  bottomLeftCorner,
  bottomRightCorner,
  topRightCorner,
  horizontalScrollBar,
  verticalScrollBar,
}

class _ScrollPaneElement extends RenderObjectElement {
  _ScrollPaneElement(_ScrollPane widget) : super(widget);

  Element _view;
  Element _rowHeader;
  Element _columnHeader;
  Element _corner;
  Element _topLeftCorner;
  Element _bottomLeftCorner;
  Element _bottomRightCorner;
  Element _topRightCorner;
  Element _horizontalScrollBar;
  Element _verticalScrollBar;

  @override
  _ScrollPane get widget => super.widget as _ScrollPane;

  @override
  RenderScrollPane get renderObject => super.renderObject as RenderScrollPane;

  @override
  void update(_ScrollPane newWidget) {
    // TODO: anything to do here?
    super.update(newWidget);
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    if (widget.view != null) _view = inflateWidget(widget.view, _ScrollPaneSlot.view);
    if (widget.rowHeader != null) _rowHeader = inflateWidget(widget.rowHeader, _ScrollPaneSlot.rowHeader);
    if (widget.columnHeader != null) _columnHeader = inflateWidget(widget.columnHeader, _ScrollPaneSlot.columnHeader);
    if (widget.corner != null) _corner = inflateWidget(widget.corner, _ScrollPaneSlot.corner);
    if (widget.topLeftCorner != null)
      _topLeftCorner = inflateWidget(widget.topLeftCorner, _ScrollPaneSlot.topLeftCorner);
    if (widget.bottomLeftCorner != null)
      _bottomLeftCorner = inflateWidget(widget.bottomLeftCorner, _ScrollPaneSlot.bottomLeftCorner);
    if (widget.bottomRightCorner != null)
      _bottomRightCorner = inflateWidget(widget.bottomRightCorner, _ScrollPaneSlot.bottomRightCorner);
    if (widget.topRightCorner != null)
      _topRightCorner = inflateWidget(widget.topRightCorner, _ScrollPaneSlot.topRightCorner);
    if (widget.horizontalScrollBar != null)
      _horizontalScrollBar = inflateWidget(widget.horizontalScrollBar, _ScrollPaneSlot.horizontalScrollBar);
    if (widget.verticalScrollBar != null)
      _verticalScrollBar = inflateWidget(widget.verticalScrollBar, _ScrollPaneSlot.verticalScrollBar);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    visitor(_view);
    if (_rowHeader != null) visitor(_rowHeader);
    if (_columnHeader != null) visitor(_columnHeader);
    if (_corner != null) visitor(_corner);
    if (_topLeftCorner != null) visitor(_topLeftCorner);
    if (_bottomLeftCorner != null) visitor(_bottomLeftCorner);
    if (_bottomRightCorner != null) visitor(_bottomRightCorner);
    if (_topRightCorner != null) visitor(_topRightCorner);
    if (_horizontalScrollBar != null) visitor(_horizontalScrollBar);
    if (_verticalScrollBar != null) visitor(_verticalScrollBar);
  }

  @override
  void insertChildRenderObject(RenderBox child, _ScrollPaneSlot slot) {
    switch (slot) {
      case _ScrollPaneSlot.view:
        renderObject.view = child;
        break;
      case _ScrollPaneSlot.rowHeader:
        renderObject.rowHeader = child;
        break;
      case _ScrollPaneSlot.columnHeader:
        renderObject.columnHeader = child;
        break;
      case _ScrollPaneSlot.corner:
        renderObject.corner = child;
        break;
      case _ScrollPaneSlot.topLeftCorner:
        renderObject.topLeftCorner = child;
        break;
      case _ScrollPaneSlot.bottomLeftCorner:
        renderObject.bottomLeftCorner = child;
        break;
      case _ScrollPaneSlot.bottomRightCorner:
        renderObject.bottomRightCorner = child;
        break;
      case _ScrollPaneSlot.topRightCorner:
        renderObject.topRightCorner = child;
        break;
      case _ScrollPaneSlot.horizontalScrollBar:
        renderObject.horizontalScrollBar = child;
        break;
      case _ScrollPaneSlot.verticalScrollBar:
        renderObject.verticalScrollBar = child;
        break;
    }
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slot) {
    throw UnsupportedError('moveChildRenderObject()');
  }

  @override
  void removeChildRenderObject(RenderBox child) {
    assert(child.parent == renderObject);
    throw UnimplementedError();
  }
}

// TODO do we get any benefit to this implementing RenderAbstractViewport?
class RenderScrollPane extends RenderBox implements ScrollBarValueListener {
  RenderScrollPane({
    ScrollBarPolicy horizontalScrollBarPolicy,
    ScrollBarPolicy verticalScrollBarPolicy,
  })  : assert(horizontalScrollBarPolicy != null),
        assert(verticalScrollBarPolicy != null),
        _horizontalScrollBarPolicy = horizontalScrollBarPolicy,
        _verticalScrollBarPolicy = verticalScrollBarPolicy;

  static const double _horizontalReveal = 30;
  static const double _verticalReveal = 30;

  /// Positions the row header, column header, and view based on the given
  /// scroll offset, row header width, and column header height.
  ///
  /// If the `scrollOffset` argument is not specified, the value will be taken
  /// from the [scrollOffset] property.
  ///
  /// If the `rowHeaderWidth` argument is not specified, the value will be
  /// taken from the size of [rowHeader].
  ///
  /// If the `columnHeaderHeight` argument is not specified, the value will be
  /// taken from the size of [columnHeader].
  void _positionMovableChildren({
    Offset scrollOffset,
    double rowHeaderWidth,
    double columnHeaderHeight,
  }) {
    scrollOffset ??= this.scrollOffset;
    rowHeaderWidth ??= rowHeader?.size?.width ?? 0;
    columnHeaderHeight ??= columnHeader?.size?.height ?? 0;

    if (view != null) {
      _ScrollPaneParentData parentData = parentDataFor(view);
      parentData.offset = Offset(rowHeaderWidth - scrollOffset.dx, columnHeaderHeight - scrollOffset.dy);
      parentData.visible = true;
    }

    if (columnHeader != null) {
      _ScrollPaneParentData parentData = parentDataFor(columnHeader);
      parentData.offset = Offset(rowHeaderWidth - scrollOffset.dx, 0);
      parentData.visible = true;
    }

    if (rowHeader != null) {
      _ScrollPaneParentData parentData = parentDataFor(rowHeader);
      parentData.offset = Offset(0, columnHeaderHeight - scrollOffset.dy);
      parentData.visible = true;
    }

    markNeedsPaint();
  }

  /// Returns an offset that is as close to to the proposed scroll offset
  /// while being within the legal bounds defined by this scroll pane.
  ///
  /// If the `horizontalScrollBarHeight` argument is not specified, the value
  /// will be taken from [horizontalScrollBar].
  ///
  /// If the `verticalScrollBarWidth` argument is not specified, the value
  /// will be taken from [verticalScrollBar].
  Offset _boundsCheckScrollOffset(
      Offset proposedScrollOffset, {
        double horizontalScrollBarHeight,
        double verticalScrollBarWidth,
      }) {
    return Offset(
      math.min(math.max(proposedScrollOffset.dx, 0), getMaxScrollLeft(verticalScrollBarWidth: verticalScrollBarWidth)),
      math.min(
          math.max(proposedScrollOffset.dy, 0), getMaxScrollTop(horizontalScrollBarHeight: horizontalScrollBarHeight)),
    );
  }

  /// Returns the maximum legal vertical scroll offset defined by this scroll
  /// pane.
  ///
  /// If the `horizontalScrollBarHeight` argument is not specified, the value
  /// will be taken from [horizontalScrollBar].
  double getMaxScrollTop({double horizontalScrollBarHeight}) {
    if (view == null) return 0;

    double viewHeight = view.size.height;
    double columnHeaderHeight = 0;
    double height = size.height;

    if (parentDataFor(horizontalScrollBar).visible) {
      horizontalScrollBarHeight ??= horizontalScrollBar.size.height;
    }
    horizontalScrollBarHeight ??= 0;

    if (columnHeader != null) columnHeaderHeight = columnHeader.size.height;
    return math.max(viewHeight + columnHeaderHeight + horizontalScrollBarHeight - height, 0);
  }

  /// Returns the maximum legal horizontal scroll offset defined by this scroll
  /// pane.
  ///
  /// If the `verticalScrollBarWidth` argument is not specified, the value
  /// will be taken from [verticalScrollBar].
  double getMaxScrollLeft({double verticalScrollBarWidth}) {
    if (view == null) return 0;

    double viewWidth = view.size.width;
    double rowHeaderWidth = 0;
    double width = size.width;

    if (parentDataFor(verticalScrollBar).visible) {
      verticalScrollBarWidth ??= verticalScrollBar.size.width;
    }
    verticalScrollBarWidth ??= 0;

    if (rowHeader != null) rowHeaderWidth = rowHeader.size.width;
    return math.max(viewWidth + rowHeaderWidth + verticalScrollBarWidth - width, 0);
  }

  Offset _scrollOffset = Offset.zero;
  Offset get scrollOffset => _scrollOffset;
  set scrollOffset(Offset value) {
    assert(value != null);
    value = _boundsCheckScrollOffset(value);
    if (_scrollOffset == value) return;
    _scrollOffset = value;

    // We don't call `markNeedsLayout()` here because we need only reposition
    // the view, row header, and column header. Invalidating our layout would
    // yield the correct behavior, but it would do much more work than needed.
    _positionMovableChildren(scrollOffset: value);
    horizontalScrollBar.value = value.dx;
    verticalScrollBar.value = value.dy;
    markNeedsPaint();
  }

  ScrollBarPolicy _horizontalScrollBarPolicy;
  ScrollBarPolicy get horizontalScrollBarPolicy => _horizontalScrollBarPolicy;
  set horizontalScrollBarPolicy(ScrollBarPolicy value) {
    assert(value != null);
    if (_horizontalScrollBarPolicy == value) return;
    _horizontalScrollBarPolicy = value;
    markNeedsLayout();
  }

  ScrollBarPolicy _verticalScrollBarPolicy;
  ScrollBarPolicy get verticalScrollBarPolicy => _verticalScrollBarPolicy;
  set verticalScrollBarPolicy(ScrollBarPolicy value) {
    assert(value != null);
    if (_verticalScrollBarPolicy == value) return;
    _verticalScrollBarPolicy = value;
    markNeedsLayout();
  }

  RenderBox _view;
  RenderBox get view => _view;
  set view(RenderBox value) {
    if (_view != null) dropChild(_view);
    _view = value;
    if (_view != null) adoptChild(_view);
  }

  RenderBox _rowHeader;
  RenderBox get rowHeader => _rowHeader;
  set rowHeader(RenderBox value) {
    if (_rowHeader != null) dropChild(_rowHeader);
    _rowHeader = value;
    if (_rowHeader != null) adoptChild(_rowHeader);
  }

  RenderBox _columnHeader;
  RenderBox get columnHeader => _columnHeader;
  set columnHeader(RenderBox value) {
    if (_columnHeader != null) dropChild(_columnHeader);
    _columnHeader = value;
    if (_columnHeader != null) adoptChild(_columnHeader);
  }

  RenderBox _corner;
  RenderBox get corner => _corner;
  set corner(RenderBox value) {
    if (_corner != null) dropChild(_corner);
    _corner = value;
    if (_corner != null) adoptChild(_corner);
  }

  RenderBox _topLeftCorner;
  RenderBox get topLeftCorner => _topLeftCorner;
  set topLeftCorner(RenderBox value) {
    if (_topLeftCorner != null) dropChild(_topLeftCorner);
    _topLeftCorner = value;
    if (_topLeftCorner != null) adoptChild(_topLeftCorner);
  }

  RenderBox _bottomLeftCorner;
  RenderBox get bottomLeftCorner => _bottomLeftCorner;
  set bottomLeftCorner(RenderBox value) {
    if (_bottomLeftCorner != null) dropChild(_bottomLeftCorner);
    _bottomLeftCorner = value;
    if (_bottomLeftCorner != null) adoptChild(_bottomLeftCorner);
  }

  RenderBox _bottomRightCorner;
  RenderBox get bottomRightCorner => _bottomRightCorner;
  set bottomRightCorner(RenderBox value) {
    if (_bottomRightCorner != null) dropChild(_bottomRightCorner);
    _bottomRightCorner = value;
    if (_bottomRightCorner != null) adoptChild(_bottomRightCorner);
  }

  RenderBox _topRightCorner;
  RenderBox get topRightCorner => _topRightCorner;
  set topRightCorner(RenderBox value) {
    if (_topRightCorner != null) dropChild(_topRightCorner);
    _topRightCorner = value;
    if (_topRightCorner != null) adoptChild(_topRightCorner);
  }

  RenderScrollBar _horizontalScrollBar;
  RenderScrollBar get horizontalScrollBar => _horizontalScrollBar;
  set horizontalScrollBar(RenderScrollBar value) {
    if (_horizontalScrollBar != null) {
      value.scrollBarValueListeners.remove(this);
      dropChild(_horizontalScrollBar);
    }
    _horizontalScrollBar = value;
    if (_horizontalScrollBar != null) {
      adoptChild(_horizontalScrollBar);
      value.scrollBarValueListeners.add(this);
    }
  }

  RenderScrollBar _verticalScrollBar;
  RenderScrollBar get verticalScrollBar => _verticalScrollBar;
  set verticalScrollBar(RenderScrollBar value) {
    if (_verticalScrollBar != null) {
      value.scrollBarValueListeners.remove(this);
      dropChild(_verticalScrollBar);
    }
    _verticalScrollBar = value;
    if (_verticalScrollBar != null) {
      adoptChild(_verticalScrollBar);
      value.scrollBarValueListeners.add(this);
    }
  }

  void _onPointerScroll(PointerScrollEvent event) {
    scrollOffset = Offset(
      scrollOffset.dx + event.scrollDelta.dx,
      scrollOffset.dy + event.scrollDelta.dy,
    );
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerScrollEvent) return _onPointerScroll(event);
    super.handleEvent(event, entry);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (view != null) view.attach(owner);
    if (rowHeader != null) rowHeader.attach(owner);
    if (columnHeader != null) columnHeader.attach(owner);
    if (corner != null) corner.attach(owner);
    if (topLeftCorner != null) topLeftCorner.attach(owner);
    if (bottomLeftCorner != null) bottomLeftCorner.attach(owner);
    if (bottomRightCorner != null) bottomRightCorner.attach(owner);
    if (topRightCorner != null) topRightCorner.attach(owner);
    if (horizontalScrollBar != null) horizontalScrollBar.attach(owner);
    if (verticalScrollBar != null) verticalScrollBar.attach(owner);
  }

  @override
  void detach() {
    if (view != null) view.detach();
    if (rowHeader != null) rowHeader.detach();
    if (columnHeader != null) columnHeader.detach();
    if (corner != null) corner.detach();
    if (topLeftCorner != null) topLeftCorner.detach();
    if (bottomLeftCorner != null) bottomLeftCorner.detach();
    if (bottomRightCorner != null) bottomRightCorner.detach();
    if (topRightCorner != null) topRightCorner.detach();
    if (horizontalScrollBar != null) horizontalScrollBar.detach();
    if (verticalScrollBar != null) verticalScrollBar.detach();
    super.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (view != null) visitor(view);
    if (rowHeader != null) visitor(rowHeader);
    if (columnHeader != null) visitor(columnHeader);
    if (corner != null) visitor(corner);
    if (topLeftCorner != null) visitor(topLeftCorner);
    if (bottomLeftCorner != null) visitor(bottomLeftCorner);
    if (bottomRightCorner != null) visitor(bottomRightCorner);
    if (topRightCorner != null) visitor(topRightCorner);
    if (horizontalScrollBar != null) visitor(horizontalScrollBar);
    if (verticalScrollBar != null) visitor(verticalScrollBar);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    final List<RenderBox> children = <RenderBox>[
      verticalScrollBar,
      horizontalScrollBar,
      topRightCorner,
      bottomRightCorner,
      bottomLeftCorner,
      topLeftCorner,
      corner,
      columnHeader,
      rowHeader,
      view,
    ];

    for (RenderBox child in children) {
      if (child != null) {
        final _ScrollPaneParentData parentData = child.parentData;
        if (parentData.visible) {
          final bool isHit = result.addWithPaintOffset(
            offset: parentData.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset transformed) {
              assert(transformed == position - parentData.offset);
              return child.hitTest(result, position: transformed);
            },
          );

          // We know that RenderScrollPane doesn't overlap its children, so if
          // one child had a hit, it precludes other children from having had a
          // hit. Thus we can stop looking for hits after one child reports a hit.
          if (isHit) {
            return true;
          }
        }
      }
    }

    return false;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ScrollPaneParentData) child.parentData = _ScrollPaneParentData();
  }

  _ScrollPaneParentData parentDataFor(RenderBox child) => child.parentData;

  @override
  void performLayout() {
    if (!constraints.hasBoundedHeight || !constraints.hasBoundedWidth) {
      throw UnimplementedError();
    }
    size = constraints.biggest;

    bool expandWidth = false;
    bool expandHeight = false;

    ScrollBarPolicy horizontalPolicy = horizontalScrollBarPolicy;
    ScrollBarPolicy verticalPolicy = verticalScrollBarPolicy;

    // The `expand` policy means that we try to use `auto`, and only
    // if it ends up not being wide or tall enough do we use `stretch`

    if (horizontalPolicy == ScrollBarPolicy.expand) {
      horizontalPolicy = ScrollBarPolicy.auto;
      expandWidth = true;
    }

    if (verticalPolicy == ScrollBarPolicy.expand) {
      verticalPolicy = ScrollBarPolicy.auto;
      expandHeight = true;
    }

    layoutHelper(horizontalPolicy, verticalPolicy);

    if (view != null && (expandWidth || expandHeight)) {
      // We assumed `auto`. Now we check our assumption to see if we
      // need to adjust it to use `stretch`
      bool adjustWidth = false, adjustHeight = false;

      if (expandWidth) {
        double rowHeaderWidth = rowHeader != null ? rowHeader.size.width : 0;

        double verticalScrollBarWidth = parentDataFor(verticalScrollBar).visible ? verticalScrollBar.size.width : 0;
        double minViewWidth = size.width - rowHeaderWidth - verticalScrollBarWidth;

        if (view.size.width < minViewWidth) {
          horizontalPolicy = ScrollBarPolicy.stretch;
          adjustWidth = true;
        }
      }

      if (expandHeight) {
        double columnHeaderHeight = columnHeader != null ? columnHeader.size.height : 0;

        double horizontalScrollBarHeight =
        parentDataFor(horizontalScrollBar).visible ? horizontalScrollBar.size.height : 0;
        double minViewHeight = size.height - columnHeaderHeight - horizontalScrollBarHeight;

        if (view.size.height < minViewHeight) {
          verticalPolicy = ScrollBarPolicy.stretch;
          adjustHeight = true;
        }
      }

      if (adjustWidth || adjustHeight) {
        layoutHelper(horizontalPolicy, verticalPolicy);
      }
    }

    _cachedHorizontalScrollBarHeight = horizontalScrollBar.size.height;
    _cachedVerticalScrollBarWidth = verticalScrollBar.size.width;
  }

  double _cachedHorizontalScrollBarHeight = 0;
  double _cachedVerticalScrollBarWidth = 0;

  void layoutHelper(ScrollBarPolicy horizontalPolicy, ScrollBarPolicy verticalPolicy) {
    double width = size.width;
    double height = size.height;

    bool constrainWidth = (horizontalPolicy == ScrollBarPolicy.stretch);
    bool constrainHeight = (verticalPolicy == ScrollBarPolicy.stretch);

    double rowHeaderWidth = 0;
    if (rowHeader != null) {
      rowHeaderWidth = rowHeader.getMinIntrinsicWidth(double.infinity);
    }

    double columnHeaderHeight = 0;
    if (columnHeader != null) {
      columnHeaderHeight = columnHeader.getMinIntrinsicHeight(double.infinity);
    }

    double previousViewWidth;
    double viewWidth = 0;
    double previousViewHeight;
    double viewHeight = 0;
    double previousHorizontalScrollBarHeight;
    double horizontalScrollBarHeight = _cachedHorizontalScrollBarHeight;
    double previousVerticalScrollBarWidth;
    double verticalScrollBarWidth = _cachedVerticalScrollBarWidth;
    int i = 0;

    do {
      previousViewWidth = viewWidth;
      previousViewHeight = viewHeight;
      previousHorizontalScrollBarHeight = horizontalScrollBarHeight;
      previousVerticalScrollBarWidth = verticalScrollBarWidth;

      if (view != null) {
        if (constrainWidth && constrainHeight) {
          viewWidth = math.max(width - rowHeaderWidth - verticalScrollBarWidth, 0);
          viewHeight = math.max(height - columnHeaderHeight - horizontalScrollBarHeight, 0);
          view.layout(BoxConstraints.tightFor(width: viewWidth, height: viewHeight), parentUsesSize: true);
        } else if (constrainWidth) {
          viewWidth = math.max(width - rowHeaderWidth - verticalScrollBarWidth, 0);
          view.layout(BoxConstraints.tightFor(width: viewWidth), parentUsesSize: true);
          viewHeight = view.size.height;
        } else if (constrainHeight) {
          viewHeight = math.max(height - columnHeaderHeight - horizontalScrollBarHeight, 0);
          view.layout(BoxConstraints.tightFor(height: viewHeight), parentUsesSize: true);
          viewWidth = view.size.width;
        } else {
          view.layout(const BoxConstraints(), parentUsesSize: true);
          viewWidth = view.size.width;
          viewHeight = view.size.height;
        }
      }

      if (horizontalPolicy == ScrollBarPolicy.always ||
          (horizontalPolicy == ScrollBarPolicy.auto && viewWidth > width - rowHeaderWidth - verticalScrollBarWidth)) {
        horizontalScrollBarHeight = horizontalScrollBar.getMinIntrinsicHeight(double.infinity);
      } else {
        horizontalScrollBarHeight = 0;
      }

      if (verticalPolicy == ScrollBarPolicy.always ||
          (verticalPolicy == ScrollBarPolicy.auto &&
              viewHeight > height - columnHeaderHeight - horizontalScrollBarHeight)) {
        verticalScrollBarWidth = verticalScrollBar.getMinIntrinsicWidth(double.infinity);
      } else {
        verticalScrollBarWidth = 0;
      }

      if (++i > 4) {
        // Infinite loop protection
        assert(() {
          print("Breaking out of potential infinite loop");
          FlutterError.reportError(FlutterErrorDetails());
        }());
        break;
      }
    } while (viewWidth != previousViewWidth ||
        viewHeight != previousViewHeight ||
        horizontalScrollBarHeight != previousHorizontalScrollBarHeight ||
        verticalScrollBarWidth != previousVerticalScrollBarWidth);

    if (columnHeader != null) {
      columnHeader.layout(BoxConstraints.tightFor(width: viewWidth, height: columnHeaderHeight), parentUsesSize: true);
    }

    if (rowHeader != null) {
      rowHeader.layout(BoxConstraints.tightFor(width: rowHeaderWidth, height: viewHeight), parentUsesSize: true);
    }

    _ScrollPaneParentData horizontalScrollBarParentData = parentDataFor(horizontalScrollBar);
    if (horizontalScrollBarHeight > 0) {
      horizontalScrollBarParentData.visible = true;
      horizontalScrollBarParentData.offset = Offset(rowHeaderWidth, height - horizontalScrollBarHeight);
    } else {
      horizontalScrollBarParentData.visible = false;
    }

    _ScrollPaneParentData verticalScrollBarParentData = parentDataFor(verticalScrollBar);
    if (verticalScrollBarWidth > 0) {
      verticalScrollBarParentData.visible = true;
      verticalScrollBarParentData.offset = Offset(width - verticalScrollBarWidth, columnHeaderHeight);
    } else {
      verticalScrollBarParentData.visible = false;
    }

    // Handle corner components

    if (columnHeaderHeight > 0 && rowHeaderWidth > 0) {
      if (corner != null) {
        _ScrollPaneParentData cornerParentData = parentDataFor(corner);
        cornerParentData.offset = Offset.zero;
        cornerParentData.visible = true;
        corner.layout(BoxConstraints.tightFor(width: rowHeaderWidth, height: columnHeaderHeight));
        parentDataFor(topLeftCorner).visible = false;
      } else {
        _ScrollPaneParentData parentData = parentDataFor(topLeftCorner);
        parentData.offset = Offset.zero;
        parentData.visible = true;
        topLeftCorner.layout(BoxConstraints.tightFor(width: rowHeaderWidth, height: columnHeaderHeight));
      }
    } else {
      if (corner != null) {
        parentDataFor(corner).visible = false;
      }

      parentDataFor(topLeftCorner).visible = false;
    }

    if (rowHeaderWidth > 0 && horizontalScrollBarHeight > 0) {
      _ScrollPaneParentData parentData = parentDataFor(bottomLeftCorner);
      parentData.offset = Offset(0, height - horizontalScrollBarHeight);
      parentData.visible = true;
      bottomLeftCorner.layout(BoxConstraints.tightFor(width: rowHeaderWidth, height: horizontalScrollBarHeight));
    } else {
      parentDataFor(bottomLeftCorner).visible = false;
    }

    if (verticalScrollBarWidth > 0 && horizontalScrollBarHeight > 0) {
      _ScrollPaneParentData parentData = parentDataFor(bottomRightCorner);
      parentData.offset = Offset(width - verticalScrollBarWidth, height - horizontalScrollBarHeight);
      parentData.visible = true;
      bottomRightCorner
          .layout(BoxConstraints.tightFor(width: verticalScrollBarWidth, height: horizontalScrollBarHeight));
    } else {
      parentDataFor(bottomRightCorner).visible = false;
    }

    if (columnHeaderHeight > 0 && verticalScrollBarWidth > 0) {
      _ScrollPaneParentData parentData = parentDataFor(topRightCorner);
      parentData.offset = Offset(width - verticalScrollBarWidth, 0);
      parentData.visible = true;
      topRightCorner.layout(BoxConstraints.tightFor(width: verticalScrollBarWidth, height: columnHeaderHeight));
    } else {
      parentDataFor(topRightCorner).visible = false;
    }

    // Perform bounds checking on the scrollTop and scrollLeft values,
    // and adjust them as necessary. Make sure to do this after we've laid
    // everything out, since our maxScrollXYZ methods rely on valid
    // sizes from our components.

    _scrollOffset = _boundsCheckScrollOffset(
      scrollOffset,
      horizontalScrollBarHeight: horizontalScrollBarHeight,
      verticalScrollBarWidth: verticalScrollBarWidth,
    );

    _positionMovableChildren(rowHeaderWidth: rowHeaderWidth, columnHeaderHeight: columnHeaderHeight);
    horizontalScrollBar.value = scrollOffset.dx;
    verticalScrollBar.value = scrollOffset.dy;

    // Adjust the structure of our scroll bars. Make sure to do this after
    // we adjust the scrollTop and scrollLeft values; otherwise we might
    // try to set structure values that are out of bounds.
    double viewportWidth = math.max(width - rowHeaderWidth - verticalScrollBarWidth, 0);
    horizontalScrollBar.blockIncrement = math.max(1, viewportWidth - _horizontalReveal);
    if (viewWidth > 0) {
      horizontalScrollBar.updateValuesPriorToLayout(
        token: this,
        start: 0,
        end: viewWidth,
        extent: math.min(viewWidth, viewportWidth),
      );
    }

    double viewportHeight = math.max(height - columnHeaderHeight - horizontalScrollBarHeight, 0);
    verticalScrollBar.blockIncrement = math.max(1, viewportHeight - _verticalReveal);
    if (viewHeight > 0) {
      verticalScrollBar.updateValuesPriorToLayout(
        token: this,
        start: 0,
        end: viewHeight,
        extent: math.min(viewHeight, viewportHeight),
      );
    }

    if (horizontalScrollBarHeight > 0) {
      double horizontalScrollBarWidth = math.max(width - rowHeaderWidth - verticalScrollBarWidth, 0);
      horizontalScrollBar.layout(
        BoxConstraints.tightFor(width: horizontalScrollBarWidth, height: horizontalScrollBarHeight),
        parentUsesSize: true,
      );
    } else {
      horizontalScrollBar.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
    }

    if (verticalScrollBarWidth > 0) {
      double verticalScrollBarHeight = math.max(height - columnHeaderHeight - horizontalScrollBarHeight, 0);
      verticalScrollBar.layout(
        BoxConstraints.tightFor(width: verticalScrollBarWidth, height: verticalScrollBarHeight),
        parentUsesSize: true,
      );
    } else {
      verticalScrollBar.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final _ScrollPaneParentData viewParentData = parentDataFor(view);
    context.pushClipRect(
      needsCompositing,
      offset,
      viewParentData.offset & view.size,
          (PaintingContext context, Offset offset) {
        context.paintChild(view, offset + viewParentData.offset);
      },
    );

    if (rowHeader != null) {
      final _ScrollPaneParentData rowHeaderParentData = parentDataFor(rowHeader);
      if (rowHeaderParentData.visible) {
        context.pushClipRect(
          needsCompositing,
          offset,
          rowHeaderParentData.offset & rowHeader.size,
              (PaintingContext context, Offset offset) {
            context.paintChild(rowHeader, offset + rowHeaderParentData.offset);
          },
        );
      }
    }

    if (columnHeader != null) {
      final _ScrollPaneParentData columnHeaderParentData = parentDataFor(columnHeader);
      if (columnHeaderParentData.visible) {
        context.pushClipRect(
          needsCompositing,
          offset,
          columnHeaderParentData.offset & columnHeader.size,
              (PaintingContext context, Offset offset) {
            context.paintChild(columnHeader, offset + columnHeaderParentData.offset);
          },
        );
      }
    }

    _ScrollPaneParentData horizontalScrollBarParentData = parentDataFor(horizontalScrollBar);
    if (horizontalScrollBarParentData.visible) {
      context.pushClipRect(
        needsCompositing,
        offset,
        horizontalScrollBarParentData.offset & horizontalScrollBar.size,
            (PaintingContext context, Offset offset) {
          context.paintChild(horizontalScrollBar, offset + horizontalScrollBarParentData.offset);
        },
      );
    }

    _ScrollPaneParentData verticalScrollBarParentData = parentDataFor(verticalScrollBar);
    if (verticalScrollBarParentData.visible) {
      context.pushClipRect(
        needsCompositing,
        offset,
        verticalScrollBarParentData.offset & verticalScrollBar.size,
            (PaintingContext context, Offset offset) {
          context.paintChild(verticalScrollBar, offset + verticalScrollBarParentData.offset);
        },
      );
    }

    RenderBox topLeftCorner = corner;
    if (topLeftCorner == null) {
      topLeftCorner = this.topLeftCorner;
    }
    _ScrollPaneParentData topLeftCornerParentData = parentDataFor(topLeftCorner);
    if (topLeftCornerParentData.visible) {
      context.paintChild(topLeftCorner, offset + topLeftCornerParentData.offset);
    }

    _ScrollPaneParentData bottomLeftCornerParentData = parentDataFor(bottomLeftCorner);
    if (bottomLeftCornerParentData.visible) {
      context.paintChild(bottomLeftCorner, offset + bottomLeftCornerParentData.offset);
    }

    _ScrollPaneParentData bottomRightCornerParentData = parentDataFor(bottomRightCorner);
    if (bottomRightCornerParentData.visible) {
      context.paintChild(bottomRightCorner, offset + bottomRightCornerParentData.offset);
    }

    _ScrollPaneParentData topRightCornerParentData = parentDataFor(topRightCorner);
    if (topRightCornerParentData.visible) {
      context.paintChild(topRightCorner, offset + topRightCornerParentData.offset);
    }
  }

  // ScrollBarValueListener methods

  @override
  void valueChanged(RenderScrollBar scrollBar, double previousValue) {
    double value = scrollBar.value;
    if (scrollBar == horizontalScrollBar) {
      scrollOffset = Offset(value, scrollOffset.dy);
    } else {
      scrollOffset = Offset(scrollOffset.dx, value);
    }
  }
}

class _ScrollPaneParentData extends BoxParentData {
  bool _visible = true;
  bool get visible => _visible;
  set visible(bool value) {
    assert(value != null);
    _visible = value;
  }
}
