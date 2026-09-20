import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/mac_service.dart';

void main() {
  group('MacService Tests', () {
    test('Validates colon, hyphen, and cisco dot MAC formats', () {
      expect(MacService.isValid('00:1A:2B:3C:4D:5E'), isTrue);
      expect(MacService.isValid('00-1A-2B-3C-4D-5E'), isTrue);
      expect(MacService.isValid('001a.2b3c.4d5e'), isTrue);
      expect(MacService.isValid('001A2B3C4D5E'), isTrue);

      expect(MacService.isValid('00:1A:2B:3C:4D'), isFalse); // too short
      expect(MacService.isValid('00:1A:2B:3C:4D:5E:6F'), isFalse); // too long
      expect(MacService.isValid('00:1Z:2B:3C:4D:5E'), isFalse); // non-hex
    });

    test('Formats MAC addresses into canonical representations', () {
      const input = '00-1A-2B-3C-4D-5E';

      expect(MacService.format(input, MacFormatType.colon), '00:1A:2B:3C:4D:5E');
      expect(MacService.format(input, MacFormatType.hyphen), '00-1A-2B-3C-4D-5E');
      expect(MacService.format(input, MacFormatType.ciscoDot), '001a.2b3c.4d5e');
      expect(MacService.format(input, MacFormatType.rawHex), '001A2B3C4D5E');
    });

    test('Generates valid random MAC addresses', () {
      final mac = MacService.generate(type: MacGenerationType.random, formatType: MacFormatType.colon);
      expect(MacService.isValid(mac), isTrue);
      expect(mac.split(':').length, 6);
    });

    test('Generates unicast MAC address with b0 = 0', () {
      final mac = MacService.generate(type: MacGenerationType.unicast, formatType: MacFormatType.colon);
      expect(MacService.isValid(mac), isTrue);
      expect(MacService.isMulticast(mac), isFalse);
    });

    test('Generates locally administered MAC with b1 = 1', () {
      final mac = MacService.generate(type: MacGenerationType.locallyAdministered, formatType: MacFormatType.colon);
      expect(MacService.isValid(mac), isTrue);
      expect(MacService.isLocallyAdministered(mac), isTrue);
    });

    test('Look up OUI prefix from mock cache', () {
      MacService.setOuiCache({'00:0C:29': 'VMware, Inc', '00:1A:2B': 'Ayecom'});

      expect(MacService.lookupOui('00:0C:29:11:22:33'), 'VMware, Inc');
      expect(MacService.lookupOui('00-1a-2b-aa-bb-cc'), 'Ayecom');
      expect(MacService.lookupOui('11:22:33:44:55:66'), isNull);
    });
  });
}
