import '../constants/app_strings.dart';

/// `TextFormField.validator` ilə birbaşa uyğundur: xəta mətni və ya null.
abstract final class Validators {
  static const minPasswordLength = 6;

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    return v.contains('@') && v.length > 2 ? null : AppStrings.invalidEmail;
  }

  static String? password(String? value) {
    return (value ?? '').length >= minPasswordLength
        ? null
        : AppStrings.shortPassword(minPasswordLength);
  }
}
