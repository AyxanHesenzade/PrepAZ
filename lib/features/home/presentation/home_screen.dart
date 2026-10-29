import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../domain/subject.dart';
import '../domain/topic_mastery.dart';
import 'home_providers.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: const [
            _StreakSection(),
            AppSpacing.gapL,
            _SubjectsSection(),
          ],
        ),
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
        if (subjects.isEmpty) return const Text(AppStrings.noSubjects);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.subjects, style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapS,
            for (final subject in subjects) _SubjectItem(subject: subject),
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
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => QuizScreen(subject: subject)));
    // məşqdən sonra seriya və faizlər yenilənsin
    ref.invalidate(streakDaysProvider);
    ref.invalidate(masteryProvider(subject.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // yüklənərkən və ya xəta olanda kart boş siyahı ilə görünür, məşqə başlamaq yenə mümkündür
    final weak = ref.watch(masteryProvider(subject.id)).maybeWhen(
          data: (m) => m,
          orElse: () => const <TopicMastery>[],
        );
    return SubjectCard(subject: subject, weakTopics: weak, onStart: () => _start(context, ref));
  }
}
