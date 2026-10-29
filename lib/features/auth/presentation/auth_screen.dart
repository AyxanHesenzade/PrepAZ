import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/message_banner.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authControllerProvider.notifier)
        .submit(email: _email.text.trim(), password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(AppStrings.appName, style: textTheme.headlineMedium, textAlign: TextAlign.center),
                    AppSpacing.gapS,
                    Text(
                      form.isSignUp ? AppStrings.signUpTitle : AppStrings.signInTitle,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapXl,
                    AppTextField(
                      controller: _email,
                      label: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    AppSpacing.gapM,
                    AppTextField(
                      controller: _password,
                      label: AppStrings.password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      validator: Validators.password,
                      onSubmitted: _submit,
                    ),
                    if (form.error != null) ...[AppSpacing.gapM, MessageBanner.error(form.error!)],
                    if (form.info != null) ...[AppSpacing.gapM, MessageBanner(form.info!)],
                    AppSpacing.gapL,
                    AppButton(
                      label: form.isSignUp ? AppStrings.signUpAction : AppStrings.signInAction,
                      isLoading: form.isBusy,
                      onPressed: _submit,
                    ),
                    AppSpacing.gapS,
                    TextButton(
                      onPressed: form.isBusy
                          ? null
                          : ref.read(authControllerProvider.notifier).toggleMode,
                      child: Text(form.isSignUp ? AppStrings.switchToSignIn : AppStrings.switchToSignUp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
