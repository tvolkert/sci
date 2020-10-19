import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Class that allows callers to measure the size of arbitrary widgets when
/// layed out with specific constraints.
class WidgetSurveyor {
  WidgetSurveyor()
      : _pipelineOwner = _newPipelineOwner(),
        _buildOwner = _newBuildOwner();

  final PipelineOwner _pipelineOwner;
  final BuildOwner _buildOwner;

  _MeasurementView get _rootView => _pipelineOwner.rootNode;

  static PipelineOwner _newPipelineOwner() {
    PipelineOwner pipelineOwner = PipelineOwner(
      onNeedVisualUpdate: () {},
      onSemanticsOwnerCreated: () {},
      onSemanticsOwnerDisposed: () {},
    );
    pipelineOwner.rootNode = _MeasurementView();
    return pipelineOwner;
  }

  static BuildOwner _newBuildOwner() {
    return BuildOwner(
      onBuildScheduled: () {},
    );
  }

  /// Builds the specified widget, lays out the resulting render tree, and
  /// returns the size of the laid-out render tree.
  ///
  /// The `constraints` argument specify the constraints that will be passed
  /// to the render tree during layout. If unspecified, the widget will be laid
  /// out unconstrained.
  Size measure(
    Widget widget, {
    BoxConstraints constraints = const BoxConstraints(),
  }) {
    RenderObjectToWidgetAdapter<RenderBox>(
      container: _pipelineOwner.rootNode,
      debugShortDescription: '[root]',
      child: widget,
    ).attachToRenderTree(_buildOwner);
    _rootView.scheduleInitialLayout();
    _rootView.childConstraints = constraints;
    _pipelineOwner.flushLayout();
    return _rootView.size;
  }
}

class _MeasurementView extends RenderObject with RenderObjectWithChildMixin<RenderBox> {
  Size size;
  BoxConstraints childConstraints;

  @override
  void performLayout() {
    assert(child != null);
    assert(childConstraints != null);
    child.layout(childConstraints, parentUsesSize: true);
    size = child.size;
  }

  @override
  void debugAssertDoesMeetConstraints() {
    assert(false);
  }

  @override
  void performResize() {
    assert(false);
  }

  @override
  Rect get paintBounds => Rect.zero;

  @override
  Rect get semanticBounds => Rect.zero;
}
