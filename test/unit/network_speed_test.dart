import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/network_speed_service.dart';

void main() {
  group('NetworkSpeedService Tests', () {
    test('Calculates transfer time accurately matching specification example', () {
      // Specification Section 19: File: 10 GB, Speed: 100 Mbps, Efficiency: 90%
      // 10 GB = 10 * 1e9 * 8 = 8e10 bits
      // Speed = 100 * 1e6 * 0.9 = 9e7 bps
      // Time = 8e10 / 9e7 = 888.888s = 14 minutes 49 seconds
      final res = NetworkSpeedService.calculate(
        fileSize: 10,
        fileUnit: 'GB',
        networkSpeed: 100,
        speedUnit: 'Mbps',
        efficiencyPercentage: 90,
      );

      expect(res.formattedTime, '14 minutes 49 seconds');
      expect(res.theoreticalSpeedMbps, 100.0);
      expect(res.actualSpeedMbps, 90.0);
    });

    test('Formats duration for small files (< 1 second)', () {
      final res = NetworkSpeedService.calculate(
        fileSize: 10,
        fileUnit: 'KB',
        networkSpeed: 1,
        speedUnit: 'Gbps',
        efficiencyPercentage: 95,
      );

      expect(res.formattedTime, '< 1 second');
    });

    test('Formats long transfer times with days and hours', () {
      final res = NetworkSpeedService.calculate(
        fileSize: 50,
        fileUnit: 'TB',
        networkSpeed: 10,
        speedUnit: 'Mbps',
        efficiencyPercentage: 80,
      );

      expect(res.formattedTime.contains('days'), isTrue);
    });
  });
}
