import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/subject.dart';

/// Fənnin simvolu (seçim panelində və başlıqlarda).
IconData subjectIcon(String slug) => switch (slug) {
  'kimya' => Icons.science_rounded,
  'biologiya' => Icons.eco_rounded,
  _ => Icons.menu_book_rounded,
};

/// Fənn seçimi: dropdown yox, aşağıdan açılan panel (rəngli ikonlu kartlar).
/// Seçilən fənnin id-si, bağlansa null.
Future<int?> showSubjectSheet(
  BuildContext context, {
  required List<Subject> subjects,
  required int selectedId,
}) {
  return showAppBottomSheet<int>(
    context: context,
    isScrollControlled: false,
    builder: (_) => _SubjectSheet(subjects: subjects, selectedId: selectedId),
  );
}

class _SubjectSheet extends StatelessWidget {
  const _SubjectSheet({required this.subjects, required this.selectedId});

  final List<Subject> subjects;
  final int selectedId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m + 4,
        0,
        AppSpacing.m + 4,
        AppSpacing.l,
      ),
      children: [
        Text(AppStrings.chooseSubject, style: text.titleLarge),
        AppSpacing.gapM,
        for (final s in subjects)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Builder(
              builder: (context) {
                final accent = AppColors.subjectAccent(s.slug, s.id);
                final selected = s.id == selectedId;
                return Pressable(
                  onTap: () => Navigator.of(context).pop(s.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.s + 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? accent.withValues(alpha: 0.12)
                          : scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      border: Border.all(
                        color: selected ? accent : scheme.outlineVariant,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                accent,
                                Color.lerp(accent, AppColors.brandEnd, 0.5)!,
                              ],
                            ),
                          ),
                          child: Icon(subjectIcon(s.slug), color: Colors.white),
                        ),
                        AppSpacing.gapM,
                        Expanded(
                          child: Text(
                            s.name,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded, color: accent),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
