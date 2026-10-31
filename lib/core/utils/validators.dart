import '../constants/app_strings.dart';

/// `TextFormField.validator` ilə birbaşa uyğundur: xəta mətni və ya null.
abstract final class Validators {
  static const minPasswordLength = 6;
  static final _emailPattern = RegExp(r'^\S+@\S+\.\S+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    return _emailPattern.hasMatch(v) ? null : AppStrings.invalidEmail;
  }

  static String? password(String? value) {
    return (value ?? '').length >= minPasswordLength
        ? null
        : AppStrings.shortPassword(minPasswordLength);
  }
}
