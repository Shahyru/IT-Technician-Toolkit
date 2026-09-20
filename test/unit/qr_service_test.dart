import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/qr_service.dart';

void main() {
  group('QrService Tests', () {
    test('Builds standard Wi-Fi connection payload', () {
      final payload = QrService.buildWifiPayload(
        ssid: 'MyWiFiNetwork',
        password: 'SuperSecretPassword',
        security: WifiSecurity.wpa,
        isHidden: false,
      );

      expect(payload, 'WIFI:S:MyWiFiNetwork;T:WPA;P:SuperSecretPassword;;');
    });

    test('Builds hidden Wi-Fi connection payload with escaping', () {
      final payload = QrService.buildWifiPayload(
        ssid: 'Office;Guest',
        password: 'Pass;123',
        security: WifiSecurity.wpa,
        isHidden: true,
      );

      expect(payload.contains(r'Office\;Guest'), isTrue);
      expect(payload.contains(';H:true'), isTrue);
    });

    test('Builds open Wi-Fi network without password', () {
      final payload = QrService.buildWifiPayload(
        ssid: 'OpenSpot',
        password: '',
        security: WifiSecurity.nopass,
      );

      expect(payload, 'WIFI:S:OpenSpot;T:nopass;;');
    });

    test('Builds Mailto, Phone, SMS, and vCard payloads', () {
      final email = QrService.buildEmailPayload(email: 'test@example.com', subject: 'Urgent');
      expect(email, 'mailto:test@example.com?subject=Urgent');

      final phone = QrService.buildPhonePayload('+1555123456');
      expect(phone, 'tel:+1555123456');

      final sms = QrService.buildSmsPayload(phone: '+1555123456', message: 'Hello');
      expect(sms, 'smsto:+1555123456:Hello');

      final vcard = QrService.buildVCardPayload(
        firstName: 'Jane',
        lastName: 'Admin',
        organization: 'Enterprise IT',
      );
      expect(vcard.contains('BEGIN:VCARD'), isTrue);
      expect(vcard.contains('FN:Jane Admin'), isTrue);
    });
  });
}
