import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.key,
  });

  /// Düymənin özünə taxılır (məs. öyrədici tur onu tapsın).
  final Key? key;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Ekranın üstündə üzən "şüşə" alt menyu (iOS liquid glass üslubu):
/// arxa fon bulanıqlaşır, panel yarımşəffafdır, seçilmiş düymənin işıqlı fonu yumşaq sürüşür.
/// Animasiyalar yalnız seçim dəyişəndə işləyir (sonsuz animasiya yoxdur).
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _height = 66.0;
  static const _duration = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final count = items.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl + 8,
        0,
        AppSpacing.xl + 8,
        (bottom > 0 ? bottom : AppSpacing.m) + 4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: _height,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                // yuxarıdan düşən işıq: şüşənin parıltısı
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: dark
                      ? [
                          Colors.white.withValues(alpha: 0.16),
                          Colors.white.withValues(alpha: 0.06),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.82),
                          Colors.white.withValues(alpha: 0.55),
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: dark ? 0.18 : 0.7),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  final itemWidth = box.maxWidth / count;
                  return Stack(
                    children: [
                      // seçilmiş düymənin arxasındakı "damcı"
                      AnimatedPositioned(
                        duration: _duration,
                        curve: Curves.easeOutBack,
                        left: itemWidth * selectedIndex,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                scheme.primary.withValues(alpha: 0.22),
                                scheme.primary.withValues(alpha: 0.12),
                              ],
                            ),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (final (i, item) in items.indexed)
                            Expanded(
                              child: _Item(
                                key: item.key,
                                item: item,
                                selected: i == selectedIndex,
                                onTap: () {
                                  if (i == selectedIndex) return;
                                  HapticFeedback.selectionClick();
                                  onSelected(i);
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.6);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              duration: GlassNavBar._duration,
              curve: Curves.easeOutBack,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: GlassNavBar._duration,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
