import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../domain/release_note.dart';

/// "Yeniliklər": aşağıdan açılan panel, ən yeni versiya yuxarıda.
Future<void> showWhatsNewSheet(BuildContext context, List<ReleaseNote> notes) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => WhatsNewSheet(notes: notes),
  );
}

class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key, required this.notes});

  final List<ReleaseNote> notes;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m + 4,
          0,
          AppSpacing.m + 4,
          AppSpacing.l,
        ),
        children: [
          Text(
            AppStrings.whatsNewTitle,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          for (final note in notes) ...[
            AppSpacing.gapM,
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandStart, AppColors.brandEnd],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppStrings.whatsNewVersion(note.version),
                  style: text.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
            for (final item in note.items())
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.s),
                padding: const EdgeInsets.all(AppSpacing.s + 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Text(item, style: text.bodyLarge),
              ),
          ],
          AppSpacing.gapL,
          AppButton(
            label: AppStrings.whatsNewOk,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
