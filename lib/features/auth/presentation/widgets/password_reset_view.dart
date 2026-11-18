import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/message_banner.dart';
import '../password_reset_controller.dart';

/// Parol bərpası: e-poçt → məktubdakı kod + yeni parol. Deep link yoxdur, ona görə link yox, kod.
class PasswordResetView extends ConsumerStatefulWidget {
  const PasswordResetView({super.key, this.initialEmail = ''});

  /// Giriş formasında yazılmış e-poçt: təkrar yazdırmırıq.
  final String initialEmail;

  @override
  ConsumerState<PasswordResetView> createState() => _PasswordResetViewState();
}

class _PasswordResetViewState extends ConsumerState<PasswordResetView> {
  final _emailForm = GlobalKey<FormState>();
  final _codeForm = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  PasswordResetController get _controller =>
      ref.read(passwordResetControllerProvider.notifier);

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (!_emailForm.currentState!.validate()) return;
    _controller.sendCode(_email.text.trim());
  }

  void _confirm() {
    if (!_codeForm.currentState!.validate()) return;
    _controller.confirm(code: _code.text, newPassword: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetControllerProvider);
    return FadeSlideIn(
      key: ValueKey(state.step),
      child: state.step == ResetStep.email
          ? _buildEmailStep(state)
          : _buildCodeStep(state),
    );
  }

  Widget _buildEmailStep(PasswordResetState state) {
    return Form(
      key: _emailForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.resetEmailIntro),
          AppSpacing.gapL,
          AppTextField(
            controller: _email,
            label: AppStrings.email,
            hintText: AppStrings.emailExample,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: Validators.email,
            onSubmitted: _sendCode,
          ),
          ..._messages(state),
          AppSpacing.gapL,
          AppButton(
            label: AppStrings.resetSendCodeAction,
            isLoading: state.isBusy,
            onPressed: _sendCode,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep(PasswordResetState state) {
    final text = Theme.of(context).textTheme;
    return Form(
      key: _codeForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.resetCodeSentTo, style: text.bodyMedium),
          AppSpacing.gapXs,
          Text(
            state.email,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.gapS,
          Text(AppStrings.resetCodeHint, style: text.bodySmall),
          AppSpacing.gapL,
          AppTextField(
            controller: _code,
            label: AppStrings.resetCodeLabel,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            textInputAction: TextInputAction.next,
            validator: Validators.resetCode,
          ),
          AppSpacing.gapM,
          AppTextField(
            controller: _password,
            label: AppStrings.newPassword,
            helperText: AppStrings.passwordSignUpHelper(
              Validators.minPasswordLength,
            ),
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              tooltip: _showPassword
                  ? AppStrings.hidePassword
                  : AppStrings.showPassword,
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            autofillHints: const [AutofillHints.newPassword],
            validator: Validators.password,
            onSubmitted: _confirm,
          ),
          ..._messages(state),
          AppSpacing.gapL,
          AppButton(
            label: AppStrings.resetConfirmAction,
            isLoading: state.isBusy,
            onPressed: _confirm,
          ),
          AppSpacing.gapS,
          OutlinedButton(
            onPressed: state.isBusy ? null : _controller.resendCode,
            child: Text(AppStrings.resetResendAction),
          ),
          AppSpacing.gapS,
          TextButton(
            onPressed: state.isBusy ? null : _controller.changeEmail,
            child: Text(AppStrings.resetChangeEmailAction),
          ),
        ],
      ),
    );
  }

  List<Widget> _messages(PasswordResetState state) => [
    if (state.error != null) ...[
      AppSpacing.gapM,
      MessageBanner.error(state.error!),
    ],
    if (state.info != null) ...[AppSpacing.gapM, MessageBanner(state.info!)],
  ];
}
