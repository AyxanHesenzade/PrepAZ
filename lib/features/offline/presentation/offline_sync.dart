import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goal/presentation/goal_providers.dart';
import '../../home/presentation/home_providers.dart';
import '../../quiz/presentation/quiz_providers.dart';
import '../domain/answer_syncer.dart';
import 'offline_providers.dart';

final answerSyncerProvider = Provider<AnswerSyncer>(
  (ref) => AnswerSyncer(
    outbox: ref.watch(answerOutboxProvider),
    quiz: ref.watch(quizRepositoryProvider),
    store: ref.watch(offlineStoreProvider),
  ),
);

/// Gözləyən oflayn cavabları göndərməyə çalışır (internet yoxdursa, heç nə olmur). Gözlənilmir.
void flushOfflineAnswers(Ref ref) => _flush(ref.read(answerSyncerProvider), () {
  ref.invalidate(masteryProvider);
  ref.invalidate(streakDaysProvider);
  ref.invalidate(answeredTodayProvider);
});

void flushOfflineAnswersFromWidget(WidgetRef ref) =>
    _flush(ref.read(answerSyncerProvider), () {
      ref.invalidate(masteryProvider);
      ref.invalidate(streakDaysProvider);
      ref.invalidate(answeredTodayProvider);
    });

/// Göndərilibsə, ana ekrandakı rəqəmlər (seriya, bu günkü cavablar, mövzu faizi) yenilənir.
void _flush(AnswerSyncer syncer, void Function() onSent) {
  unawaited(
    syncer
        .flush()
        .then((sent) {
          if (sent > 0) onSent();
        })
        .catchError((Object _) {
          // göndərmə sonra təkrar cəhd olunacaq; ekranda göstərməyə dəyməz
        }),
  );
}

/// Tətbiq açılanda və arxa fondan qayıdanda gözləyən cavabları göndərir.
class AnswerSyncGate extends ConsumerStatefulWidget {
  const AnswerSyncGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AnswerSyncGate> createState() => _AnswerSyncGateState();
}

class _AnswerSyncGateState extends ConsumerState<AnswerSyncGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) flushOfflineAnswersFromWidget(ref);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) flushOfflineAnswersFromWidget(ref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
