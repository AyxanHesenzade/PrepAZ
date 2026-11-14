import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../home/domain/subject.dart';
import '../../../home/presentation/widgets/subject_sheet.dart';

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
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.gold,
                      size: 28,
                    ),
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
                          const Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: Text(
                              '@$nickname',
                              overflow: TextOverflow.ellipsis,
                              style: text.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
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
  const _GlassPill({
    required this.child,
    required this.onTap,
    this.big = false,
  });

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
