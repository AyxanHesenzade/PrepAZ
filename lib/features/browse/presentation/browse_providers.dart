import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/in_memory_topic_draft_repository.dart';
import '../data/supabase_browse_repository.dart';
import '../domain/browse_repository.dart';
import '../domain/browse_topic.dart';
import '../domain/topic_draft.dart';

final browseRepositoryProvider = Provider<BrowseRepository>(
  (ref) => SupabaseBrowseRepository(ref.watch(supabaseClientProvider)),
);

/// `main.dart` burada SharedPreferences-li repository verir; testlərdə yaddaşda qalır.
final topicDraftRepositoryProvider = Provider<TopicDraftRepository>(
  (ref) => InMemoryTopicDraftRepository(),
);

final browseTopicsProvider = FutureProvider.autoDispose
    .family<List<BrowseTopic>, int>(
      (ref, subjectId) =>
          ref.watch(browseRepositoryProvider).getTopics(subjectId),
    );
