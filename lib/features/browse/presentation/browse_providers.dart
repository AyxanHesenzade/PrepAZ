import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../offline/data/offline_browse_repository.dart';
import '../../offline/presentation/offline_providers.dart';
import '../data/in_memory_topic_draft_repository.dart';
import '../data/supabase_browse_repository.dart';
import '../domain/browse_repository.dart';
import '../domain/browse_topic.dart';
import '../domain/topic_draft.dart';

/// Yüklənmiş mövzular telefondan, qalanı serverdən oxunur (bax `OfflineBrowseRepository`).
final browseRepositoryProvider = Provider<BrowseRepository>(
  (ref) => OfflineBrowseRepository(
    remote: SupabaseBrowseRepository(ref.watch(supabaseClientProvider)),
    store: ref.watch(offlineStoreProvider),
    outbox: ref.watch(answerOutboxProvider),
  ),
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
