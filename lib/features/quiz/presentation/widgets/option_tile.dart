import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/math_text.dart';
import '../../../../core/widgets/pressable.dart';

enum OptionStatus { idle, selected, correct, wrong }

const _fast = Duration(milliseconds: 220);

/// Variantın fonu və haşiyəsi (OptionTile və LetterOptions eyni rəngləri işlədir).
(Color background, Color border) optionColors(
  BuildContext context,
  OptionStatus status,
) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    OptionStatus.correct => (
      AppColors.success.withValues(alpha: 0.12),
      AppColors.success,
    ),
    OptionStatus.wrong => (
      AppColors.danger.withValues(alpha: 0.10),
      AppColors.danger,
    ),
    OptionStatus.selected => (
      scheme.primary.withValues(alpha: 0.08),
      scheme.primary,
    ),
    OptionStatus.idle => (scheme.surfaceContainerLowest, Colors.transparent),
  };
}

/// Hərf nişanının (dairə) fonu və yazı rəngi.
(Color background, Color foreground) letterBadgeColors(
  BuildContext context,
  OptionStatus status,
) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    OptionStatus.correct => (AppColors.success, Colors.white),
    OptionStatus.wrong => (AppColors.danger, Colors.white),
    OptionStatus.selected => (scheme.primary, scheme.onPrimary),
    OptionStatus.idle => (
      scheme.surfaceContainerHighest,
      scheme.onSurfaceVariant,
    ),
  };
}

/// Qapalı sualın bir variantı: hərf nişanı + mətn. Rənglər keçid animasiyası ilə dəyişir.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.status,
    required this.onTap,
  });

  final String letter;
  final String text;
  final OptionStatus status;

  /// null olanda toxunmaq olmur (cavab artıq yoxlanıb).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border) = optionColors(context, status);
    final (badgeBackground, badgeForeground) = letterBadgeColors(
      context,
      status,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s + 2),
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: _fast,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m - 2,
            vertical: AppSpacing.s + 5,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.m),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: _fast,
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBackground,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: badgeForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m - 2),
              Expanded(child: MathText(text)),
              if (status == OptionStatus.correct)
                const Icon(Icons.check, color: AppColors.success),
              if (status == OptionStatus.wrong)
                const Icon(Icons.close, color: AppColors.danger),
            ],
          ),
        ),
      ),
    );
  }
}
