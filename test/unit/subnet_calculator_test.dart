import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/subnet_calculator_service.dart';

void main() {
  group('SubnetCalculatorService Tests', () {
    test('Calculates 4 subnets dividing a /24 network into /26 subnets', () {
      final subnets = SubnetCalculatorService.calculateSubnets(
        baseNetwork: '192.168.1.0',
        baseCidr: 24,
        targetCidr: 26,
      );

      expect(subnets.length, 4);

      // Subnet 1
      expect(subnets[0].networkAddress, '192.168.1.0');
      expect(subnets[0].broadcastAddress, '192.168.1.63');
      expect(subnets[0].firstHost, '192.168.1.1');
      expect(subnets[0].lastHost, '192.168.1.62');
      expect(subnets[0].usableHosts, 62);

      // Subnet 2
      expect(subnets[1].networkAddress, '192.168.1.64');
      expect(subnets[1].broadcastAddress, '192.168.1.127');
      expect(subnets[1].firstHost, '192.168.1.65');
      expect(subnets[1].lastHost, '192.168.1.126');
      expect(subnets[1].usableHosts, 62);

      // Subnet 3
      expect(subnets[2].networkAddress, '192.168.1.128');
      expect(subnets[2].broadcastAddress, '192.168.1.191');

      // Subnet 4
      expect(subnets[3].networkAddress, '192.168.1.192');
      expect(subnets[3].broadcastAddress, '192.168.1.255');
    });

    test('Calculates smallest CIDR prefix for required host capacity', () {
      expect(SubnetCalculatorService.cidrForHosts(50), 26); // 26 gives 62 hosts
      expect(SubnetCalculatorService.cidrForHosts(100), 25); // 25 gives 126 hosts
      expect(SubnetCalculatorService.cidrForHosts(300), 23); // 23 gives 510 hosts
    });

    test('Calculates target CIDR to accommodate subnet counts', () {
      expect(SubnetCalculatorService.cidrForSubnets(24, 4), 26); // borrows 2 bits: 24+2=26
      expect(SubnetCalculatorService.cidrForSubnets(24, 8), 27); // borrows 3 bits: 24+3=27
    });

    test('Throws FormatException if target CIDR is smaller than base CIDR', () {
      expect(
        () => SubnetCalculatorService.calculateSubnets(
          baseNetwork: '192.168.1.0',
          baseCidr: 24,
          targetCidr: 22,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
