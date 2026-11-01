import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import 'option_tile.dart';

/// Şəkil-sualın variantları şəkildədir, ona görə yalnız hərf düymələri göstərilir: A B C D E.
class LetterOptions extends StatelessWidget {
  const LetterOptions({
    super.key,
    required this.letters,
    required this.statusOf,
    required this.onTap,
  });

  final List<String> letters;
  final OptionStatus Function(String letter) statusOf;

  /// null olanda toxunmaq olmur (cavab artıq yoxlanıb).
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final letter in letters)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: LetterButton(
                letter: letter,
                status: statusOf(letter),
                onTap: onTap == null ? null : () => onTap!(letter),
              ),
            ),
          ),
      ],
    );
  }
}

class LetterButton extends StatelessWidget {
  const LetterButton({
    super.key,
    required this.letter,
    required this.status,
    required this.onTap,
    this.height = 60,
  });

  final String letter;
  final OptionStatus status;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (background, border) = optionColors(context, status);
    final (badgeBackground, badgeForeground) = letterBadgeColors(
      context,
      status,
    );
    final idle = status == OptionStatus.idle;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: idle ? background : badgeBackground,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(
          letter,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: idle ? null : badgeForeground),
        ),
      ),
    );
  }
}
