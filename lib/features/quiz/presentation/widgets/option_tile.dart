import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/math_text.dart';

enum OptionStatus { idle, selected, correct, wrong }

/// Qapalı sualın bir variantı: "A) mətn".
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
    final scheme = Theme.of(context).colorScheme;
    final (background, border) = switch (status) {
      OptionStatus.correct => (AppColors.success.withValues(alpha: 0.15), AppColors.success),
      OptionStatus.wrong => (scheme.errorContainer, scheme.error),
      OptionStatus.selected => (scheme.primaryContainer, scheme.primary),
      OptionStatus.idle => (Colors.transparent, scheme.outlineVariant),
    };
    final emphasized = status != OptionStatus.idle;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: emphasized ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Text('$letter)', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Expanded(child: MathText(text)),
                if (status == OptionStatus.correct) const Icon(Icons.check, color: AppColors.success),
                if (status == OptionStatus.wrong) Icon(Icons.close, color: scheme.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
