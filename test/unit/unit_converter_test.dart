import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/unit_conversion_service.dart';

void main() {
  group('UnitConversionService Tests', () {
    test('Converts Data Storage units correctly', () {
      // 1 Byte = 8 bits
      final bits = UnitConversionService.convert(
        category: ConversionCategory.data,
        value: 1,
        fromUnit: 'Byte',
        toUnit: 'bit',
      );
      expect(bits, 8.0);

      // 1 GiB = 1024 MiB
      final mib = UnitConversionService.convert(
        category: ConversionCategory.data,
        value: 1,
        fromUnit: 'GiB (binary)',
        toUnit: 'MiB (binary)',
      );
      expect(mib, 1024.0);

      // 1 TB = 1000 GB
      final gb = UnitConversionService.convert(
        category: ConversionCategory.data,
        value: 1,
        fromUnit: 'TB (decimal)',
        toUnit: 'GB (decimal)',
      );
      expect(gb, 1000.0);
    });

    test('Converts Network Throughput units correctly', () {
      // 100 Mbps to MB/s -> 100 * 1e6 / (8 * 1e6) = 12.5 MB/s
      final mbs = UnitConversionService.convert(
        category: ConversionCategory.network,
        value: 100,
        fromUnit: 'Mbps',
        toUnit: 'MB/s',
      );
      expect(mbs, 12.5);

      // 1 Gbps = 1000 Mbps
      final mbps = UnitConversionService.convert(
        category: ConversionCategory.network,
        value: 1,
        fromUnit: 'Gbps',
        toUnit: 'Mbps',
      );
      expect(mbps, 1000.0);
    });

    test('Converts Temperature accurately', () {
      // 0 Celsius = 32 Fahrenheit
      final f = UnitConversionService.convert(
        category: ConversionCategory.temperature,
        value: 0,
        fromUnit: 'Celsius',
        toUnit: 'Fahrenheit',
      );
      expect(f, 32.0);

      // 100 Celsius = 373.15 Kelvin
      final k = UnitConversionService.convert(
        category: ConversionCategory.temperature,
        value: 100,
        fromUnit: 'Celsius',
        toUnit: 'Kelvin',
      );
      expect(k, 373.15);
    });

    test('Converts Length and Weight units', () {
      // 1 km = 1000 m
      final m = UnitConversionService.convert(
        category: ConversionCategory.length,
        value: 1,
        fromUnit: 'km',
        toUnit: 'm',
      );
      expect(m, 1000.0);

      // 1 kg = 1000 g
      final g = UnitConversionService.convert(
        category: ConversionCategory.weight,
        value: 1,
        fromUnit: 'kg',
        toUnit: 'g',
      );
      expect(g, 1000.0);
    });
  });
}
