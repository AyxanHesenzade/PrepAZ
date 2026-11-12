import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/leaderboard.dart';
import '../../domain/leaderboard_repository.dart';
import '../leaderboard_providers.dart';

/// Nik-ad, ad və soyad. İlk qoşulmada da, sonra dəyişəndə də eyni forma.
class PlayerForm extends ConsumerStatefulWidget {
  const PlayerForm({
    super.key,
    this.initial,
    required this.actionLabel,
    required this.onSaved,
  });

  final Player? initial;
  final String actionLabel;
  final VoidCallback onSaved;

  @override
  ConsumerState<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends ConsumerState<PlayerForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nickname = TextEditingController(text: widget.initial?.nickname);
  late final _firstName = TextEditingController(text: widget.initial?.firstName);
  late final _lastName = TextEditingController(text: widget.initial?.lastName);
  bool _saving = false;
  String? _nicknameError;
  String? _error;

  @override
  void dispose() {
    _nickname.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _nicknameError = null;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(leaderboardRepositoryProvider).savePlayer(
        Player(
          nickname: _nickname.text.trim(),
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
        ),
      );
      if (mounted) widget.onSaved();
    } on NicknameTakenException catch (e) {
      if (!mounted) return;
      // xəta nik-ad xanasının altında görünsün
      _nicknameError = e.message;
      _formKey.currentState!.validate();
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _nickname,
            label: AppStrings.nicknameLabel,
            helperText: AppStrings.nicknameHelper,
            validator: (v) => Validators.nickname(v) ?? _nicknameError,
            textInputAction: TextInputAction.next,
            suffixIcon: const Icon(Icons.alternate_email_rounded),
          ),
          AppSpacing.gapM,
          AppTextField(
            controller: _firstName,
            label: AppStrings.firstNameLabel,
            validator: Validators.personName,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
          ),
          AppSpacing.gapM,
          AppTextField(
            controller: _lastName,
            label: AppStrings.lastNameLabel,
            validator: Validators.personName,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.familyName],
            onSubmitted: _save,
          ),
          if (_error != null) ...[
            AppSpacing.gapM,
            Text(
              _error!,
              style: TextStyle(color: scheme.error),
            ),
          ],
          AppSpacing.gapL,
          AppButton(
            label: widget.actionLabel,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
