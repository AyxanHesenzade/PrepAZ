import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../browse/domain/browse_topic.dart';
import '../../browse/presentation/topic_questions_screen.dart';
import '../../home/domain/subject.dart';
import '../domain/offline_models.dart';
import 'offline_providers.dart';

/// Fənnin yüklənmiş mövzuları. Mövzuya basanda testlər açılır və internetsiz işləyir.
class DownloadedTopicsScreen extends ConsumerWidget {
  const DownloadedTopicsScreen({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: SafeArea(
        child: AsyncValueView<List<DownloadedSubject>>(
          value: ref.watch(downloadedSubjectsProvider),
          onRetry: () => ref.invalidate(downloadedSubjectsProvider),
          builder: (all) {
            final topics = <StoredTopic>[
              for (final s in all)
                if (s.subject.id == subject.id) ...s.topics,
            ];
            if (topics.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(AppStrings.downloadedEmpty, textAlign: TextAlign.center),
                ),
              );
            }
            return ListView(
              padding: AppSpacing.pagePadding,
              children: [
                for (final topic in topics)
                  Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded, color: accent, size: 22),
                      ),
                      title: Text(topic.topicName),
                      subtitle: Text(
                        [
                          if (topic.sectionName != null) topic.sectionName!,
                          AppStrings.questionCount(topic.questionCount),
                        ].join(' · '),
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: scheme.outline),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TopicQuestionsScreen(
                            subjectId: subject.id,
                            topic: BrowseTopic(
                              id: topic.topicId,
                              name: topic.topicName,
                              questionCount: topic.questionCount,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
