import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/password_generator_service.dart';

void main() {
  group('PasswordGeneratorService Tests', () {
    test('Generates password of exact requested length', () {
      const options = PasswordOptions(length: 24);
      final pwd = PasswordGeneratorService.generate(options);

      expect(pwd.length, 24);
    });

    test('Includes uppercase, lowercase, numbers, and symbols when requested', () {
      const options = PasswordOptions(
        length: 32,
        includeUppercase: true,
        includeLowercase: true,
        includeNumbers: true,
        includeSymbols: true,
      );
      final pwd = PasswordGeneratorService.generate(options);

      expect(pwd.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pwd.contains(RegExp(r'[a-z]')), isTrue);
      expect(pwd.contains(RegExp(r'[0-9]')), isTrue);
      expect(pwd.contains(RegExp(r'[!@#\$%^&*()-_=+[\]{}|;:,.<>?]')), isTrue);
    });

    test('Excludes ambiguous characters when toggle is active', () {
      const options = PasswordOptions(
        length: 50,
        excludeAmbiguous: true,
      );
      final pwd = PasswordGeneratorService.generate(options);

      // Ambiguous characters: 0, O, o, 1, l, I, |
      expect(pwd.contains(RegExp(r'[0Oo1lI|]')), isFalse);
    });

    test('Calculates entropy and evaluates strength', () {
      const options = PasswordOptions(length: 16);
      final pwd = PasswordGeneratorService.generate(options);
      final entropy = PasswordGeneratorService.calculateEntropy(pwd, options);
      final strength = PasswordGeneratorService.evaluateStrength(entropy);

      expect(entropy, greaterThan(80)); // 16 * log2(90) ~ 103 bits
      expect(strength, 'Very Strong');
    });
  });
}
