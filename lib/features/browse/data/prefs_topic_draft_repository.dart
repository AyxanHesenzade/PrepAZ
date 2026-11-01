import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/app_exception.dart';
import '../domain/topic_draft.dart';

/// Qaralama telefonda SharedPreferences-də, hər istifadəçi üçün ayrıca saxlanır.
class PrefsTopicDraftRepository implements TopicDraftRepository {
  PrefsTopicDraftRepository(this._prefs, this._userId);

  final SharedPreferences _prefs;
  final String? Function() _userId;

  String _key(int topicId) => 'topic_draft.${_userId()}.$topicId';

  @override
  TopicDraft load(int topicId) {
    final raw = _prefs.getString(_key(topicId));
    if (raw == null) return const TopicDraft();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return TopicDraft(
        retake: json['retake'] as bool? ?? false,
        answers: (json['answers'] as Map<String, dynamic>).cast<String, String>(),
      );
    } on FormatException {
      return const TopicDraft();
    } on TypeError {
      return const TopicDraft();
    }
  }

  @override
  Future<void> save(int topicId, TopicDraft draft) => guard(
    () => _prefs.setString(
      _key(topicId),
      jsonEncode({'retake': draft.retake, 'answers': draft.answers}),
    ),
  );

  @override
  Future<void> clear(int topicId) => guard(() => _prefs.remove(_key(topicId)));
}
