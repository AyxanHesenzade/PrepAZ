import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_language.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/pressable.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/widgets/delete_account_dialog.dart';
import '../../legal/presentation/legal_screen.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../reports/presentation/report_sheet.dart';
import '../../teachers/presentation/teachers_screen.dart';
import '../../tour/presentation/tour_targets.dart';

/// Yan menyu: dil, görünüş (gündüz/gecə), tövsiyə olunan müəllimlər və çıxış.
/// Dil və görünüş bölmələrinə basanda açılır.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final tour = TourScope.maybeOf(context);
    final scheme = Theme.of(context).colorScheme;

    final themeLabels = {
      AppThemeMode.light: AppStrings.themeLight,
      AppThemeMode.dark: AppStrings.themeDark,
      AppThemeMode.system: AppStrings.themeSystem,
    };
    final themeIcons = {
      AppThemeMode.light: Icons.light_mode_rounded,
      AppThemeMode.dark: Icons.dark_mode_rounded,
      AppThemeMode.system: Icons.brightness_auto_rounded,
    };

    return Drawer(
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          const _DrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                _ExpandableSection(
                  key: tour?.language,
                  icon: Icons.translate_rounded,
                  title: AppStrings.languageTitle,
                  value: settings.language.nativeName,
                  child: _Choices<AppLanguage>(
                    values: AppLanguage.values,
                    selected: settings.language,
                    labelOf: (l) => l.nativeName,
                    onSelected: controller.setLanguage,
                  ),
                ),
                _ExpandableSection(
                  key: tour?.appearance,
                  icon: Icons.contrast_rounded,
                  title: AppStrings.appearance,
                  value: themeLabels[settings.themeMode]!,
                  child: _Choices<AppThemeMode>(
                    values: const [AppThemeMode.light, AppThemeMode.dark, AppThemeMode.system],
                    selected: settings.themeMode,
                    labelOf: (m) => themeLabels[m]!,
                    iconOf: (m) => themeIcons[m]!,
                    onSelected: controller.setThemeMode,
                  ),
                ),
                _NavTile(
                  key: tour?.teachers,
                  icon: Icons.workspace_premium_rounded,
                  title: AppStrings.teachersTitle,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TeachersScreen()));
                  },
                ),
                _NavTile(
                  key: tour?.report,
                  icon: Icons.bug_report_outlined,
                  title: AppStrings.reportAppTitle,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    final root = navigator.context;
                    navigator.pop();
                    showReportSheet(root);
                  },
                ),
                _NavTile(
                  key: tour?.legal,
                  icon: Icons.gavel_rounded,
                  title: AppStrings.legalMenuTitle,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LegalScreen()));
                  },
                ),
                _NavTile(
                  key: tour?.deleteAccount,
                  icon: Icons.delete_outline_rounded,
                  title: AppStrings.deleteAccount,
                  color: scheme.error,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    final root = navigator.context;
                    navigator.pop();
                    showDeleteAccountDialog(root);
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: _NavTile(
                key: tour?.signOut,
                icon: Icons.logout_rounded,
                title: AppStrings.signOut,
                color: scheme.error,
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authRepositoryProvider).signOut();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(AppSpacing.l, MediaQuery.paddingOf(context).top + AppSpacing.l, AppSpacing.l, AppSpacing.l),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandStart, AppColors.brandEnd],
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(AppRadius.xl)),
      ),
      child: Row(
        children: [
          const AppLogo(size: 52),
          AppSpacing.gapM,
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Basanda aşağı açılan bölmə: bağlı olanda cari dəyəri göstərir.
class _ExpandableSection extends StatefulWidget {
  const _ExpandableSection({super.key, required this.icon, required this.title, required this.value, required this.child});

  final IconData icon;
  final String title;
  final String value;
  final Widget child;

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s + 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: Column(
        children: [
          Pressable(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  _IconBubble(icon: widget.icon),
                  AppSpacing.gapM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: text.titleSmall),
                        Text(widget.value, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.expand_more_rounded, color: scheme.outline),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.m),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Choices<T> extends StatelessWidget {
  const _Choices({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.iconOf,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final value in values)
          Pressable(
            onTap: () => onSelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s + 3),
              decoration: BoxDecoration(
                color: value == selected ? scheme.primary : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconOf != null) ...[
                    Icon(iconOf!(value), size: 18, color: value == selected ? scheme.onPrimary : scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    labelOf(value),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: value == selected ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({super.key, required this.icon, required this.title, required this.onTap, this.color});

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = color ?? scheme.primary;
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s + 2),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        child: Row(
          children: [
            _IconBubble(icon: icon, color: tint),
            AppSpacing.gapM,
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.s + 2)),
      child: Icon(icon, size: 22, color: tint),
    );
  }
}
