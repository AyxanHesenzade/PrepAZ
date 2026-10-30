import 'package:flutter/material.dart';

/// Tətbiqin ikonu (assets/icon/icon.png) yumru künclü kvadrat kimi.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  static const asset = 'assets/icon/icon.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        semanticLabel: 'PrepAZ',
        errorBuilder: (_, _, _) => SizedBox(
          width: size,
          height: size,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.school_rounded, color: Theme.of(context).colorScheme.onPrimary, size: size * 0.55),
          ),
        ),
      ),
    );
  }
}
