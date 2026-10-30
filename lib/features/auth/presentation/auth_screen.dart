import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/fade_slide_in.dart';
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthHero(
              subtitle: form.isSignUp
                  ? AppStrings.signUpTitle
                  : AppStrings.signInTitle,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: FadeSlideIn(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                            label: form.isSignUp
                                ? AppStrings.signUpAction
                                : AppStrings.signInAction,
                            isLoading: form.isBusy,
                            onPressed: _submit,
                          ),
                          AppSpacing.gapS,
                          TextButton(
                            onPressed: form.isBusy
                                ? null
                                : ref
                                      .read(authControllerProvider.notifier)
                                      .toggleMode,
                            child: Text(
                              form.isSignUp
                                  ? AppStrings.switchToSignIn
                                  : AppStrings.switchToSignUp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Giriş ekranının yuxarısı: gradientli, aşağı tərəfi yumru böyük başlıq.
class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.l,
        MediaQuery.paddingOf(context).top + AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.xl + AppSpacing.m,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandStart, AppColors.brandEnd],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl + 10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(size: 72),
          AppSpacing.gapL,
          Text(
            AppStrings.appName,
            style: text.displaySmall?.copyWith(color: Colors.white),
          ),
          AppSpacing.gapS,
          Text(
            subtitle,
            style: text.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
