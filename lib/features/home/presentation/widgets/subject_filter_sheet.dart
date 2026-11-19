import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/subject.dart';
import 'subject_sheet.dart';

/// Ana ekranda hansı fənlərin görünəcəyini seçmək: aşağıdan açılan panel, hər fənn işarələnir.
/// Ən azı bir fənn seçili qalır. "Hazır" yeni gizlədilən id-ləri qaytarır, bağlansa null.
Future<Set<int>?> showSubjectFilterSheet(
  BuildContext context, {
  required List<Subject> subjects,
  required Set<int> hidden,
}) {
  return showAppBottomSheet<Set<int>>(
    context: context,
    builder: (_) => _FilterSheet(subjects: subjects, hidden: hidden),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.subjects, required this.hidden});

  final List<Subject> subjects;
  final Set<int> hidden;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final Set<int> _shown = {
    for (final s in widget.subjects) if (!widget.hidden.contains(s.id)) s.id,
  };

  @override
  void initState() {
    super.initState();
    // köhnə filtr hamısını gizlədibsə, hamısı seçili başlayır
    if (_shown.isEmpty) _shown.addAll(widget.subjects.map((s) => s.id));
  }

  bool get _all => _shown.length == widget.subjects.length;

  void _toggle(int id) {
    setState(() {
      if (!_shown.contains(id)) {
        _shown.add(id);
      } else if (_shown.length > 1) {
        _shown.remove(id); // sonuncu fənn çıxarılmır
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m + 4, 0, AppSpacing.m + 4, AppSpacing.l),
      children: [
        Row(
          children: [
            Expanded(child: Text(AppStrings.subjectFilterTitle, style: text.titleLarge)),
            TextButton(
              onPressed: _all ? null : () => setState(() => _shown.addAll(widget.subjects.map((s) => s.id))),
              child: Text(AppStrings.subjectFilterAll),
            ),
          ],
        ),
        AppSpacing.gapXs,
        Text(
          AppStrings.subjectFilterHint,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        AppSpacing.gapM,
        for (final s in widget.subjects)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _SubjectTile(
              subject: s,
              selected: _shown.contains(s.id),
              onTap: () => _toggle(s.id),
            ),
          ),
        AppSpacing.gapS,
        FilledButton(
          onPressed: () => Navigator.of(context).pop({
            for (final s in widget.subjects) if (!_shown.contains(s.id)) s.id,
          }),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(AppStrings.subjectFilterDone),
        ),
      ],
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject, required this.selected, required this.onTap});

  final Subject subject;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.s + 4),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: selected ? accent : scheme.outlineVariant, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: selected
                      ? [accent, Color.lerp(accent, AppColors.brandEnd, 0.5)!]
                      : [scheme.outlineVariant, scheme.outline],
                ),
              ),
              child: Icon(subjectIcon(subject.slug), color: Colors.white),
            ),
            AppSpacing.gapM,
            Expanded(
              child: Text(subject.name, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Icon(
              selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: selected ? accent : scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
