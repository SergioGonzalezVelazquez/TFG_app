import 'package:flutter_test/flutter_test.dart';
import 'package:tfg_app/utils/validators.dart';

void main() {
  test('Password Validator Test', () {
    expect(Validator.validatePassword(''), PasswordValidationResult.EMPTY_PASSWORD);
    expect(Validator.validatePassword('passw'),
        PasswordValidationResult.TOO_SHORT);
    expect(Validator.validatePassword('validPass'),
        PasswordValidationResult.VALID);
  });
}
