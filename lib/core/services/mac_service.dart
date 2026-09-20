import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../utils/validators.dart';

enum MacFormatType {
  colon, // 00:1A:2B:3C:4D:5E
  hyphen, // 00-1A-2B-3C-4D-5E
  ciscoDot, // 001a.2b3c.4d5e
  rawHex, // 001A2B3C4D5E
}

enum MacGenerationType {
  random,
  unicast,
  locallyAdministered,
}

class MacService {
  static Map<String, String>? _ouiCache;

  /// Loads bundled OUI database from assets
  static Future<void> loadOuiDatabase() async {
    if (_ouiCache != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/networking/oui.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      _ouiCache = map.map((k, v) => MapEntry(k.toUpperCase(), v.toString()));
    } catch (_) {
      _ouiCache = {};
    }
  }

  /// Sets OUI cache directly for unit testing
  static void setOuiCache(Map<String, String> cache) {
    _ouiCache = cache;
  }

  /// Strips separators from MAC address into 12 uppercase hex characters
  static String normalize(String mac) {
    return mac.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
  }

  /// Validates MAC address
  static bool isValid(String mac) {
    return Validators.validateMAC(mac) == null;
  }

  /// Formats 12 hex characters into target style
  static String format(String mac, MacFormatType type) {
    final hex = normalize(mac);
    if (hex.length != 12) {
      throw const FormatException('MAC address must have exactly 12 hexadecimal characters');
    }

    switch (type) {
      case MacFormatType.colon:
        return [
          hex.substring(0, 2),
          hex.substring(2, 4),
          hex.substring(4, 6),
          hex.substring(6, 8),
          hex.substring(8, 10),
          hex.substring(10, 12),
        ].join(':');

      case MacFormatType.hyphen:
        return [
          hex.substring(0, 2),
          hex.substring(2, 4),
          hex.substring(4, 6),
          hex.substring(6, 8),
          hex.substring(8, 10),
          hex.substring(10, 12),
        ].join('-');

      case MacFormatType.ciscoDot:
        return [
          hex.substring(0, 4).toLowerCase(),
          hex.substring(4, 8).toLowerCase(),
          hex.substring(8, 12).toLowerCase(),
        ].join('.');

      case MacFormatType.rawHex:
        return hex;
    }
  }

  /// Generates a valid MAC address
  static String generate({
    MacGenerationType type = MacGenerationType.random,
    MacFormatType formatType = MacFormatType.colon,
  }) {
    final rng = Random.secure();
    final bytes = List<int>.generate(6, (_) => rng.nextInt(256));

    if (type == MacGenerationType.unicast) {
      // Clear least-significant bit of first octet (b0 = 0)
      bytes[0] = bytes[0] & 0xFE;
    } else if (type == MacGenerationType.locallyAdministered) {
      // Set second least-significant bit of first octet (b1 = 1) and clear multicast bit (b0 = 0)
      bytes[0] = (bytes[0] | 0x02) & 0xFE;
    }

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();
    return format(hex, formatType);
  }

  /// Look up vendor by MAC or OUI prefix
  static String? lookupOui(String mac) {
    final hex = normalize(mac);
    if (hex.length < 6) return null;
    final prefix = '${hex.substring(0, 2)}:${hex.substring(2, 4)}:${hex.substring(4, 6)}';
    return _ouiCache?[prefix];
  }

  /// Checks if MAC is Multicast
  static bool isMulticast(String mac) {
    final hex = normalize(mac);
    if (hex.length < 2) return false;
    final firstByte = int.tryParse(hex.substring(0, 2), radix: 16) ?? 0;
    return (firstByte & 0x01) == 1;
  }

  /// Checks if MAC is Locally Administered (U/L bit set)
  static bool isLocallyAdministered(String mac) {
    final hex = normalize(mac);
    if (hex.length < 2) return false;
    final firstByte = int.tryParse(hex.substring(0, 2), radix: 16) ?? 0;
    return (firstByte & 0x02) == 2;
  }
}
