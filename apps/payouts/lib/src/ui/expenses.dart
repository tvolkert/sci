import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;

import 'package:payouts/splitter.dart';
import 'package:payouts/src/pivot.dart' as pivot;

class ExpenseReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 7, 5),
            child: pivot.LinkButton(
              image: AssetImage('assets/money_add.png'),
              text: 'Add expense report',
              onPressed: () {},
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Split(
                axis: Axis.horizontal,
                initialFractions: [0.25, 0.75],
                children: [
                  ExpenseReportListView(),
                  DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(color: Color(0xFF999999))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(11, 11, 11, 9),
                          child: DefaultTextStyle(
                            style:
                            Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black),
                            child: Table(
                              columnWidths: {
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Program:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Orbital Sciences')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Charge number:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4), child: Text('123')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4), child: Text('Dates:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('2015-10-12 to 2015-10-25')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Purpose of travel:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('None of your business')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Destination (city):')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Vancouver')),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4, right: 6),
                                        child: Text('Party or parties visited:')),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 4), child: Text('Jimbo')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 9, left: 11),
                          child: Row(
                            children: [
                              pivot.LinkButton(
                                image: AssetImage('assets/money_add.png'),
                                text: 'Add expense line item',
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: const Color(0xff999999),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(1),
                            child: ExpensesTableView(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpensesTableView extends StatefulWidget {
  @override
  _ExpensesTableViewState createState() => _ExpensesTableViewState();
}

class _ExpensesTableViewState extends State<ExpensesTableView> {
  pivot.TableViewSelectionController _selectionController;
  pivot.TableViewSortController _sortController;
  pivot.TableViewEditorController _editorcontroller;

  final List<List<String>> data = [
    ['2015-10-12', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-13', 'Car Rental', r'$34.50', 'Test'],
    ['2015-10-13', 'Parking', r'$12.00', ''],
    ['2015-10-13', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-14', 'Car Rental', r'$23.43', 'foo'],
    ['2015-10-14', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-15', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-16', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-17', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-18', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-19', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-20', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-21', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-22', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-23', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-24', 'Lodging', r'$219.05', 'Hotel'],
    ['2015-10-25', 'Lodging', r'$219.05', 'Hotel'],
  ];

  static final intl.DateFormat dateFormat = intl.DateFormat('yyyy-MM-dd');

  pivot.TableHeaderRenderer _renderHeader(String name) {
    return ({
      BuildContext context,
      int columnIndex,
    }) {
      return Text(
        name,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
      );
    };
  }

  Widget _renderDate({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String date = data[rowIndex][0];
    final DateTime dateTime = DateTime.parse(date);
    final String formattedDate = dateFormat.format(dateTime);
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        formattedDate,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  Widget _renderType({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String type = data[rowIndex][1];
    if (isEditing) {
      return _renderTypeEditor(type);
    }
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        type,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  Widget _renderTypeEditor(String type) {
    return pivot.PushButton<String>(
      onPressed: () {},
      label: type,
      menuItems: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'type1',
          height: 22,
          child: Text('Another type'),
        ),
        PopupMenuItem<String>(
          value: 'type2',
          height: 22,
          child: Text('Yet another type'),
        ),
      ],
      onMenuItemSelected: (String value) {},
    );
  }

  Widget _renderAmount({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String amount = data[rowIndex][2];
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        amount,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  Widget _renderDescription({
    BuildContext context,
    int rowIndex,
    int columnIndex,
    bool rowSelected,
    bool rowHighlighted,
    bool isEditing,
  }) {
    final String description = data[rowIndex][3];
    TextStyle style = DefaultTextStyle.of(context).style;
    if (rowSelected) {
      style = style.copyWith(color: Colors.white);
    }
    return ExpenseCellWrapper(
      rowIndex: rowIndex,
      rowHighlighted: rowHighlighted,
      rowSelected: rowSelected,
      child: Text(
        description,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectionController = pivot.TableViewSelectionController(selectMode: pivot.SelectMode.multi);
    _sortController = pivot.TableViewSortController(sortMode: pivot.TableViewSortMode.singleColumn);
    _editorcontroller = pivot.TableViewEditorController();
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _sortController.dispose();
    _editorcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pivot.ScrollableTableView(
      rowHeight: 19,
      length: data.length,
      selectionController: _selectionController,
      sortController: _sortController,
      editorController: _editorcontroller,
      roundColumnWidthsToWholePixel: false,
      columns: <pivot.TableColumnController>[
        pivot.TableColumnController(
          key: 'date',
          width: pivot.ConstrainedTableColumnWidth(width: 120),
          cellRenderer: _renderDate,
          headerRenderer: _renderHeader('Date'),
        ),
        pivot.TableColumnController(
          key: 'type',
          width: pivot.FixedTableColumnWidth(120),
          cellRenderer: _renderType,
          headerRenderer: _renderHeader('Type'),
        ),
        pivot.TableColumnController(
          key: 'amount',
          width: pivot.FixedTableColumnWidth(100),
          cellRenderer: _renderAmount,
          headerRenderer: _renderHeader('Amount'),
        ),
        pivot.TableColumnController(
          key: 'description',
          width: pivot.FlexTableColumnWidth(),
          cellRenderer: _renderDescription,
          headerRenderer: _renderHeader('Description'),
        ),
      ],
    );
  }
}

class ExpenseCellWrapper extends StatelessWidget {
  const ExpenseCellWrapper({
    Key key,
    this.rowIndex = 0,
    this.rowHighlighted = false,
    this.rowSelected = false,
    this.child,
  })  : assert(rowIndex != null),
        super(key: key);

  final int rowIndex;
  final bool rowHighlighted;
  final bool rowSelected;
  final Widget child;

  static const List<Color> colors = <Color>[Colors.white, Color(0xfff7f5ee)];

  @override
  Widget build(BuildContext context) {
    Widget result = Padding(
      padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
      child: child,
    );

    if (!rowHighlighted && !rowSelected) {
      result = ColoredBox(
        color: colors[rowIndex % 2],
        child: result,
      );
    }

    return result;
  }
}

class ExpenseReportData {
  const ExpenseReportData({
    this.title,
    this.amount,
  });
  final String title;
  final double amount;
}

class ExpenseReportListView extends StatefulWidget {
  @override
  _ExpenseReportListViewState createState() => _ExpenseReportListViewState();
}

class _ExpenseReportListViewState extends State<ExpenseReportListView> {
  int selectedIndex = 1;

  static const List<ExpenseReportData> expenseReports = <ExpenseReportData>[
    ExpenseReportData(title: 'SCI - Overhead', amount: 0),
    ExpenseReportData(title: 'Orbital Sciences (123)', amount: 3136.63),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: use ink?
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF999999)),
      ),
      child: ListView.builder(
        itemExtent: 18,
        shrinkWrap: true,
        itemCount: expenseReports.length,
        itemBuilder: (BuildContext context, int index) {
          final ExpenseReportData data = expenseReports[index];
          return ExpenseReportListTile(
            title: data.title,
            amount: data.amount,
            hoverColor: Color(0xffdddcd5),
            selected: index == selectedIndex,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}

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
