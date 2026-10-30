import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/pressable.dart';
import '../domain/teacher.dart';
import 'teachers_providers.dart';

/// Suallara kömək etmiş müəllimlər: ad, fənn, əlaqə nömrəsi və hazırlıq təklifi.
class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.teachersTitle)),
      body: SafeArea(
        child: AsyncValueView<List<Teacher>>(
          value: ref.watch(teachersProvider),
          onRetry: () => ref.invalidate(teachersProvider),
          builder: (teachers) => teachers.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: Text(
                      AppStrings.teachersEmpty,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m + 4,
                    AppSpacing.s,
                    AppSpacing.m + 4,
                    AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      AppStrings.teachersIntro,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    AppSpacing.gapL,
                    for (final (i, teacher) in teachers.indexed)
                      FadeSlideIn(
                        index: i,
                        child: _TeacherCard(teacher: teacher),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({required this.teacher});

  final Teacher teacher;

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (opened) return;
    await Clipboard.setData(ClipboardData(text: teacher.phone));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(AppStrings.contactFailed)));
  }

  String get _modeLabel => switch (teacher.lessonMode) {
    LessonMode.inPerson => AppStrings.lessonInPerson,
    LessonMode.online => AppStrings.lessonOnline,
    LessonMode.both => AppStrings.lessonBoth,
  };

  IconData get _modeIcon => switch (teacher.lessonMode) {
    LessonMode.inPerson => Icons.location_on_rounded,
    LessonMode.online => Icons.videocam_rounded,
    LessonMode.both => Icons.devices_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // ünvan yalnız əyani dərsi olan müəllimdə mənalıdır
    final showAddress =
        teacher.hasAddress && teacher.lessonMode != LessonMode.online;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m + 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(teacher: teacher),
              AppSpacing.gapM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teacher.name, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      teacher.subject,
                      style: text.bodyMedium?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapM,
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _InfoChip(icon: _modeIcon, label: _modeLabel),
              if (showAddress)
                _InfoChip(icon: Icons.place_outlined, label: teacher.address!),
            ],
          ),
          if (teacher.hasAbout) ...[
            AppSpacing.gapM,
            Text(
              AppStrings.aboutTeacher,
              style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            AppSpacing.gapXs,
            Text(
              teacher.about!,
              style: text.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (teacher.hasOffer) ...[
            AppSpacing.gapM,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.teacherOffer,
                    style: text.labelMedium?.copyWith(color: scheme.primary),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    teacher.offer!,
                    style: text.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ],
          AppSpacing.gapM,
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.call_rounded,
                  label: AppStrings.callAction,
                  filled: true,
                  onTap: () =>
                      _open(context, Uri(scheme: 'tel', path: teacher.phone)),
                ),
              ),
              AppSpacing.gapS,
              Expanded(
                child: _ContactButton(
                  icon: Icons.chat_rounded,
                  label: AppStrings.whatsappAction,
                  filled: false,
                  onTap: () => _open(
                    context,
                    Uri.parse('https://wa.me/${teacher.phoneDigits}'),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapS,
          Center(
            child: Text(
              teacher.phone,
              style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Müəllimin fotosu (tətbiq faylı və ya link). Yoxdursa və ya yüklənmirsə adın ilk hərfi.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.teacher});

  final Teacher teacher;

  static const _size = 72.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = teacher.name.trim();
    final initial = name.isEmpty ? '' : name.characters.first.toUpperCase();
    final fallback = Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      color: scheme.primaryContainer,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
    Widget content = fallback;
    if (teacher.hasPhoto) {
      final path = teacher.photo!.trim();
      content = teacher.isNetworkPhoto
          ? Image.network(
              path,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
          : Image.asset(
              path,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.l),
      child: SizedBox(width: _size, height: _size, child: content),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m - 2,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = filled ? scheme.onPrimary : scheme.primary;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: filled
              ? scheme.primary
              : scheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
