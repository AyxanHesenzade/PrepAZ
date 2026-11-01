import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/app_exception.dart';
import '../auth_providers.dart';

Future<void> showDeleteAccountDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const DeleteAccountDialog());

/// Silmədən əvvəl son təsdiq. Uğurlu olanda AuthGate giriş ekranına keçir.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(AppStrings.deleteAccountQuestion),
      content: Text(_error ?? AppStrings.deleteAccountWarning, style: TextStyle(color: _error == null ? null : scheme.error)),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: _busy ? null : _delete,
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          child: Text(AppStrings.deleteAccountConfirm),
        ),
      ],
    );
  }
}
