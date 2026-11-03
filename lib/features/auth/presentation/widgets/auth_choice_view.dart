import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/message_banner.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../legal/presentation/widgets/google_consent_note.dart';

/// İlk ekran: istifadəçi formanı görməzdən əvvəl yeni olub-olmadığını seçir.
class AuthChoiceView extends StatelessWidget {
  const AuthChoiceView({
    super.key,
    required this.onNewUser,
    required this.onExistingUser,
    required this.onGoogle,
    this.isBusy = false,
    this.error,
  });

  final VoidCallback onNewUser;
  final VoidCallback onExistingUser;
  final VoidCallback onGoogle;
  final bool isBusy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.choiceQuestion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          AppSpacing.gapL,
          _ChoiceCard(
            icon: Icons.person_add_alt_1_rounded,
            title: AppStrings.choiceNewTitle,
            subtitle: AppStrings.choiceNewSubtitle,
            highlighted: true,
            onTap: onNewUser,
          ),
          AppSpacing.gapM,
          _ChoiceCard(
            icon: Icons.login_rounded,
            title: AppStrings.choiceExistingTitle,
            subtitle: AppStrings.choiceExistingSubtitle,
            highlighted: false,
            onTap: onExistingUser,
          ),
          AppSpacing.gapL,
          _OrDivider(),
          AppSpacing.gapL,
          OutlinedButton.icon(
            onPressed: isBusy ? null : onGoogle,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: isBusy
                ? const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const _GoogleMark(),
            label: Text(AppStrings.googleContinue),
          ),
          AppSpacing.gapS,
          const GoogleConsentNote(),
          if (error != null) ...[AppSpacing.gapM, MessageBanner.error(error!)],
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(AppStrings.orDivider),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Rəsmi loqo faylı əlavə etməmək üçün sadə "G" işarəsi.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4285F4),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final background = highlighted
        ? scheme.primary
        : scheme.surfaceContainerLowest;
    final foreground = highlighted ? scheme.onPrimary : scheme.onSurface;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: highlighted
              ? null
              : Border.all(color: scheme.primary, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 34,
              color: highlighted ? scheme.onPrimary : scheme.primary,
            ),
            AppSpacing.gapM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.titleLarge?.copyWith(color: foreground),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    subtitle,
                    style: text.bodyMedium?.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: foreground),
          ],
        ),
      ),
    );
  }
}
