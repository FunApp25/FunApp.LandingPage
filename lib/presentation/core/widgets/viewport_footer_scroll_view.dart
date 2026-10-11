import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Scrollable page body that keeps its footer at the viewport bottom when the
/// main content is short and lets longer content scroll naturally.
final class ViewportFooterScrollView extends StatelessWidget {
  /// Creates a viewport-aware body with one content region and one footer.
  const ViewportFooterScrollView({
    required this.content,
    required this.footer,
    this.controller,
    this.scrollKey,
    super.key,
  });

  /// Primary page content rendered before the footer.
  final Widget content;

  /// Shared footer rendered at the bottom of the available viewport.
  final Widget footer;

  /// Optional controller retained by pages that restore or change scroll.
  final ScrollController? controller;

  /// Stable key assigned to the underlying scroll view.
  final Key? scrollKey;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      key: scrollKey,
      controller: controller,
      child: _ViewportFooterLayout(
        minimumHeight: constraints.maxHeight,
        children: [content, footer],
      ),
    ),
  );
}

final class _ViewportFooterLayout extends MultiChildRenderObjectWidget {
  const _ViewportFooterLayout({
    required this.minimumHeight,
    required super.children,
  });

  final double minimumHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderViewportFooterLayout(minimumHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderViewportFooterLayout renderObject,
  ) {
    renderObject.minimumHeight = minimumHeight;
  }
}

final class _ViewportFooterParentData
    extends ContainerBoxParentData<RenderBox> {}

final class _RenderViewportFooterLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ViewportFooterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ViewportFooterParentData> {
  _RenderViewportFooterLayout(this._minimumHeight);

  double _minimumHeight;

  double get minimumHeight => _minimumHeight;

  set minimumHeight(double value) {
    if (_minimumHeight != value) {
      _minimumHeight = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ViewportFooterParentData) {
      child.parentData = _ViewportFooterParentData();
    }
  }

  @override
  void performLayout() {
    final content = firstChild;
    final footer = content == null ? null : childAfter(content);
    final childConstraints = BoxConstraints(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
    );

    content?.layout(childConstraints, parentUsesSize: true);
    footer?.layout(childConstraints, parentUsesSize: true);

    final contentHeight = content?.size.height ?? 0;
    final footerHeight = footer?.size.height ?? 0;
    final naturalHeight = contentHeight + footerHeight;
    final layoutHeight = math.max(_minimumHeight, naturalHeight);
    final layoutWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : math.max(content?.size.width ?? 0, footer?.size.width ?? 0);
    size = constraints.constrain(Size(layoutWidth, layoutHeight));

    if (content != null) {
      (content.parentData! as _ViewportFooterParentData).offset = Offset.zero;
    }
    if (footer != null) {
      (footer.parentData! as _ViewportFooterParentData).offset = Offset(
        0,
        math.max(contentHeight, size.height - footerHeight),
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
