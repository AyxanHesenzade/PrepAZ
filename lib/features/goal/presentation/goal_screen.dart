import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../domain/exam_goal.dart';
import 'goal_providers.dart';

/// İmtahan dövrünü (və ya öz tarixini) və gündəlik hədəfi seçmək ekranı.
/// [firstTime] olanda başlıq "imtahanına nə qədər qalıb?" olur.
class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key, this.firstTime = false});

  final bool firstTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periods = ref.watch(examPeriodsProvider);
    final goal = ref.watch(userGoalProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.goalTitle)),
      body: SafeArea(
        child: AsyncValueView<List<ExamPeriod>>(
          value: periods,
          onRetry: () => ref.invalidate(examPeriodsProvider),
          builder: (list) => AsyncValueView<UserGoal?>(
            value: goal,
            onRetry: () => ref.invalidate(userGoalProvider),
            builder: (current) => _GoalForm(
              periods: list,
              initial: current ?? const UserGoal(),
              firstTime: firstTime,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({
    required this.periods,
    required this.initial,
    required this.firstTime,
  });

  final List<ExamPeriod> periods;
  final UserGoal initial;
  final bool firstTime;

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  late int? _periodId = widget.initial.periodId;
  late DateTime? _custom = widget.initial.customDate;
  late int _daily = widget.initial.dailyGoal;
  bool _saving = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _custom ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _custom = picked;
        _periodId = null;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(goalRepositoryProvider)
          .saveGoal(
            UserGoal(
              periodId: _periodId,
              customDate: _custom,
              dailyGoal: _daily,
            ),
          );
      ref.invalidate(userGoalProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is AppException ? error.message : AppStrings.goalSaveFailed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        if (widget.firstTime) ...[
          Text(AppStrings.goalPromptTitle, style: text.headlineSmall),
          AppSpacing.gapS,
          Text(
            AppStrings.goalPromptText,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          AppSpacing.gapL,
        ],
        Text(AppStrings.goalPeriod, style: text.titleMedium),
        AppSpacing.gapS,
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final p in widget.periods)
              ChoiceChip(
                label: Text(
                  '${AppStrings.periodName(p.code, p.name)} · ${_format(p.examDate)}',
                ),
                selected: _periodId == p.id && _custom == null,
                onSelected: (_) => setState(() {
                  _periodId = p.id;
                  _custom = null;
                }),
              ),
            ChoiceChip(
              avatar: const Icon(Icons.event_rounded, size: 18),
              label: Text(
                _custom == null
                    ? AppStrings.goalCustomDate
                    : '${AppStrings.goalCustomDate} · ${_format(_custom!)}',
              ),
              selected: _custom != null,
              onSelected: (_) => _pickDate(),
            ),
          ],
        ),
        AppSpacing.gapL,
        Text(AppStrings.goalDaily, style: text.titleMedium),
        AppSpacing.gapS,
        Wrap(
          spacing: AppSpacing.s,
          children: [
            for (final n in UserGoal.dailyGoalOptions)
              ChoiceChip(
                label: Text('$n'),
                selected: _daily == n,
                onSelected: (_) => setState(() => _daily = n),
              ),
          ],
        ),
        AppSpacing.gapXl,
        AppButton(
          label: AppStrings.goalSave,
          isLoading: _saving,
          onPressed: _save,
        ),
        if (widget.firstTime) ...[
          AppSpacing.gapS,
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: Text(AppStrings.goalLater),
          ),
        ],
      ],
    );
  }

  static String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
