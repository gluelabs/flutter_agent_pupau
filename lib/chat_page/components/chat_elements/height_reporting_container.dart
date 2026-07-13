import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Measures [child]'s height after layout and reports changes above [heightChangeEpsilon].
class HeightReportingContainer extends StatefulWidget {
  const HeightReportingContainer({
    super.key,
    required this.onHeight,
    required this.child,
    this.heightChangeEpsilon = 0.25,
  });

  final void Function(double height) onHeight;
  final Widget child;

  /// Ignore sub-pixel jitter (logical px).
  final double heightChangeEpsilon;

  @override
  State<HeightReportingContainer> createState() =>
      _HeightReportingContainerState();
}

class _HeightReportingContainerState extends State<HeightReportingContainer> {
  final GlobalKey _contentKey = GlobalKey();

  double _lastEmittedHeight = -1.0;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }
      _emitHeightIfNeeded();
    });
    return KeyedSubtree(
      key: _contentKey,
      child: widget.child,
    );
  }

  void _emitHeightIfNeeded() {
    final RenderObject? renderObject =
        _contentKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }
    final double height = renderObject.size.height;
    if (_lastEmittedHeight >= 0 &&
        (height - _lastEmittedHeight).abs() < widget.heightChangeEpsilon) {
      return;
    }
    _lastEmittedHeight = height;
    widget.onHeight(height);
  }
}
