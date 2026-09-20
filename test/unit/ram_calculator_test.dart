import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/ram_calculator_service.dart';

void main() {
  group('RamCalculatorService Tests', () {
    test('Calculates total RAM from dynamic module list accurately', () {
      final modules = [
        RamModule(id: '1', capacity: 8, unit: 'GB'),
        RamModule(id: '2', capacity: 8, unit: 'GB'),
        RamModule(id: '3', capacity: 16, unit: 'GB'),
      ];

      final total = RamCalculatorService.calculateTotalInGb(modules);
      expect(total, 32.0);
    });

    test('Handles mixed units (MB and GB)', () {
      final modules = [
        RamModule(id: '1', capacity: 4, unit: 'GB'),
        RamModule(id: '2', capacity: 2048, unit: 'MB'), // 2 GB
      ];

      final total = RamCalculatorService.calculateTotalInGb(modules);
      expect(total, 6.0);
    });

    test('Generates memory conversions table', () {
      final conversions = RamCalculatorService.getFormattedConversions(16.0);
      expect(conversions.containsKey('Bytes'), isTrue);
      expect(conversions.containsKey('MB'), isTrue);
      expect(conversions.containsKey('GiB'), isTrue);
    });
  });
}
