import '../constants/app_strings.dart';

/// `TextFormField.validator` ilə birbaşa uyğundur: xəta mətni və ya null.
abstract final class Validators {
  static const minPasswordLength = 6;
  static final _emailPattern = RegExp(r'^\S+@\S+\.\S+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    return _emailPattern.hasMatch(v) ? null : AppStrings.invalidEmail;
  }

  /// `leaderboard_players.nickname` yoxlaması ilə eynidir (db/migrations/017_leaderboard.sql).
  static final _nicknamePattern = RegExp(r'^[A-Za-z0-9_.ƏəÜüÖöĞğİıŞşÇç]{3,20}$');

  static String? nickname(String? value) {
    return _nicknamePattern.hasMatch(value?.trim() ?? '')
        ? null
        : AppStrings.nicknameInvalid;
  }

  static String? personName(String? value) {
    final length = value?.trim().length ?? 0;
    return length >= 2 && length <= 40 ? null : AppStrings.personNameInvalid;
  }

  static String? password(String? value) {
    return (value ?? '').length >= minPasswordLength
        ? null
        : AppStrings.shortPassword(minPasswordLength);
  }
}
