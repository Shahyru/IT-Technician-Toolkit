import 'dart:math';

class PasswordOptions {
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final bool excludeAmbiguous;

  const PasswordOptions({
    this.length = 16,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeNumbers = true,
    this.includeSymbols = true,
    this.excludeAmbiguous = false,
  });

  PasswordOptions copyWith({
    int? length,
    bool? includeUppercase,
    bool? includeLowercase,
    bool? includeNumbers,
    bool? includeSymbols,
    bool? excludeAmbiguous,
  }) {
    return PasswordOptions(
      length: length ?? this.length,
      includeUppercase: includeUppercase ?? this.includeUppercase,
      includeLowercase: includeLowercase ?? this.includeLowercase,
      includeNumbers: includeNumbers ?? this.includeNumbers,
      includeSymbols: includeSymbols ?? this.includeSymbols,
      excludeAmbiguous: excludeAmbiguous ?? this.excludeAmbiguous,
    );
  }
}

class PasswordGeneratorService {
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  // Ambiguous characters: 0, O, o, 1, l, I, |
  static const String _ambiguous = '0Oo1lI|[]{}()/\'"`~,;:.<>';

  /// Generates a cryptographically secure random password based on options
  static String generate(PasswordOptions options) {
    String upper = _uppercase;
    String lower = _lowercase;
    String num = _numbers;
    String sym = _symbols;

    if (options.excludeAmbiguous) {
      upper = upper.split('').where((c) => !_ambiguous.contains(c)).join();
      lower = lower.split('').where((c) => !_ambiguous.contains(c)).join();
      num = num.split('').where((c) => !_ambiguous.contains(c)).join();
      sym = sym.split('').where((c) => !_ambiguous.contains(c)).join();
    }

    String charPool = '';
    final guaranteedChars = <String>[];
    final rng = Random.secure();

    if (options.includeUppercase && upper.isNotEmpty) {
      charPool += upper;
      guaranteedChars.add(upper[rng.nextInt(upper.length)]);
    }
    if (options.includeLowercase && lower.isNotEmpty) {
      charPool += lower;
      guaranteedChars.add(lower[rng.nextInt(lower.length)]);
    }
    if (options.includeNumbers && num.isNotEmpty) {
      charPool += num;
      guaranteedChars.add(num[rng.nextInt(num.length)]);
    }
    if (options.includeSymbols && sym.isNotEmpty) {
      charPool += sym;
      guaranteedChars.add(sym[rng.nextInt(sym.length)]);
    }

    if (charPool.isEmpty) {
      throw const FormatException('At least one character set must be selected');
    }

    final result = <String>[...guaranteedChars];
    final remaining = options.length - result.length;

    for (int i = 0; i < remaining; i++) {
      result.add(charPool[rng.nextInt(charPool.length)]);
    }

    // Shuffle characters securely using Fisher-Yates
    for (int i = result.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }

    return result.take(options.length).join();
  }

  /// Calculates Shannon entropy in bits
  static double calculateEntropy(String password, PasswordOptions options) {
    int poolSize = 0;
    if (options.includeUppercase) poolSize += 26;
    if (options.includeLowercase) poolSize += 26;
    if (options.includeNumbers) poolSize += 10;
    if (options.includeSymbols) poolSize += 28;

    if (poolSize <= 0) poolSize = 26;
    return password.length * (log(poolSize) / log(2));
  }

  /// Returns textual strength rating
  static String evaluateStrength(double entropyBits) {
    if (entropyBits < 36) return 'Very Weak';
    if (entropyBits < 50) return 'Weak';
    if (entropyBits < 65) return 'Moderate';
    if (entropyBits < 80) return 'Strong';
    return 'Very Strong';
  }
}
