import '../domain/topic_draft.dart';

/// Yaddaşda saxlayır (testlər və `main.dart`-ın override etmədiyi hallar üçün).
class InMemoryTopicDraftRepository implements TopicDraftRepository {
  final drafts = <int, TopicDraft>{};

  @override
  TopicDraft load(int topicId) => drafts[topicId] ?? const TopicDraft();

  @override
  Future<void> save(int topicId, TopicDraft draft) async => drafts[topicId] = draft;

  @override
  Future<void> clear(int topicId) async => drafts.remove(topicId);
}
