import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;

class ExpenseReportListTile extends StatelessWidget {
  /// Creates a list tile.
  ///
  /// If [isThreeLine] is true, then [subtitle] must not be null.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const ExpenseReportListTile({
    Key key,
    @required this.title,
    @required this.amount,
    this.enabled = true,
    this.onTap,
    this.mouseCursor,
    this.selected = false,
    this.focusColor,
    this.hoverColor,
    this.autofocus = false,
  })  : assert(enabled != null),
        assert(selected != null),
        assert(autofocus != null),
        super(key: key);

  final String title;
  final double amount;

  /// Whether this list tile is interactive.
  ///
  /// If false, this list tile is styled with the disabled color from the
  /// current [Theme] and the [onTap] and [onLongPress] callbacks are
  /// inoperative.
  final bool enabled;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback onTap;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.selected].
  ///  * [MaterialState.disabled].
  ///
  /// If this property is null, [MaterialStateMouseCursor.clickable] will be used.
  final MouseCursor mouseCursor;

  /// If this tile is also [enabled] then icons and text are rendered with the same color.
  ///
  /// By default the selected color is the theme's primary color. The selected color
  /// can be overridden with a [ListTileTheme].
  final bool selected;

  /// The color for the tile's [Material] when it has the input focus.
  final Color focusColor;

  /// The color for the tile's [Material] when a pointer is hovering over it.
  final Color hoverColor;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  Color _textColor(ThemeData theme, ListTileTheme tileTheme, Color defaultColor) {
    if (!enabled)
      return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.textColor != null)
      return tileTheme.textColor;

    if (selected) {
      return Colors.white;
    }
    return defaultColor;
  }

  TextStyle _textStyle(ThemeData theme, ListTileTheme tileTheme) {
    TextStyle style;
    if (tileTheme != null) {
      switch (tileTheme.style) {
        case ListTileStyle.drawer:
          style = theme.textTheme.bodyText1;
          break;
        case ListTileStyle.list:
          style = theme.textTheme.subtitle1;
          break;
      }
    } else {
      style = theme.textTheme.subtitle1;
    }
    final Color color = _textColor(theme, tileTheme, style.color);
    return style.copyWith(fontFamily: 'Verdana', fontSize: 11.0, color: color);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    final MouseCursor effectiveMouseCursor = MaterialStateProperty.resolveAs<MouseCursor>(
      mouseCursor ?? MaterialStateMouseCursor.clickable,
      <MaterialState>{
        if (!enabled) MaterialState.disabled,
        if (selected) MaterialState.selected,
      },
    );

    final intl.NumberFormat _currencyFormat = intl.NumberFormat('\$#,##0.00', 'en_US');

    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);
    TextStyle textStyle = _textStyle(theme, tileTheme);

    return InkWell(
      customBorder: ListTileTheme.of(context).shape,
      onTap: enabled ? onTap : null,
      mouseCursor: effectiveMouseCursor,
      canRequestFocus: enabled,
      focusColor: focusColor,
      hoverColor: hoverColor,
      autofocus: autofocus,
      child: Semantics(
        selected: selected,
        enabled: enabled,
        child: SafeArea(
          top: false,
          bottom: false,
          child: DefaultTextStyle(
            style: textStyle,
            child: _ListTile(
              title: Text(title),
              trailing: Text('(${_currencyFormat.format(amount)})'),
              textDirection: Directionality.of(context),
              titleBaselineType: TextBaseline.alphabetic,
              selected: selected,
            ),
          ),
        ),
      ),
    );
  }
}

// Identifies the children of a _ListTileElement.
enum _ListTileSlot {
  title,
  trailing,
}

class _ListTile extends RenderObjectWidget {
  const _ListTile({
    Key key,
    this.title,
    this.trailing,
    @required this.textDirection,
    @required this.titleBaselineType,
    this.selected = false,
  })  : assert(textDirection != null),
        assert(titleBaselineType != null),
        assert(selected != null),
        super(key: key);

  final Widget title;
  final Widget trailing;
  final TextDirection textDirection;
  final TextBaseline titleBaselineType;
  final bool selected;

  @override
  _ListTileElement createElement() => _ListTileElement(this);

  @override
  _RenderListTile createRenderObject(BuildContext context) {
    return _RenderListTile(
      textDirection: textDirection,
      titleBaselineType: titleBaselineType,
      selected: selected,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderListTile renderObject) {
    renderObject
      ..textDirection = textDirection
      ..titleBaselineType = titleBaselineType
      ..selected = selected;
  }
}

class _ListTileElement extends RenderObjectElement {
  _ListTileElement(_ListTile widget) : super(widget);

  final Map<_ListTileSlot, Element> slotToChild = <_ListTileSlot, Element>{};
  final Map<Element, _ListTileSlot> childToSlot = <Element, _ListTileSlot>{};

  @override
  _ListTile get widget => super.widget as _ListTile;

  @override
  _RenderListTile get renderObject => super.renderObject as _RenderListTile;

  @override
  void visitChildren(ElementVisitor visitor) {
    slotToChild.values.forEach(visitor);
  }

  @override
  void forgetChild(Element child) {
    assert(slotToChild.values.contains(child));
    assert(childToSlot.keys.contains(child));
    final _ListTileSlot slot = childToSlot[child];
    childToSlot.remove(child);
    slotToChild.remove(slot);
    super.forgetChild(child);
  }

  void _mountChild(Widget widget, _ListTileSlot slot) {
    final Element oldChild = slotToChild[slot];
    final Element newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      slotToChild.remove(slot);
      childToSlot.remove(oldChild);
    }
    if (newChild != null) {
      slotToChild[slot] = newChild;
      childToSlot[newChild] = slot;
    }
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _mountChild(widget.title, _ListTileSlot.title);
    _mountChild(widget.trailing, _ListTileSlot.trailing);
  }

  void _updateChild(Widget widget, _ListTileSlot slot) {
    final Element oldChild = slotToChild[slot];
    final Element newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      childToSlot.remove(oldChild);
      slotToChild.remove(slot);
    }
    if (newChild != null) {
      slotToChild[slot] = newChild;
      childToSlot[newChild] = slot;
    }
  }

  @override
  void update(_ListTile newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChild(widget.title, _ListTileSlot.title);
    _updateChild(widget.trailing, _ListTileSlot.trailing);
  }

  void _updateRenderObject(RenderBox child, _ListTileSlot slot) {
    switch (slot) {
      case _ListTileSlot.title:
        renderObject.title = child;
        break;
      case _ListTileSlot.trailing:
        renderObject.trailing = child;
        break;
    }
  }

  @override
  void insertChildRenderObject(RenderObject child, dynamic slotValue) {
    assert(child is RenderBox);
    assert(slotValue is _ListTileSlot);
    final _ListTileSlot slot = slotValue as _ListTileSlot;
    _updateRenderObject(child as RenderBox, slot);
    assert(renderObject.childToSlot.keys.contains(child));
    assert(renderObject.slotToChild.keys.contains(slot));
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    assert(child is RenderBox);
    assert(renderObject.childToSlot.keys.contains(child));
    _updateRenderObject(null, renderObject.childToSlot[child]);
    assert(!renderObject.childToSlot.keys.contains(child));
    assert(!renderObject.slotToChild.keys.contains(slot));
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slotValue) {
    assert(false, 'not reachable');
  }
}

class _RenderListTile extends RenderBox {
  _RenderListTile({
    @required TextDirection textDirection,
    @required TextBaseline titleBaselineType,
    @required bool selected,
  })  : assert(textDirection != null),
        assert(titleBaselineType != null),
        assert(selected != null),
        _textDirection = textDirection,
        _titleBaselineType = titleBaselineType,
        _selected = selected;

  // The horizontal gap between the titles and the trailing widget.
  double get _horizontalTitleGap => 2;

  // The minimum padding on the top and bottom of the title widget.
  static const double _minVerticalPadding = 3;

  static const double _horizontalPadding = 2;

  final Map<_ListTileSlot, RenderBox> slotToChild = <_ListTileSlot, RenderBox>{};
  final Map<RenderBox, _ListTileSlot> childToSlot = <RenderBox, _ListTileSlot>{};

  RenderBox _updateChild(RenderBox oldChild, RenderBox newChild, _ListTileSlot slot) {
    assert(oldChild != newChild);
    if (oldChild != null) {
      dropChild(oldChild);
      childToSlot.remove(oldChild);
      slotToChild.remove(slot);
    }
    if (newChild != null) {
      childToSlot[newChild] = slot;
      slotToChild[slot] = newChild;
      adoptChild(newChild);
    }
    return newChild;
  }

  RenderBox _title;
  RenderBox get title => _title;
  set title(RenderBox value) {
    _title = _updateChild(_title, value, _ListTileSlot.title);
  }

  RenderBox _trailing;
  RenderBox get trailing => _trailing;
  set trailing(RenderBox value) {
    _trailing = _updateChild(_trailing, value, _ListTileSlot.trailing);
  }

  // The returned list is ordered for hit testing.
  Iterable<RenderBox> get _children sync* {
    if (title != null) yield title;
    if (trailing != null) yield trailing;
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    assert(value != null);
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  TextBaseline get titleBaselineType => _titleBaselineType;
  TextBaseline _titleBaselineType;
  set titleBaselineType(TextBaseline value) {
    assert(value != null);
    if (_titleBaselineType == value) return;
    _titleBaselineType = value;
    markNeedsLayout();
  }

  bool get selected => _selected;
  bool _selected;
  set selected(bool value) {
    assert(value != null);
    if (_selected == value) return;
    _selected = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final RenderBox child in _children) child.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    for (final RenderBox child in _children) child.detach();
  }

  @override
  void redepthChildren() {
    _children.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _children.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> value = <DiagnosticsNode>[];
    void add(RenderBox child, String name) {
      if (child != null) value.add(child.toDiagnosticsNode(name: name));
    }

    add(title, 'title');
    add(trailing, 'trailing');
    return value;
  }

  @override
  bool get sizedByParent => false;

  static double _minWidth(RenderBox box, double height) {
    return box == null ? 0.0 : box.getMinIntrinsicWidth(height);
  }

  static double _maxWidth(RenderBox box, double height) {
    return box == null ? 0.0 : box.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _minWidth(title, height) + _maxWidth(trailing, height) + 2 * _horizontalPadding;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _maxWidth(title, height) + _maxWidth(trailing, height) + 2 * _horizontalPadding;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return title.getMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(title != null);
    final BoxParentData parentData = title.parentData as BoxParentData;
    return parentData.offset.dy + title.getDistanceToActualBaseline(baseline);
  }

  static Size _layoutBox(RenderBox box, BoxConstraints constraints) {
    if (box == null) return Size.zero;
    box.layout(constraints, parentUsesSize: true);
    return box.size;
  }

  static void _positionBox(RenderBox box, Offset offset) {
    final BoxParentData parentData = box.parentData as BoxParentData;
    parentData.offset = offset;
  }

  // All of the dimensions below were taken from the Material Design spec:
  // https://material.io/design/components/lists.html#specs
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final bool hasTrailing = trailing != null;

    final BoxConstraints looseConstraints = constraints.loosen();

    final double tileWidth = looseConstraints.maxWidth;
    final Size trailingSize = _layoutBox(trailing, looseConstraints);
    assert(tileWidth != trailingSize.width, 'Trailing widget consumes entire tile width. Please use a sized widget.');

    title.getMinIntrinsicWidth(looseConstraints.maxHeight);

    final double adjustedTrailingWidth = trailingSize.width > 0 ? trailingSize.width + _horizontalTitleGap : 0.0;
    final BoxConstraints titleConstraints = looseConstraints.tighten(
      width: tileWidth - adjustedTrailingWidth,
    );
    final Size titleSize = _layoutBox(title, titleConstraints);

    double tileHeight = titleSize.height + 1.0 * _minVerticalPadding;
    double titleY = (tileHeight - titleSize.height) / 2.0;
    double trailingY = (tileHeight - trailingSize.height) / 2.0;

    switch (textDirection) {
      case TextDirection.rtl:
        {
          _positionBox(title, Offset(adjustedTrailingWidth, titleY));
          if (hasTrailing) _positionBox(trailing, Offset(0.0, trailingY));
          break;
        }
      case TextDirection.ltr:
        {
          _positionBox(title, Offset(_horizontalPadding, titleY));
          if (hasTrailing) _positionBox(trailing, Offset(tileWidth - trailingSize.width - _horizontalPadding, trailingY));
          break;
        }
    }

    size = constraints.constrain(Size(tileWidth, tileHeight));
    assert(size.width == constraints.constrainWidth(tileWidth));
    assert(size.height == constraints.constrainHeight(tileHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void doPaint(RenderBox child) {
      if (child != null) {
        final BoxParentData parentData = child.parentData as BoxParentData;
        context.paintChild(child, parentData.offset + offset);
      }
    }

    if (selected) {
      context.canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()
        ..color = Color(0xff14538b));
    }
    doPaint(title);
    doPaint(trailing);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {@required Offset position}) {
    assert(position != null);
    for (final RenderBox child in _children) {
      final BoxParentData parentData = child.parentData as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - parentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
    }
    return false;
  }
}
