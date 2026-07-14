/// Password strength validation for enterprise auth.
abstract final class PasswordValidator {
  static const int minLength = 10;

  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'password_required';
    }
    if (password.length < minLength) {
      return 'password_too_short';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'password_missing_uppercase';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'password_missing_lowercase';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'password_missing_digit';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'))) {
      return 'password_missing_special';
    }
    return null;
  }

  static double strengthScore(String password) {
    var score = 0.0;
    if (password.length >= minLength) score += 0.2;
    if (password.length >= 14) score += 0.1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) score += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }
}
