import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/settings_providers.dart';
import '../domain/tour_step.dart';

final tourControllerProvider = NotifierProvider<TourController, TourStep?>(
  TourController.new,
);

/// null = tur göstərilmir. Bitəndə bayraq telefonda saxlanır və tur bir daha açılmır.
class TourController extends Notifier<TourStep?> {
  @override
  TourStep? build() => null;

  void start() {
    if (state != null || ref.read(settingsControllerProvider).tourSeen) return;
    state = TourStep.values.first;
  }

  /// İstifadəçinin özü istəyəndə: tur əvvəl görülübsə də başdan başlayır.
  void replay() {
    state ??= TourStep.values.first;
  }

  /// [isAvailable] false olan addım atlanır (məs. heç bir fənn yüklənməyib).
  void advance(bool Function(TourStep step) isAvailable) {
    final current = state;
    if (current == null) return;
    for (final step in TourStep.values.skip(current.index + 1)) {
      if (isAvailable(step)) {
        state = step;
        return;
      }
    }
    state = null;
    ref.read(settingsControllerProvider.notifier).setTourSeen();
  }
}
