import 'package:flutter/material.dart';

/// Ekrana ilk çıxanda aşağıdan yuxarı süzülərək görünür. [index] artdıqca gecikir (kartlar ardıcıl gəlir).
/// Gecikmə Timer ilə yox, bir controller-in `Interval`-ı ilə qurulub: testlərdə gözləyən taymer qalmır.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  static const _step = 70; // ms
  static const _length = 520; // ms

  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    final delay = (widget.index.clamp(0, 6)) * _step;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: delay + _length),
    )..forward();
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay / (delay + _length), 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
