import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mascot/mascot.dart';
import '../../../../core/widgets/mascot/mascot_behavior.dart';
import '../../domain/tour_step.dart';
import '../tour_controller.dart';
import '../tour_targets.dart';

/// Ana ekranın (yan menyu daxil) üstünü örtür: ekran qaralır, izah olunan element
/// işıqlı qalır, köməkçi balonda izah edir. Tur gedərkən altdakı heç nə basılmır.
class TourOverlay extends ConsumerWidget {
  const TourOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(tourControllerProvider);
    return step == null ? const SizedBox.shrink() : _TourLayer(step: step);
  }
}

class _TourLayer extends ConsumerStatefulWidget {
  const _TourLayer({required this.step});

  final TourStep step;

  @override
  ConsumerState<_TourLayer> createState() => _TourLayerState();
}

class _TourLayerState extends ConsumerState<_TourLayer>
    with SingleTickerProviderStateMixin {
  // yalnız tur açıq olanda fırlanır, tur bitəndə controller dispose olunur
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  TourTargets get _targets => TourScope.maybeOf(context)!;

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  bool _isAvailable(TourStep step) {
    if (!step.onSubjectCard) return true;
    return _targets.keyFor(step)?.currentContext != null;
  }

  void _next() {
    final leaving = widget.step;
    final controller = ref.read(tourControllerProvider.notifier);
    if (leaving == TourStep.openMenu) {
      _targets.scaffold.currentState?.openDrawer();
    }
    controller.advance(_isAvailable);
    final next = ref.read(tourControllerProvider);
    if (leaving.inDrawer && next?.inDrawer != true) {
      _targets.scaffold.currentState?.closeDrawer();
    }
    if (next != null && next.onSubjectCard) _reveal(next);
  }

  /// Fənn kartı ekrandan aşağıda qala bilər: elementi görünən yerə sürüşdürür.
  void _reveal(TourStep step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _targets.keyFor(step)?.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// Hər kadr ölçülür: yan menyu açılanda və siyahı sürüşəndə işıq elementin arxasınca gedir.
  Rect? _targetRect() {
    final overlay = context.findRenderObject();
    final target = _targets
        .keyFor(widget.step)
        ?.currentContext
        ?.findRenderObject();
    if (overlay is! RenderBox || target is! RenderBox || !target.attached) {
      return null;
    }
    final topLeft = target.localToGlobal(Offset.zero, ancestor: overlay);
    return (topLeft & target.size).inflate(6);
  }

  void _onTapUp(TapUpDetails details, Rect? hole) {
    // menyu addımında yeganə çıxış işıqlı düyməyə basmaqdır
    if (widget.step == TourStep.openMenu &&
        hole != null &&
        hole.contains(details.localPosition)) {
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (context, _) {
          final hole = _targetRect();
          final height = MediaQuery.sizeOf(context).height;
          final coachOnTop = hole != null && hole.center.dy > height / 2;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _onTapUp(details, hole),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _SpotlightPainter(hole: hole, pulse: _motion.value),
                ),
                SafeArea(
                  child: Align(
                    alignment: hole == null
                        ? Alignment.center
                        : coachOnTop
                        ? Alignment.topCenter
                        : Alignment.bottomCenter,
                    child: _Coach(step: widget.step, onNext: _next),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Coach extends StatelessWidget {
  const _Coach({required this.step, required this.onNext});

  final TourStep step;
  final VoidCallback onNext;

  String get _message => switch (step) {
    TourStep.welcome => AppStrings.tourWelcome,
    TourStep.openMenu => AppStrings.tourOpenMenu,
    TourStep.language => AppStrings.tourLanguage,
    TourStep.appearance => AppStrings.tourAppearance,
    TourStep.teachers => AppStrings.tourTeachers,
    TourStep.report => AppStrings.tourReport,
    TourStep.legal => AppStrings.tourLegal,
    TourStep.deleteAccount => AppStrings.tourDeleteAccount,
    TourStep.signOut => AppStrings.tourSignOut,
    TourStep.practice => AppStrings.tourPractice,
    TourStep.weakPlaces => AppStrings.tourWeakPlaces,
    TourStep.mistakes => AppStrings.tourMistakes,
    TourStep.topics => AppStrings.tourTopics,
    TourStep.done => AppStrings.tourDone,
  };

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Bubble(text: _message),
            const Mascot(behavior: TalkingMascot()),
            if (step != TourStep.openMenu) ...[
              AppSpacing.gapS,
              SizedBox(
                width: 220,
                child: AppButton(
                  label: step == TourStep.done
                      ? AppStrings.tourFinish
                      : AppStrings.tourGotIt,
                  onPressed: onNext,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Köməkçinin başının üstündəki balon. Rəngi gecə rejimində də ağ qalır.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.l),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.brandEnd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomPaint(size: const Size(24, 12), painter: _BubbleTailPainter()),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) => false;
}

/// Qaranlıq fon, [hole] yerində işıqlı pəncərə və döyünən çərçivə.
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({required this.hole, required this.pulse});

  final Rect? hole;
  final double pulse;

  static const _radius = Radius.circular(AppRadius.m);

  @override
  void paint(Canvas canvas, Size size) {
    final shade = Paint()..color = Colors.black.withValues(alpha: 0.68);
    final screen = Path()..addRect(Offset.zero & size);
    final target = hole;
    if (target == null) {
      canvas.drawPath(screen, shade);
      return;
    }
    final window = RRect.fromRectAndRadius(target, _radius);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        screen,
        Path()..addRRect(window),
      ),
      shade,
    );
    // saniyədə bir dəfə döyünür (controller 6 saniyəlikdir)
    final beat = (pulse * 6) % 1;
    canvas.drawRRect(
      window.inflate(beat * 6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white.withValues(alpha: 1 - beat),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.hole != hole || oldDelegate.pulse != pulse;
}
