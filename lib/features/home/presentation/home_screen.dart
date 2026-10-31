import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_version.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../browse/presentation/topic_list_screen.dart';
import '../../goal/domain/exam_goal.dart';
import '../../goal/presentation/goal_providers.dart';
import '../../goal/presentation/goal_screen.dart';
import '../../goal/presentation/widgets/goal_card.dart';
import '../../menu/presentation/app_drawer.dart';
import '../../mistakes/presentation/mistakes_screen.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../tour/presentation/tour_controller.dart';
import '../../tour/presentation/tour_targets.dart';
import '../../tour/presentation/widgets/tour_overlay.dart';
import '../domain/subject.dart';
import '../domain/topic_mastery.dart';
import 'home_providers.dart';
import 'weak_topics_screen.dart';
import 'widgets/header_mascot.dart';
import 'widgets/streak_card.dart';
import 'widgets/subject_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _tour = TourTargets();

  Future<void> _refresh() async {
    await Future.wait([
      ref.refresh(streakDaysProvider.future),
      ref.refresh(userGoalProvider.future),
      ref.refresh(answeredTodayProvider.future),
      ref.refresh(subjectsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TourScope(
      targets: _tour,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            key: _tour.scaffold,
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
                            key: _tour.menuButton,
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
                        const HeaderMascot(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.m + 4,
                          AppSpacing.m,
                          AppSpacing.m + 4,
                          AppSpacing.l,
                        ),
                        children: [
                          const FadeSlideIn(child: _StreakSection()),
                          AppSpacing.gapM,
                          const FadeSlideIn(index: 1, child: _GoalSection()),
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
          ),
          // yan menyunun da üstündə qalsın deyə Scaffold-un xaricindədir
          const TourOverlay(),
        ],
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
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: scheme.outline),
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

/// Hədəf kartı. Şagird hələ hədəf seçməyibsə, ilk açılışda seçim ekranı bir dəfə özü açılır.
class _GoalSection extends ConsumerStatefulWidget {
  const _GoalSection();

  @override
  ConsumerState<_GoalSection> createState() => _GoalSectionState();
}

class _GoalSectionState extends ConsumerState<_GoalSection> {
  bool _prompted = false;

  Future<void> _open({bool firstTime = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GoalScreen(firstTime: firstTime)),
    );
    ref.invalidate(userGoalProvider);
    if (firstTime && mounted) _startTour();
  }

  /// Hədəf seçimindən sonra (və ya seçim lazım deyilsə) ilk açılışda tur başlayır.
  void _startTour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(tourControllerProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserGoal?>>(userGoalProvider, (_, next) {
      if (next.isLoading || _prompted) return;
      if (next.hasError || next.value != null) {
        _startTour();
        return;
      }
      // yalnız uğurla oxunub və hədəf yoxdursa; xəta olanda şagirdi narahat etmirik
      _prompted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open(firstTime: true);
      });
    });
    final goal = ref.watch(userGoalProvider);
    // kart köməkçi məlumatdır: yüklənərkən və ya xəta olanda gizlənir, ana ekranı pozmur
    if (!goal.hasValue) return const SizedBox.shrink();
    final periods =
        ref.watch(examPeriodsProvider).asData?.value ?? const <ExamPeriod>[];
    final value = goal.requireValue ?? const UserGoal();
    return GoalCard(
      daysLeft: value.daysLeft(periods, DateTime.now()),
      answeredToday: ref.watch(answeredTodayProvider).asData?.value ?? 0,
      dailyGoal: value.dailyGoal,
      onTap: _open,
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
                child: _SubjectItem(subject: subject, isFirst: i == 0),
              ),
          ],
        );
      },
    );
  }
}

class _SubjectItem extends ConsumerWidget {
  const _SubjectItem({required this.subject, required this.isFirst});

  final Subject subject;

  /// Öyrədici tur yalnız birinci fənn kartını göstərir.
  final bool isFirst;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => QuizScreen(subject: subject)),
    );
    // məşqdən sonra seriya və faizlər yenilənsin
    ref.invalidate(streakDaysProvider);
    ref.invalidate(answeredTodayProvider);
    ref.invalidate(masteryProvider(subject.id));
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    // alt ekranlarda məşq edilmiş ola bilər
    ref.invalidate(streakDaysProvider);
    ref.invalidate(answeredTodayProvider);
    ref.invalidate(masteryProvider(subject.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // yüklənərkən və ya xəta olanda kart boş siyahı ilə görünür, məşqə başlamaq yenə mümkündür
    final weak = ref
        .watch(masteryProvider(subject.id))
        .maybeWhen(data: (m) => m, orElse: () => const <TopicMastery>[]);
    final tour = isFirst ? TourScope.maybeOf(context) : null;
    return SubjectCard(
      subject: subject,
      weakTopics: weak,
      startKey: tour?.practice,
      weakPlacesKey: tour?.weakPlaces,
      mistakesKey: tour?.mistakes,
      topicsKey: tour?.topics,
      onStart: () => _start(context, ref),
      onWeakPlaces: () =>
          _open(context, ref, WeakTopicsScreen(subject: subject)),
      onMistakes: () => _open(context, ref, MistakesScreen(subject: subject)),
      onTopics: () => _open(context, ref, TopicListScreen(subject: subject)),
    );
  }
}
