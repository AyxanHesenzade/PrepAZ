import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_version.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../browse/presentation/topic_list_screen.dart';
import '../../menu/presentation/app_drawer.dart';
import '../../mistakes/presentation/mistakes_screen.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../domain/subject.dart';
import '../domain/topic_mastery.dart';
import 'home_providers.dart';
import 'weak_topics_screen.dart';
import 'widgets/streak_card.dart';
import 'widgets/subject_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(streakDaysProvider.future),
      ref.refresh(subjectsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // başlıq sabitdir: siyahı sürüşəndə yerində qalır
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m + 4,
                AppSpacing.m,
                AppSpacing.m + 4,
                AppSpacing.s,
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton.filledTonal(
                      tooltip: AppStrings.menu,
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.surfaceContainerLowest,
                        foregroundColor: scheme.onSurface,
                        fixedSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  AppSpacing.gapM,
                  Expanded(
                    child: Text(
                      AppStrings.homeTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m + 4,
                    AppSpacing.m,
                    AppSpacing.m + 4,
                    AppSpacing.l,
                  ),
                  children: [
                    const FadeSlideIn(child: _StreakSection()),
                    AppSpacing.gapXl,
                    const _SubjectsSection(),
                  ],
                ),
              ),
            ),
            const _VersionFooter(),
          ],
        ),
      ),
    );
  }
}

/// Ekranın altında sabit duran versiya yazısı (siyahı ilə sürüşmür). Oxunmasa heç nə göstərilmir.
class _VersionFooter extends ConsumerWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).asData?.value;
    if (version == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s + 2),
      color: scheme.surface,
      child: Text(
        AppStrings.appVersion(version.version, version.build),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.outline),
      ),
    );
  }
}

class _StreakSection extends ConsumerWidget {
  const _StreakSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView(
      value: ref.watch(streakDaysProvider),
      onRetry: () => ref.invalidate(streakDaysProvider),
      builder: (days) => StreakCard(days: days),
    );
  }
}

class _SubjectsSection extends ConsumerWidget {
  const _SubjectsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView(
      value: ref.watch(subjectsProvider),
      onRetry: () => ref.invalidate(subjectsProvider),
      builder: (subjects) {
        if (subjects.isEmpty) return Text(AppStrings.noSubjects);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.subjects,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppSpacing.gapM,
            for (final (i, subject) in subjects.indexed)
              FadeSlideIn(
                index: i + 1,
                child: _SubjectItem(subject: subject),
              ),
          ],
        );
      },
    );
  }
}

class _SubjectItem extends ConsumerWidget {
  const _SubjectItem({required this.subject});

  final Subject subject;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => QuizScreen(subject: subject)),
    );
    // məşqdən sonra seriya və faizlər yenilənsin
    ref.invalidate(streakDaysProvider);
    ref.invalidate(masteryProvider(subject.id));
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    // alt ekranlarda məşq edilmiş ola bilər
    ref.invalidate(streakDaysProvider);
    ref.invalidate(masteryProvider(subject.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // yüklənərkən və ya xəta olanda kart boş siyahı ilə görünür, məşqə başlamaq yenə mümkündür
    final weak = ref
        .watch(masteryProvider(subject.id))
        .maybeWhen(data: (m) => m, orElse: () => const <TopicMastery>[]);
    return SubjectCard(
      subject: subject,
      weakTopics: weak,
      onStart: () => _start(context, ref),
      onWeakPlaces: () =>
          _open(context, ref, WeakTopicsScreen(subject: subject)),
      onMistakes: () => _open(context, ref, MistakesScreen(subject: subject)),
      onTopics: () => _open(context, ref, TopicListScreen(subject: subject)),
    );
  }
}
