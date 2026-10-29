import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum MessageKind { error, info }

/// Xəta və ya məlumat mətni. Hər ekranda təkrar yazılmasın deyə ortaqdır.
class MessageBanner extends StatelessWidget {
  const MessageBanner(this.message, {super.key, this.kind = MessageKind.info});

  const MessageBanner.error(this.message, {super.key}) : kind = MessageKind.error;

  final String message;
  final MessageKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isError = kind == MessageKind.error;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isError ? scheme.errorContainer : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: isError ? scheme.onErrorContainer : scheme.onSecondaryContainer),
      ),
    );
  }
}
