import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../home/domain/subject.dart';
import '../../../home/presentation/widgets/subject_sheet.dart';
import '../../domain/subject_stats.dart';

/// "İrəliləyiş" başlığı: fənnin rəngində gradient kart, şüşə fənn seçimi və fənnin nə qədərinin həll edildiyi.
class StatsHeader extends StatelessWidget {
  const StatsHeader({
    super.key,
    required this.subjects,
    required this.selected,
    required this.stats,
    required this.onSubjectChanged,
  });

  final List<Subject> subjects;
  final Subject selected;

  /// Yüklənərkən null: zolaq göstərilmir.
  final SubjectStats? stats;
  final ValueChanged<int> onSubjectChanged;

  Future<void> _pick(BuildContext context) async {
    final id = await showSubjectSheet(
      context,
      subjects: subjects,
      selectedId: selected.id,
    );
    if (id != null && id != selected.id) onSubjectChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = AppColors.subjectAccent(selected.slug, selected.id);
    final s = stats;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, Color.lerp(accent, AppColors.brandEnd, 0.6)!],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -14,
            child: Icon(
              Icons.insights_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.m + 4,
              AppSpacing.m,
              AppSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    AppSpacing.gapS,
                    Text(
                      AppStrings.progressTitle,
                      style: text.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapM,
                Pressable(
                  onTap: () => _pick(context),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            subjectIcon(selected.slug),
                            size: 20,
                            color: accent,
                          ),
                        ),
                        AppSpacing.gapS,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppStrings.subjectLabel,
                                style: text.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                              Text(
                                selected.name,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (subjects.length > 1)
                          const Icon(
                            Icons.unfold_more_rounded,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ),
                if (s != null && s.questionsTotal > 0) ...[
                  AppSpacing.gapM,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.statsSolvedOf(
                            s.questionsSolved,
                            s.questionsTotal,
                          ),
                          style: text.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        AppStrings.statsCoverage((s.coverage * 100).round()),
                        style: text.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapS,
                  _GlassBar(value: s.coverage),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient üstündə ağ zolaq: dolarkən bir dəfə axır.
class _GlassBar extends StatelessWidget {
  const _GlassBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          // çox kiçik faiz də görünsün
          widthFactor: v == 0 ? 0 : v.clamp(0.03, 1).toDouble(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
      ),
    );
  }
}
