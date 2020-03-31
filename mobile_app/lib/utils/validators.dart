import 'package:validators/validators.dart';
import 'package:password_strength/password_strength.dart';

/// Combine custom functions and String validation
/// from https://pub.dev/packages/validators package
class Validator {
  /// validates if the string is an email in form
  static String email(val) {
    if (val.isEmpty || !isEmail(val))
      return "Introduce una dirección de correo electrónico válida";
    return null;
  }

  /// validates if the string is an email in form
  static String username(val) {
    if (val.trim().isEmpty) return "Introduce tu nombre y apellidos";
    return null;
  }

  static String passwordPresent(val) {
    if (val.trim().isEmpty) return "Introduce tu contraseña";
    return null;
  }

  /// Returns false when using a weak password (less than 6 chars),
  /// with no spaces
  static String validPassword(password) {
    if (password.replaceAll(' ', '').length < 6)
      return "Tu contraseña debe tener al menos 6 caracteres";
    return null;
  }

  static String confirmPassword(String password, passwordConfirm) {
    if (passwordConfirm.trim().isEmpty) return "Confirma tu contraseña";
    if (passwordConfirm != password) return "Las contraseñas no coinciden";
    return null;
  }

  /// Password strength estimator for Dart. Considers the length
  /// of the password, used characters, and whether or not the
  /// password appears in the top 10,000 most used passwords.
  /// https://pub.dev/packages/password_strength
  static double passwordStrength(String password) {
    return estimatePasswordStrength(password);
  }
}
