import 'dart:math' as math;
import 'dart:ui' show window;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'text_input.dart';

void main() {
  runApp(
    Localizations(
      locale: Locale('en', 'US'),
      delegates: [
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: MediaQuery(
        data: MediaQueryData.fromWindow(window),
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return PageRouteBuilder<void>(
              settings: settings,
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return Material(
                  child: ColoredBox(
                    color: Color(0xffffffff),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: DefaultTextStyle(
                        style: TextStyle(fontFamily: 'Verdana', color: Color(0xff000000)),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Form(
                                children: [
                                  FormField(
                                    label: 'Field 1',
                                    child: TextInput(
                                      backgroundColor: Color(0xfff7f5ee),
                                    ),
                                  ),
                                  FormField(
                                    label: 'Foo',
                                    child: Padding(padding: EdgeInsets.only(top: 10), child: ColoredBox(color: Color(0xffccdddd), child: Text('Hello World'))),
                                  ),
                                  FormField(
                                    label: 'Field 2',
                                    child: TextInput(
                                      backgroundColor: Color(0xfff7f5ee),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

class FormField {
  const FormField({this.label, this.child});

  final String label;
  final Widget child;
}

class Form extends RenderObjectWidget {
  const Form({
    Key key,
    this.children,
    this.horizontalSpacing = 6,
    this.verticalSpacing = 6,
    this.flagImageOffset = 4,
    this.delimiter = ':',
    this.stretch = false,
    this.rightAlignLabels = false,
  }) : super(key: key);

  final List<FormField> children;
  final double horizontalSpacing;
  final double verticalSpacing;
  final double flagImageOffset;
  final String delimiter;
  final bool stretch;
  final bool rightAlignLabels;

  @override
  RenderObjectElement createElement() => _FormElement(this);

  @override
  _RenderForm createRenderObject(BuildContext context) {
    return _RenderForm(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      flagImageOffset: flagImageOffset,
      stretch: stretch,
      rightAlignLabels: rightAlignLabels,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderForm renderObject) {
    renderObject
      ..horizontalSpacing = horizontalSpacing
      ..verticalSpacing = verticalSpacing
      ..flagImageOffset = flagImageOffset
      ..stretch = stretch
      ..rightAlignLabels = rightAlignLabels;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('horizontalSpacing', horizontalSpacing));
    properties.add(DiagnosticsProperty<double>('verticalSpacing', verticalSpacing));
    properties.add(DiagnosticsProperty<double>('flagImageOffset', flagImageOffset));
    properties.add(DiagnosticsProperty<bool>('stretch', stretch));
  }
}

enum _SlotType {
  label,
  field,
}

@immutable
class _FormSlot {
  const _FormSlot.label(this.index, this.previous) : type = _SlotType.label;

  const _FormSlot.child(this.index, this.previous) : type = _SlotType.field;

  final int index;
  final Element previous;
  final _SlotType type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _FormSlot &&
        index == other.index &&
        previous == other.previous &&
        type == other.type;
  }

  @override
  int get hashCode => hashValues(index, previous, type);
}

class _FormFieldElement {
  Element label;
  Element child;
}

class _FormElement extends RenderObjectElement {
  _FormElement(Form widget) : super(widget);

  List<_FormFieldElement> _fields;

  @override
  Form get widget => super.widget as Form;

  @override
  _RenderForm get renderObject => super.renderObject as _RenderForm;

  @override
  void visitChildren(ElementVisitor visitor) {
    for (_FormFieldElement field in _fields) {
      visitor(field.label);
      visitor(field.child);
    }
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _FormFieldElement previous = _FormFieldElement();
    _fields = List<_FormFieldElement>.generate(widget.children.length, (int index) {
      final FormField field = widget.children[index];
      _FormFieldElement element = _FormFieldElement();
      final Widget labelWidget = Text('${field.label}${widget.delimiter}');
      element.label = updateChild(null, labelWidget, _FormSlot.label(index, previous.label));
      element.child = updateChild(null, field.child, _FormSlot.child(index, previous.child));
      previous = element;
      return element;
    }, growable: false);
  }

  @override
  void update(Form newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    print('TODO: update form');
  }

  @override
  void insertRenderObjectChild(RenderBox child, _FormSlot slot) {
    assert(slot != null);
    switch (slot.type) {
      case _SlotType.label:
        renderObject.insertLabel(child, after: slot.previous?.renderObject);
        break;
      case _SlotType.field:
        renderObject.insertChild(child, after: slot.previous?.renderObject);
        break;
    }
  }

  @override
  void moveRenderObjectChild(RenderObject _, _FormSlot __, _FormSlot ___) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, _FormSlot slot) {
    assert(child.parent == renderObject);
    switch (slot.type) {
      case _SlotType.label:
        renderObject.removeLabel(child);
        break;
      case _SlotType.field:
        renderObject.removeChild(child);
        break;
    }
  }

  @override
  void forgetChild(Element child) {
    print('TODO: forgetChild()');
    super.forgetChild(child);
  }
}

class FormParentData extends ContainerBoxParentData<RenderBox> {}

class _ChildList {
  RenderBox firstChild;
  RenderBox lastChild;
}

class _RenderForm extends RenderBox {
  _RenderForm({
    double horizontalSpacing,
    double verticalSpacing,
    double flagImageOffset,
    bool stretch,
    bool rightAlignLabels,
  }) {
    this.horizontalSpacing = horizontalSpacing;
    this.verticalSpacing = verticalSpacing;
    this.flagImageOffset = flagImageOffset;
    this.stretch = stretch;
    this.rightAlignLabels = rightAlignLabels;
  }

  static const double _flagImageSize = 16;

  double _horizontalSpacing;
  double get horizontalSpacing => _horizontalSpacing;
  set horizontalSpacing(double value) {
    assert(value != null);
    if (value == _horizontalSpacing) return;
    _horizontalSpacing = value;
    markNeedsLayout();
  }

  double _verticalSpacing;
  double get verticalSpacing => _verticalSpacing;
  set verticalSpacing(double value) {
    assert(value != null);
    if (value == _verticalSpacing) return;
    _verticalSpacing = value;
    markNeedsLayout();
  }

  double _flagImageOffset;
  double get flagImageOffset => _flagImageOffset;
  set flagImageOffset(double value) {
    assert(value != null);
    if (value == _flagImageOffset) return;
    _flagImageOffset = value;
    markNeedsLayout();
  }

  bool _stretch;
  bool get stretch => _stretch;
  set stretch(bool value) {
    assert(value != null);
    if (value == _stretch) return;
    _stretch = value;
    markNeedsLayout();
  }

  bool _rightAlignLabels;
  bool get rightAlignLabels => _rightAlignLabels;
  set rightAlignLabels(bool value) {
    assert(value != null);
    if (value == _rightAlignLabels) return;
    _rightAlignLabels = value;
    markNeedsLayout();
  }

  /// The number of children.
  int _childCount = 0;
  int get childCount => _childCount;

  final Map<_SlotType, _ChildList> _children = <_SlotType, _ChildList>{
    _SlotType.label: _ChildList(),
    _SlotType.field: _ChildList(),
  };

  bool _debugUltimatePreviousSiblingOf(RenderBox child, {RenderBox equals}) {
    ContainerParentDataMixin<RenderBox> childParentData = child.parentData;
    while (childParentData.previousSibling != null) {
      assert(childParentData.previousSibling != child);
      child = childParentData.previousSibling;
      childParentData = child.parentData;
    }
    return child == equals;
  }

  bool _debugUltimateNextSiblingOf(RenderBox child, {RenderBox equals}) {
    ContainerParentDataMixin<RenderBox> childParentData = child.parentData;
    while (childParentData.nextSibling != null) {
      assert(childParentData.nextSibling != child);
      child = childParentData.nextSibling;
      childParentData = child.parentData;
    }
    return child == equals;
  }

  void _insertIntoChildList(
    RenderBox child, {
    RenderBox after,
    @required _SlotType type,
  }) {
    assert(type != null);
    final _ChildList children = _children[type];
    final FormParentData childParentData = child.parentData;
    assert(childParentData.nextSibling == null);
    assert(childParentData.previousSibling == null);
    _childCount += 1;
    assert(_childCount > 0);
    if (after == null) {
      // insert at the start (_firstChild)
      childParentData.nextSibling = children.firstChild;
      if (children.firstChild != null) {
        final FormParentData firstChildParentData = children.firstChild.parentData;
        firstChildParentData.previousSibling = child;
      }
      children.firstChild = child;
      children.lastChild ??= child;
    } else {
      assert(children.firstChild != null);
      assert(children.lastChild != null);
      assert(_debugUltimatePreviousSiblingOf(after, equals: children.firstChild));
      assert(_debugUltimateNextSiblingOf(after, equals: children.lastChild));
      final FormParentData afterParentData = after.parentData;
      if (afterParentData.nextSibling == null) {
        // insert at the end (_lastChild); we'll end up with two or more children
        assert(after == children.lastChild);
        childParentData.previousSibling = after;
        afterParentData.nextSibling = child;
        children.lastChild = child;
      } else {
        // insert in the middle; we'll end up with three or more children
        // set up links from child to siblings
        childParentData.nextSibling = afterParentData.nextSibling;
        childParentData.previousSibling = after;
        // set up links from siblings to child
        final FormParentData childPreviousSiblingParentData =
            childParentData.previousSibling.parentData;
        final FormParentData childNextSiblingParentData = childParentData.nextSibling.parentData;
        childPreviousSiblingParentData.nextSibling = child;
        childNextSiblingParentData.previousSibling = child;
        assert(afterParentData.nextSibling == child);
      }
    }
  }

  void _insertChild(RenderBox child, {RenderBox after, @required _SlotType type}) {
    final _ChildList children = _children[type];
    assert(child != this, 'A RenderObject cannot be inserted into itself.');
    assert(after != this,
        'A RenderObject cannot simultaneously be both the parent and the sibling of another RenderObject.');
    assert(child != after, 'A RenderObject cannot be inserted after itself.');
    assert(child != children.firstChild);
    assert(child != children.lastChild);
    adoptChild(child);
    _insertIntoChildList(child, after: after, type: type);
  }

  void insertLabel(RenderBox label, {RenderBox after}) {
    _insertChild(label, after: after, type: _SlotType.label);
  }

  void insertChild(RenderBox child, {RenderBox after}) {
    _insertChild(child, after: after, type: _SlotType.field);
  }

  void removeLabel(RenderObject label) {
    // TODO
  }

  void removeChild(RenderObject child) {
    // TODO
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FormParentData) {
      child.parentData = FormParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    visitChildren((RenderObject child) {
      child.attach(owner);
    });
  }

  @override
  void detach() {
    super.detach();
    visitChildren((RenderObject child) {
      child.detach();
    });
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    for (_SlotType type in _children.keys) {
      visitChildrenOfType(type, visitor);
    }
  }

  void visitChildrenOfType(_SlotType type, RenderObjectVisitor visitor) {
    RenderBox child = _children[type].firstChild;
    while (child != null) {
      visitor(child);
      final FormParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
  }

  @override
  void redepthChildren() {
    visitChildren((RenderObject child) {
      redepthChild(child);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    RenderBox label = _children[_SlotType.label].lastChild;
    RenderBox field = _children[_SlotType.field].lastChild;
    while (field != null) {
      assert(label != null);
      for (RenderBox child in [field, label]) {
        final FormParentData childParentData = child.parentData;
        final bool isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child.hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          return true;
        }
      }
      final FormParentData labelParentData = label.parentData;
      final FormParentData fieldParentData = field.parentData;
      label = labelParentData.previousSibling;
      field = fieldParentData.previousSibling;
    }
    assert(label == null);
    return false;
  }

  @override
  bool hitTestSelf(Offset position) => super.hitTestSelf(position);

  @override
  double computeMinIntrinsicWidth(double height) {
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) => computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  void performLayout() {
    // Determine the maximum label width
    double maxLabelWidth = 0;
    visitChildrenOfType(_SlotType.label, (RenderObject child) {
      child.layout(const BoxConstraints(), parentUsesSize: true);
      maxLabelWidth = math.max(maxLabelWidth, (child as RenderBox).size.width);
    });

    BoxConstraints fieldConstraints = constraints.deflate(
      EdgeInsets.only(left: maxLabelWidth + horizontalSpacing + flagImageOffset + _flagImageSize),
    );
    if (stretch) {
      fieldConstraints = fieldConstraints.tighten(width: fieldConstraints.maxWidth);
    }

    double rowY = 0;
    double maxFieldWidth = 0;
    RenderBox label = _children[_SlotType.label].firstChild;
    RenderBox field = _children[_SlotType.field].firstChild;
    while (field != null) {
      assert(label != null);
      final FormParentData labelParentData = label.parentData;
      final FormParentData childParentData = field.parentData;

      final double labelAscent = label.getDistanceToBaseline(TextBaseline.alphabetic);
      final double labelDescent = label.size.height - labelAscent;
      field.layout(fieldConstraints, parentUsesSize: true);
      final double fieldAscent = field.getDistanceToBaseline(TextBaseline.alphabetic);
      final double fieldDescent = field.size.height - fieldAscent;

      final double baseline = math.max(labelAscent, fieldAscent);
      final double rowHeight =
          math.max(baseline + math.max(labelDescent, fieldDescent), _flagImageSize);

      // Align the label and field to baseline
      double labelX = rightAlignLabels ? maxLabelWidth - label.size.width : 0;
      double labelY = rowY + (baseline - labelAscent);
      labelParentData.offset = Offset(labelX, labelY);
      double fieldX = maxLabelWidth + horizontalSpacing;
      double fieldY = rowY + (baseline - fieldAscent);
      childParentData.offset = Offset(fieldX, fieldY);

      // Vertically center the flag on the label
      // TODO

      rowY += rowHeight + verticalSpacing;
      maxFieldWidth = math.max(maxFieldWidth, field.size.width);
      label = labelParentData.nextSibling;
      field = childParentData.nextSibling;
    }
    assert(label == null);

    size = constraints.constrainDimensions(
      maxLabelWidth + horizontalSpacing + maxFieldWidth,
      rowY - verticalSpacing,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    visitChildren((RenderObject child) {
      final FormParentData childParentData = child.parentData;
      context.paintChild(child, childParentData.offset + offset);
    });
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> result = <DiagnosticsNode>[];
    void add(RenderBox child, String name) {
      if (child != null) result.add(child.toDiagnosticsNode(name: name));
    }
    int i = 0;
    visitChildrenOfType(_SlotType.label, (RenderObject label) {
      add(label, 'label_${i++}');
    });
    i = 0;
    visitChildrenOfType(_SlotType.field, (RenderObject field) {
      add(field, 'field_${i++}');
    });
    return result;
  }
}
