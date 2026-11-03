import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mascot/mascot.dart';
import '../../../../core/widgets/mascot/mascot_behavior.dart';

/// Köməkçi ekranın yuxarısından hoppanıb gəlir, balonda söz deyir, bir neçə saniyədən sonra çəkilir.
/// Toxunanda dərhal çəkilir. Yeni söz gələndə ([token] dəyişəndə) yenidən başlayır.
///
/// Zaman cədvəli bir AnimationController-dədir (Timer yoxdur): testlərdə gözləyən taymer qalmır.
class CheerOverlay extends StatefulWidget {
  const CheerOverlay({
    super.key,
    required this.message,
    required this.token,
    this.animateMascot = false,
  });

  /// null = deyiləcək söz yoxdur.
  final String? message;

  /// Hər yeni söz üçün fərqli rəqəm.
  final int token;

  /// Köməkçinin özünün hərəkəti (ağız, əl). Testlərdə söndürülür.
  final bool animateMascot;

  static const total = Duration(milliseconds: 3800);

  /// Zaman cədvəli (0..1): girir, qalır, çıxır.
  static const _enterEnd = 0.12;
  static const _exitStart = 0.9;

  @override
  State<CheerOverlay> createState() => _CheerOverlayState();
}

class _CheerOverlayState extends State<CheerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: CheerOverlay.total,
  );

  @override
  void initState() {
    super.initState();
    if (widget.message != null) _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(CheerOverlay old) {
    super.didUpdateWidget(old);
    if (widget.token != old.token && widget.message != null) {
      _controller.forward(from: 0);
    }
  }

  /// Toxunanda: gözləmədən çıxış hissəsinə keçir.
  void _dismiss() {
    if (_controller.value < CheerOverlay._exitStart) {
      _controller.forward(from: CheerOverlay._exitStart);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    if (message == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        if (t == 0 || t >= 1) return const SizedBox.shrink();
        final enter = Curves.easeOutBack.transform(
          (t / CheerOverlay._enterEnd).clamp(0.0, 1.0),
        );
        final exit = Curves.easeIn.transform(
          ((t - CheerOverlay._exitStart) / (1 - CheerOverlay._exitStart)).clamp(0.0, 1.0),
        );
        return Transform.translate(
          offset: Offset(0, (1 - enter) * -180 + exit * -180),
          child: Opacity(
            opacity: 1 - exit,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
              child: Semantics(
                liveRegion: true,
                child: _Card(message: message, animateMascot: widget.animateMascot),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.message, required this.animateMascot});

  final String message;
  final bool animateMascot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Mascot(
            behavior: const TalkingMascot(),
            size: 72,
            animate: animateMascot,
          ),
          AppSpacing.gapS,
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                // gecə rejimində də ağ qalır: köməkçinin balonu hər yerdə eynidir
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.l),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 6)),
                ],
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF1B1F2A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
