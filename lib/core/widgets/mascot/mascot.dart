import 'package:flutter/material.dart';

import 'mascot_behavior.dart';
import 'mascot_painter.dart';
import 'mascot_style.dart';

/// PrepAZ köməkçisi. Nə etdiyini [behavior], necə göründüyünü [style] təyin edir.
/// [animate] false olanda və telefonda animasiyalar söndürüləndə sakit dayanır.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    required this.behavior,
    this.size = 96,
    this.style = const MascotStyle(),
    this.animate = true,
  });

  final MascotBehavior behavior;
  final double size;
  final MascotStyle style;
  final bool animate;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.behavior.cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(Mascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.behavior.cycle;
    _syncMotion();
  }

  void _syncMotion() {
    final shouldMove =
        widget.animate && !MediaQuery.disableAnimationsOf(context);
    if (shouldMove && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldMove && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: MascotPainter(
          animation: _controller,
          behavior: widget.behavior,
          style: widget.style,
        ),
      ),
    );
  }
}
