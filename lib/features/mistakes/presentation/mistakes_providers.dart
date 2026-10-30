import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quiz/domain/mistake_item.dart';
import '../../quiz/presentation/quiz_providers.dart';

/// Fənn üzrə səhvlər dəftəri. Şəkillər söndürülübsə suallar şəkilsiz qayıdır.
final mistakesProvider = FutureProvider.autoDispose.family<List<MistakeItem>, int>((ref, subjectId) async {
  final items = await ref.watch(quizRepositoryProvider).getMistakes(subjectId);
  if (ref.watch(imagesEnabledProvider)) return items;
  return [
    for (final item in items)
      MistakeItem(question: item.question.withoutImages(), dueAt: item.dueAt, intervalDays: item.intervalDays),
  ];
});
