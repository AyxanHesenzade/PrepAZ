import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../home/domain/subject.dart';
import '../domain/browse_topic.dart';
import '../domain/search_fold.dart';
import 'browse_providers.dart';
import 'topic_questions_screen.dart';

/// Fənnin mövzuları. Cavablar yazılmır, yalnız sualları ardıcıl həll etmək üçündür.
class TopicListScreen extends ConsumerStatefulWidget {
  const TopicListScreen({super.key, required this.subject});

  final Subject subject;

  @override
  ConsumerState<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends ConsumerState<TopicListScreen> {
  final _search = TextEditingController();
  String _query = '';

  Subject get subject => widget.subject;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = browseTopicsProvider(subject.id);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.topicsTitle)),
      body: SafeArea(
        child: AsyncValueView<List<BrowseTopic>>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          builder: (topics) {
            final shown = topics
                .where((t) => foldForSearch(t.name).contains(_query))
                .toList();
            if (topics.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(
                    AppStrings.noQuestionsInTopic,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m,
                    AppSpacing.m,
                    AppSpacing.m,
                    0,
                  ),
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = foldForSearch(v)),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchTopics,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: AppSpacing.pagePadding,
                    children: [
                      Text(
                        AppStrings.topicsHint,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      AppSpacing.gapM,
                      if (shown.isEmpty)
                        Text(
                          AppStrings.noTopicsFound,
                          textAlign: TextAlign.center,
                        ),
                      for (final topic in shown)
                        Card(
                          child: ListTile(
                            title: Text(topic.name),
                            subtitle: Text(
                              AppStrings.questionCount(topic.questionCount),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: scheme.outline,
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    TopicQuestionsScreen(topic: topic),
                              ),
                            ),
                          ),
                        ),
                    ],
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
