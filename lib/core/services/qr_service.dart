enum QrContentType {
  plainText,
  url,
  wifi,
  email,
  phone,
  sms,
  vCard,
}

enum WifiSecurity {
  wpa,
  wep,
  nopass,
}

class QrService {
  /// Builds Wi-Fi standard connection URI: WIFI:S:<SSID>;T:<WPA|WEP|nopass>;P:<password>;H:<true|false>;;
  static String buildWifiPayload({
    required String ssid,
    required String password,
    required WifiSecurity security,
    bool isHidden = false,
  }) {
    String secString;
    switch (security) {
      case WifiSecurity.wpa:
        secString = 'WPA';
        break;
      case WifiSecurity.wep:
        secString = 'WEP';
        break;
      case WifiSecurity.nopass:
        secString = 'nopass';
        break;
    }

    // Escape special chars according to ZXing standard: \ ; , " :
    String escape(String s) {
      return s
          .replaceAll(r'\', r'\\')
          .replaceAll(';', r'\;')
          .replaceAll(',', r'\,')
          .replaceAll('"', r'\"')
          .replaceAll(':', r'\:');
    }

    final p = security == WifiSecurity.nopass ? '' : ';P:${escape(password)}';
    final h = isHidden ? ';H:true' : '';
    return 'WIFI:S:${escape(ssid)};T:$secString$p$h;;';
  }

  /// Builds Mailto payload: mailto:test@example.com?subject=...&body=...
  static String buildEmailPayload({
    required String email,
    String? subject,
    String? body,
  }) {
    final query = <String>[];
    if (subject != null && subject.isNotEmpty) {
      query.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null && body.isNotEmpty) {
      query.add('body=${Uri.encodeComponent(body)}');
    }
    final qs = query.isEmpty ? '' : '?${query.join('&')}';
    return 'mailto:$email$qs';
  }

  /// Builds Phone call payload: tel:+1234567890
  static String buildPhonePayload(String phone) {
    return 'tel:${phone.trim()}';
  }

  /// Builds SMS payload: smsto:+1234567890:Message
  static String buildSmsPayload({required String phone, String? message}) {
    final msg = (message != null && message.isNotEmpty) ? ':${message.trim()}' : '';
    return 'smsto:${phone.trim()}$msg';
  }

  /// Builds vCard standard format
  static String buildVCardPayload({
    required String firstName,
    required String lastName,
    String? organization,
    String? title,
    String? phone,
    String? email,
    String? website,
  }) {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      'N:$lastName;$firstName;;;',
      'FN:$firstName $lastName',
    ];
    if (organization != null && organization.isNotEmpty) {
      lines.add('ORG:$organization');
    }
    if (title != null && title.isNotEmpty) {
      lines.add('TITLE:$title');
    }
    if (phone != null && phone.isNotEmpty) {
      lines.add('TEL;TYPE=CELL:$phone');
    }
    if (email != null && email.isNotEmpty) {
      lines.add('EMAIL:$email');
    }
    if (website != null && website.isNotEmpty) {
      lines.add('URL:$website');
    }
    lines.add('END:VCARD');
    return lines.join('\n');
  }
}
