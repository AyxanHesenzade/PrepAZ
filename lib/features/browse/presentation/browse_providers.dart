import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../quiz/domain/question.dart';
import '../data/supabase_browse_repository.dart';
import '../domain/browse_repository.dart';
import '../domain/browse_topic.dart';

final browseRepositoryProvider = Provider<BrowseRepository>(
  (ref) => SupabaseBrowseRepository(ref.watch(supabaseClientProvider)),
);

final browseTopicsProvider = FutureProvider.autoDispose
    .family<List<BrowseTopic>, int>(
      (ref, subjectId) =>
          ref.watch(browseRepositoryProvider).getTopics(subjectId),
    );

final browseQuestionsProvider = FutureProvider.autoDispose
    .family<List<Question>, int>(
      (ref, topicId) =>
          ref.watch(browseRepositoryProvider).getTopicQuestions(topicId),
    );
