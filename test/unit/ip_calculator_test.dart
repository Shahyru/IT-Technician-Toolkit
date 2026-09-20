import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/ip_calculator_service.dart';

void main() {
  group('IpCalculatorService Tests', () {
    test('Calculates standard /24 subnet accurately', () {
      final res = IpCalculatorService.calculate('192.168.1.100', cidrInput: 24);

      expect(res.ipAddress, '192.168.1.100');
      expect(res.subnetMask, '255.255.255.0');
      expect(res.cidr, 24);
      expect(res.networkAddress, '192.168.1.0');
      expect(res.broadcastAddress, '192.168.1.255');
      expect(res.firstUsableHost, '192.168.1.1');
      expect(res.lastUsableHost, '192.168.1.254');
      expect(res.totalAddresses, 256);
      expect(res.usableHosts, 254);
      expect(res.ipClass, 'Class C');
      expect(res.scope, 'Private (RFC 1918)');
      expect(res.wildcardMask, '0.0.0.255');
    });

    test('Parses CIDR notation embedded in IP input', () {
      final res = IpCalculatorService.calculate('10.0.0.50/16');

      expect(res.ipAddress, '10.0.0.50');
      expect(res.subnetMask, '255.255.0.0');
      expect(res.cidr, 16);
      expect(res.networkAddress, '10.0.0.0');
      expect(res.broadcastAddress, '10.0.255.255');
      expect(res.firstUsableHost, '10.0.0.1');
      expect(res.lastUsableHost, '10.0.255.254');
      expect(res.totalAddresses, 65536);
      expect(res.usableHosts, 65534);
      expect(res.ipClass, 'Class A');
      expect(res.scope, 'Private (RFC 1918)');
    });

    test('Handles /30 point-to-point router links', () {
      final res = IpCalculatorService.calculate('172.16.1.5/30');

      expect(res.networkAddress, '172.16.1.4');
      expect(res.broadcastAddress, '172.16.1.7');
      expect(res.firstUsableHost, '172.16.1.5');
      expect(res.lastUsableHost, '172.16.1.6');
      expect(res.totalAddresses, 4);
      expect(res.usableHosts, 2);
    });

    test('Handles /32 single host route', () {
      final res = IpCalculatorService.calculate('8.8.8.8/32');

      expect(res.networkAddress, '8.8.8.8');
      expect(res.broadcastAddress, '8.8.8.8');
      expect(res.usableHosts, 1);
      expect(res.scope, 'Public');
      expect(res.ipClass, 'Class A');
    });

    test('Detects APIPA Link-Local addresses', () {
      final res = IpCalculatorService.calculate('169.254.12.34/16');
      expect(res.scope, 'Link-Local / APIPA');
    });

    test('Detects Loopback addresses', () {
      final res = IpCalculatorService.calculate('127.0.0.1/8');
      expect(res.scope, 'Loopback');
    });

    test('Rejects invalid IP octets greater than 255', () {
      expect(
        () => IpCalculatorService.calculate('999.168.1.1/24'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Rejects malformed octet counts', () {
      expect(
        () => IpCalculatorService.calculate('192.168.1/24'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => IpCalculatorService.calculate('192.168.1.1.1/24'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Rejects negative octets and non-numbers', () {
      expect(
        () => IpCalculatorService.calculate('192.168.-1.1/24'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => IpCalculatorService.calculate('192.168.abc.1/24'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
