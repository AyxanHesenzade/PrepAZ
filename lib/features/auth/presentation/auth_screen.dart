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
import 'widgets/auth_choice_view.dart';
import 'widgets/email_confirm_view.dart';
import 'widgets/numbered_steps.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

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

  AuthController get _controller => ref.read(authControllerProvider.notifier);

  String _subtitle(AuthFormState form) {
    if (form.awaitingConfirmation) return AppStrings.confirmTitle;
    return switch (form.mode) {
      AuthMode.choose => AppStrings.choiceTitle,
      AuthMode.signIn => AppStrings.signInTitle,
      AuthMode.signUp => AppStrings.signUpTitle,
    };
  }

  /// Forma ekranından seçim ekranına qayıdış. Yazılmış e-poçt silinmir.
  void _backToChoice() => _controller.setMode(AuthMode.choose);

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(authControllerProvider);
    final onForm = !form.awaitingConfirmation && !form.isChoosing;

    return PopScope(
      canPop: !onForm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !form.isBusy) _backToChoice();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuthHero(
                subtitle: _subtitle(form),
                onBack: onForm && !form.isBusy ? _backToChoice : null,
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: _buildBody(form),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AuthFormState form) {
    if (form.awaitingConfirmation) return const EmailConfirmView();
    if (form.isChoosing) {
      return AuthChoiceView(
        onNewUser: () => _controller.setMode(AuthMode.signUp),
        onExistingUser: () => _controller.setMode(AuthMode.signIn),
      );
    }
    return _buildForm(form);
  }

  Widget _buildForm(AuthFormState form) {
    return FadeSlideIn(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (form.isSignUp)
              _AuthGuide(
                title: AppStrings.signUpGuideTitle,
                steps: [
                  AppStrings.signUpGuideForm,
                  AppStrings.signUpGuideLink,
                  AppStrings.signUpGuideReturn,
                ],
              )
            else
              _AuthGuide(
                title: AppStrings.signInGuideTitle,
                steps: [AppStrings.signInGuideForm, AppStrings.signInGuideTap],
                note: AppStrings.signInGuideNewUser,
              ),
            AppSpacing.gapL,
            AppTextField(
              controller: _email,
              label: AppStrings.email,
              hintText: AppStrings.emailExample,
              helperText: form.isSignUp
                  ? AppStrings.emailSignUpHelper
                  : AppStrings.emailSignInHelper,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            AppSpacing.gapM,
            AppTextField(
              controller: _password,
              label: AppStrings.password,
              helperText: form.isSignUp
                  ? AppStrings.passwordSignUpHelper(Validators.minPasswordLength)
                  : AppStrings.passwordSignInHelper,
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
                onPressed: () =>
                    setState(() => _showPassword = !_showPassword),
              ),
              autofillHints: [
                form.isSignUp
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
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
                  : () => _controller.setMode(
                      form.isSignUp ? AuthMode.signIn : AuthMode.signUp,
                    ),
              child: Text(
                form.isSignUp
                    ? AppStrings.switchToSignIn
                    : AppStrings.switchToSignUp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nə ediləcəyini formadan əvvəl göstərir: heç kim nəyə basacağını düşünməsin.
class _AuthGuide extends StatelessWidget {
  const _AuthGuide({required this.title, required this.steps, this.note});

  final String title;
  final List<String> steps;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapS,
          NumberedSteps(steps: steps),
          if (note != null) ...[
            AppSpacing.gapM,
            Text(
              note!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

/// Giriş ekranının yuxarısı: gradientli, aşağı tərəfi yumru, forma üçün yer saxlayan başlıq.
class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.subtitle, this.onBack});

  final String subtitle;

  /// Doludursa, solda geri düyməsi görünür.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.l,
        MediaQuery.paddingOf(context).top + AppSpacing.m,
        AppSpacing.l,
        AppSpacing.l,
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
          Row(
            children: [
              if (onBack != null) ...[
                IconButton(
                  tooltip: AppStrings.back,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBack,
                ),
                AppSpacing.gapS,
              ],
              const AppLogo(size: 48),
              AppSpacing.gapM,
              Text(
                AppStrings.appName,
                style: text.headlineMedium?.copyWith(color: Colors.white),
              ),
            ],
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
