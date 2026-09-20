import 'package:flutter/material.dart';
import '../../../core/services/password_generator_service.dart';
import '../../../core/utils/clipboard_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/favorite_button.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  PasswordOptions _options = const PasswordOptions(
    length: 16,
    includeUppercase: true,
    includeLowercase: true,
    includeNumbers: true,
    includeSymbols: true,
    excludeAmbiguous: false,
  );

  String _password = '';
  double _entropy = 0.0;
  String _strength = '';

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  void _regenerate() {
    try {
      final pwd = PasswordGeneratorService.generate(_options);
      final ent = PasswordGeneratorService.calculateEntropy(pwd, _options);
      final str = PasswordGeneratorService.evaluateStrength(ent);

      setState(() {
        _password = pwd;
        _entropy = ent;
        _strength = str;
      });
    } catch (_) {
      // If no characters selected
    }
  }

  Color _strengthColor() {
    if (_entropy < 36) return Colors.redAccent;
    if (_entropy < 50) return Colors.orangeAccent;
    if (_entropy < 65) return Colors.amber;
    if (_entropy < 80) return Colors.lightGreen;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cryptographic Password Generator'),
        actions: const [
          FavoriteButton(itemId: 'tool-password-gen'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Password Display Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Generated Password', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _strengthColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _strengthColor().withOpacity(0.4)),
                        ),
                        child: Text(
                          '$_strength (${_entropy.toStringAsFixed(1)} bits entropy)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _strengthColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _password,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => ClipboardUtils.copyWithFeedback(
                            context,
                            _password,
                            message: 'Password copied to clipboard',
                          ),
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy Password'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _regenerate,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Regenerate'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Generator Options Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Generation Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Length:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${_options.length} characters', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Slider(
                    value: _options.length.toDouble(),
                    min: 6,
                    max: 64,
                    divisions: 58,
                    label: '${_options.length}',
                    onChanged: (val) {
                      setState(() => _options = _options.copyWith(length: val.toInt()));
                      _regenerate();
                    },
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  SwitchListTile.adaptive(
                    title: const Text('Uppercase Letters (A-Z)'),
                    value: _options.includeUppercase,
                    onChanged: (val) {
                      if (!val && !_options.includeLowercase && !_options.includeNumbers && !_options.includeSymbols) return;
                      setState(() => _options = _options.copyWith(includeUppercase: val));
                      _regenerate();
                    },
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Lowercase Letters (a-z)'),
                    value: _options.includeLowercase,
                    onChanged: (val) {
                      if (!val && !_options.includeUppercase && !_options.includeNumbers && !_options.includeSymbols) return;
                      setState(() => _options = _options.copyWith(includeLowercase: val));
                      _regenerate();
                    },
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Numbers (0-9)'),
                    value: _options.includeNumbers,
                    onChanged: (val) {
                      if (!val && !_options.includeUppercase && !_options.includeLowercase && !_options.includeSymbols) return;
                      setState(() => _options = _options.copyWith(includeNumbers: val));
                      _regenerate();
                    },
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Symbols (!@#\$%^&*...)'),
                    value: _options.includeSymbols,
                    onChanged: (val) {
                      if (!val && !_options.includeUppercase && !_options.includeLowercase && !_options.includeNumbers) return;
                      setState(() => _options = _options.copyWith(includeSymbols: val));
                      _regenerate();
                    },
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Exclude Ambiguous Characters'),
                    subtitle: const Text('Excludes 0, O, o, 1, l, I, | to prevent visual confusion'),
                    value: _options.excludeAmbiguous,
                    onChanged: (val) {
                      setState(() => _options = _options.copyWith(excludeAmbiguous: val));
                      _regenerate();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Security Disclaimer
            const AppCard(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Zero-Knowledge Privacy: Passwords are generated using local cryptographically secure random number generators and are never logged, cached, or transmitted over any network.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
