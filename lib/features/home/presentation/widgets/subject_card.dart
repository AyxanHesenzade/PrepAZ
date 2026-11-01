import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/subject.dart';
import '../../domain/topic_mastery.dart';
import 'mastery_row.dart';

/// Fənn kartı: fənnin öz rəngində yumşaq fon, ən zəif 3 mövzu və iri "məşqə başla" düyməsi.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.topics,
    required this.onStart,
    required this.onWeakPlaces,
    required this.onMistakes,
    required this.onTopics,
    this.startKey,
    this.weakPlacesKey,
    this.mistakesKey,
    this.topicsKey,
  });

  static const maxWeakShown = 3;
  static const maxStrongShown = 2;

  final Subject subject;
  /// Ən zəifdən başlayaraq, artıq sıralanmış.
  final List<TopicMastery> topics;
  final VoidCallback onStart;
  final VoidCallback onWeakPlaces;
  final VoidCallback onMistakes;
  final VoidCallback onTopics;

  /// Öyrədici tur düymələri bu açarlarla tapır (yalnız birinci kartda verilir).
  final Key? startKey;
  final Key? weakPlacesKey;
  final Key? mistakesKey;
  final Key? topicsKey;

  static IconData iconFor(String slug) => switch (slug) {
    'kimya' => Icons.science_rounded,
    'biologiya' => Icons.eco_rounded,
    _ => Icons.auto_stories_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    final tint = Color.alphaBlend(
      accent.withValues(alpha: isLight ? 0.10 : 0.16),
      scheme.surfaceContainerLowest,
    );
    final weak = topics.where((t) => t.isWeak).take(maxWeakShown).toList();
    final strong = topics.reversed.where((t) => t.isStrong).take(maxStrongShown).toList();
    final message = topics.isEmpty ? AppStrings.noMasteryYet : AppStrings.needMoreAnswers;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m + 2),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Icon(
                  iconFor(subject.slug),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              AppSpacing.gapM,
              Expanded(child: Text(subject.name, style: text.titleLarge)),
            ],
          ),
          AppSpacing.gapM,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.s,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
            child: weak.isEmpty && strong.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: Text(
                      message,
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (weak.isNotEmpty)
                        MasteryGroup(title: AppStrings.weakTopics, topics: weak),
                      if (weak.isNotEmpty && strong.isNotEmpty) AppSpacing.gapS,
                      if (strong.isNotEmpty)
                        MasteryGroup(title: AppStrings.strongTopics, topics: strong),
                    ],
                  ),
          ),
          AppSpacing.gapM,
          Pressable(
            key: startKey,
            onTap: onStart,
            child: Container(
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      AppStrings.startQuiz,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                  AppSpacing.gapS,
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapS,
          Row(
            children: [
              Expanded(
                child: _SoftAction(
                  key: weakPlacesKey,
                  icon: Icons.insights_rounded,
                  label: AppStrings.weakPlacesTitle,
                  color: accent,
                  onTap: onWeakPlaces,
                ),
              ),
              AppSpacing.gapS,
              Expanded(
                child: _SoftAction(
                  key: mistakesKey,
                  icon: Icons.menu_book_rounded,
                  label: AppStrings.mistakesBook,
                  color: accent,
                  onTap: onMistakes,
                ),
              ),
            ],
          ),
          AppSpacing.gapS,
          _SoftAction(
            key: topicsKey,
            icon: Icons.list_alt_rounded,
            label: AppStrings.topicsTitle,
            color: accent,
            onTap: onTopics,
          ),
        ],
      ),
    );
  }
}

class _SoftAction extends StatelessWidget {
  const _SoftAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: scheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
