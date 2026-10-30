import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_version.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/message_banner.dart';
import '../../quiz/domain/question.dart';
import '../domain/report_repository.dart';
import 'report_providers.dart';

/// Problem bildirişi pəncərəsi. [question] verilibsə sualdakı xəta, yoxsa tətbiqdəki xəta bildirilir.
/// Açıqlama məcburidir: boş və ya çox qısa mətnlə göndərmək olmur.
Future<void> showReportSheet(BuildContext context, {Question? question}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ReportSheet(question: question),
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({this.question});

  final Question? question;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final version = await ref.read(appVersionProvider.future);
      final question = widget.question;
      await ref.read(reportRepositoryProvider).submit(
            message: _controller.text,
            appVersion: '${version.version}+${version.build}',
            questionId: question?.id,
            questionCode: question?.reportCode,
          );
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(AppStrings.reportSent)));
    } catch (error) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = errorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final valid = ReportRules.isValid(_controller.text);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.m + 4, 0, AppSpacing.m + 4, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.m),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question == null ? AppStrings.reportAppTitle : AppStrings.reportQuestionTitle, style: text.titleLarge),
            AppSpacing.gapXs,
            Text(
              question == null ? AppStrings.reportAppHint : AppStrings.reportQuestionHint(question.reportCode),
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            AppSpacing.gapM,
            TextField(
              controller: _controller,
              enabled: !_sending,
              maxLines: 5,
              minLines: 3,
              maxLength: ReportRules.maxLength,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: AppStrings.reportDescription,
                helperText: valid ? null : AppStrings.reportMinHint(ReportRules.minLength),
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              AppSpacing.gapS,
              MessageBanner.error(_error!),
            ],
            AppSpacing.gapM,
            AppButton(label: AppStrings.reportSend, isLoading: _sending, onPressed: valid ? _send : null),
          ],
        ),
      ),
    );
  }
}
