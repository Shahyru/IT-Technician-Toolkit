class Validators {
  /// Validates IPv4 address string (e.g. 192.168.1.1)
  static String? validateIPv4(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IP address cannot be empty';
    }
    final trimmed = value.trim();
    final parts = trimmed.split('.');
    if (parts.length != 4) {
      return 'Invalid IPv4 address: must contain 4 octets';
    }
    for (final part in parts) {
      if (part.isEmpty) {
        return 'Invalid octet: cannot be empty';
      }
      final intVal = int.tryParse(part);
      if (intVal == null) {
        return 'Invalid octet: "$part" is not a number';
      }
      if (intVal < 0 || intVal > 255) {
        return 'Invalid octet "$intVal": must be between 0 and 255';
      }
      // Check for leading zero if length > 1
      if (part.length > 1 && part.startsWith('0')) {
        return 'Invalid octet "$part": leading zeros not allowed';
      }
    }
    return null;
  }

  /// Validates standard IPv4 Subnet Mask (e.g. 255.255.255.0)
  static String? validateSubnetMask(String? value) {
    final ipError = validateIPv4(value);
    if (ipError != null) return ipError;

    final parts = value!.trim().split('.').map(int.parse).toList();
    final binary = parts.map((e) => e.toRadixString(2).padLeft(8, '0')).join();
    
    // Subnet mask must be contiguous 1s followed by 0s
    final match = RegExp(r'^1*0*$').hasMatch(binary);
    if (!match) {
      return 'Invalid subnet mask: bits must be contiguous';
    }
    return null;
  }

  /// Validates CIDR notation (e.g. 0 to 32 or /24)
  static String? validateCIDR(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CIDR prefix cannot be empty';
    }
    String cleaned = value.trim();
    if (cleaned.startsWith('/')) {
      cleaned = cleaned.substring(1);
    }
    final cidr = int.tryParse(cleaned);
    if (cidr == null) {
      return 'CIDR must be an integer';
    }
    if (cidr < 0 || cidr > 32) {
      return 'CIDR prefix must be between /0 and /32';
    }
    return null;
  }

  /// Validates IP address with optional CIDR (e.g. 192.168.1.1 or 192.168.1.1/24)
  static String? validateIPOrCIDR(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an IP address or IP/CIDR';
    }
    final trimmed = value.trim();
    if (trimmed.contains('/')) {
      final split = trimmed.split('/');
      if (split.length != 2) return 'Invalid IP/CIDR format';
      final ipErr = validateIPv4(split[0]);
      if (ipErr != null) return ipErr;
      final cidrErr = validateCIDR(split[1]);
      if (cidrErr != null) return cidrErr;
      return null;
    }
    return validateIPv4(trimmed);
  }

  /// Validates Port number (1 - 65535)
  static String? validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port cannot be empty';
    }
    final port = int.tryParse(value.trim());
    if (port == null) {
      return 'Port must be a valid number';
    }
    if (port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }
    return null;
  }

  /// Validates MAC Address (colon, hyphen, or cisco dot)
  static String? validateMAC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MAC address cannot be empty';
    }
    final trimmed = value.trim();
    // Colon format: 00:1A:2B:3C:4D:5E
    final colonRegex = RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');
    // Hyphen format: 00-1A-2B-3C-4D-5E
    final hyphenRegex = RegExp(r'^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$');
    // Cisco dot format: 001a.2b3c.4d5e
    final dotRegex = RegExp(r'^[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}$');
    // Raw hex: 001A2B3C4D5E
    final rawRegex = RegExp(r'^[0-9A-Fa-f]{12}$');

    if (colonRegex.hasMatch(trimmed) ||
        hyphenRegex.hasMatch(trimmed) ||
        dotRegex.hasMatch(trimmed) ||
        rawRegex.hasMatch(trimmed)) {
      return null;
    }
    return 'Invalid MAC format (use 00:11:22:33:44:55, 00-11-22-33-44-55, or 0011.2233.4455)';
  }

  /// Validates Hostname or IP
  static String? validateHostname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hostname or IP cannot be empty';
    }
    final trimmed = value.trim();
    // If IPv4
    if (validateIPv4(trimmed) == null) return null;

    // Check valid hostname (RFC 1123)
    final hostnameRegex = RegExp(r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}$|^localhost$');
    if (hostnameRegex.hasMatch(trimmed) || RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(trimmed)) {
      return null;
    }
    return 'Invalid hostname or domain';
  }

  /// Validates positive integer
  static String? validatePositiveInteger(String? value, {String field = 'Value', int min = 1, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    final num = int.tryParse(value.trim());
    if (num == null) {
      return '$field must be a valid number';
    }
    if (num < min) {
      return '$field must be at least $min';
    }
    if (max != null && num > max) {
      return '$field cannot exceed $max';
    }
    return null;
  }

  /// Validates positive double
  static String? validatePositiveDouble(String? value, {String field = 'Value', double min = 0.000001}) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return '$field must be a valid number';
    }
    if (num < min) {
      return '$field must be greater than 0';
    }
    return null;
  }
}
