import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../home/domain/subject.dart';

/// Fənnin simvolu (seçim panelində və başlıqda).
IconData subjectIcon(String slug) => switch (slug) {
  'kimya' => Icons.science_rounded,
  'biologiya' => Icons.eco_rounded,
  _ => Icons.menu_book_rounded,
};

/// "Yarış" ekranının başlığı: fənnin rəngində gradient kart, nik-ad düyməsi və fənn seçimi.
/// Fənn dəyişəndə rəng yumşaq keçir.
class BoardHeader extends StatelessWidget {
  const BoardHeader({
    super.key,
    required this.subjects,
    required this.selected,
    required this.nickname,
    required this.onSubjectChanged,
    required this.onEditPlayer,
  });

  final List<Subject> subjects;
  final Subject selected;
  final String nickname;
  final ValueChanged<int> onSubjectChanged;
  final VoidCallback onEditPlayer;

  Future<void> _pickSubject(BuildContext context) async {
    final id = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _SubjectSheet(subjects: subjects, selectedId: selected.id),
    );
    if (id != null && id != selected.id) onSubjectChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = AppColors.subjectAccent(selected.slug, selected.id);
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
            right: -24,
            top: -10,
            child: Icon(
              Icons.emoji_events_rounded,
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
                    const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 28),
                    AppSpacing.gapS,
                    Expanded(
                      child: Text(
                        AppStrings.competeTitle,
                        style: text.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _GlassPill(
                      onTap: onEditPlayer,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: Text(
                              '@$nickname',
                              overflow: TextOverflow.ellipsis,
                              style: text.labelLarge?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapM,
                _GlassPill(
                  big: true,
                  onTap: () => _pickSubject(context),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(subjectIcon(selected.slug), size: 20, color: accent),
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
                        const Icon(Icons.unfold_more_rounded, color: Colors.white),
                    ],
                  ),
                ),
                AppSpacing.gapM,
                Text(
                  AppStrings.leaderboardAllHint,
                  style: text.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient üstündə yarımşəffaf "şüşə" düymə.
class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child, required this.onTap, this.big = false});

  final Widget child;
  final VoidCallback onTap;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: big
            ? const EdgeInsets.fromLTRB(8, 8, 14, 8)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: child,
      ),
    );
  }
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
                            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (selected) Icon(Icons.check_circle_rounded, color: accent),
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
