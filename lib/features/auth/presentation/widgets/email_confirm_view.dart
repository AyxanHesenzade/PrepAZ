import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/message_banner.dart';
import '../auth_controller.dart';
import 'numbered_steps.dart';

/// Qeydiyyatdan sonrakı gözləmə: nə edəcəyini addım-addım deyir və
/// istifadəçi tətbiqə qayıdanda təsdiqi özü yoxlayır.
class EmailConfirmView extends ConsumerStatefulWidget {
  const EmailConfirmView({super.key});

  @override
  ConsumerState<EmailConfirmView> createState() => _EmailConfirmViewState();
}

class _EmailConfirmViewState extends ConsumerState<EmailConfirmView> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref
          .read(authControllerProvider.notifier)
          .checkConfirmedSilently(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final text = Theme.of(context).textTheme;

    return FadeSlideIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.confirmHeadline, style: text.titleLarge),
          AppSpacing.gapS,
          Text(AppStrings.confirmSentTo, style: text.bodyMedium),
          AppSpacing.gapXs,
          Text(
            form.pendingEmail ?? '',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.gapL,
          NumberedSteps(
            steps: [
              AppStrings.confirmStepOpen,
              AppStrings.confirmStepTap,
              AppStrings.confirmStepReturn,
            ],
          ),
          if (form.error != null) ...[
            AppSpacing.gapM,
            MessageBanner.error(form.error!),
          ],
          if (form.info != null) ...[
            AppSpacing.gapM,
            MessageBanner(form.info!),
          ],
          AppSpacing.gapL,
          AppButton(
            label: AppStrings.confirmCheckAction,
            isLoading: form.isBusy,
            onPressed: controller.checkConfirmed,
          ),
          AppSpacing.gapS,
          OutlinedButton(
            onPressed: form.isBusy ? null : controller.resendConfirmation,
            child: Text(AppStrings.confirmResendAction),
          ),
          AppSpacing.gapS,
          TextButton(
            onPressed: form.isBusy ? null : controller.cancelConfirmation,
            child: Text(AppStrings.confirmBackAction),
          ),
        ],
      ),
    );
  }
}
