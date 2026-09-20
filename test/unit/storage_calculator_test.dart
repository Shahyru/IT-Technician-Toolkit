import 'package:flutter_test/flutter_test.dart';
import 'package:it_technician_toolkit/core/services/storage_calculator_service.dart';

void main() {
  group('StorageCalculatorService Tests', () {
    test('Calculates Single Drive configuration', () {
      final res = StorageCalculatorService.calculate(
        mode: RaidMode.single,
        driveCount: 1,
        driveCapacity: 4.0,
      );
      expect(res.rawCapacity, 4.0);
      expect(res.usableCapacity, 4.0);
      expect(res.redundancyCapacity, 0.0);
      expect(res.efficiencyPercentage, 100.0);
    });

    test('Calculates RAID 0 Striping with zero redundancy', () {
      final res = StorageCalculatorService.calculate(
        mode: RaidMode.raid0,
        driveCount: 4,
        driveCapacity: 2.0,
      );
      expect(res.rawCapacity, 8.0);
      expect(res.usableCapacity, 8.0);
      expect(res.redundancyCapacity, 0.0);
      expect(res.efficiencyPercentage, 100.0);
    });

    test('Calculates RAID 1 Mirroring (2 drives = 1 drive usable)', () {
      final res = StorageCalculatorService.calculate(
        mode: RaidMode.raid1,
        driveCount: 2,
        driveCapacity: 4.0,
      );
      expect(res.rawCapacity, 8.0);
      expect(res.usableCapacity, 4.0);
      expect(res.redundancyCapacity, 4.0);
      expect(res.efficiencyPercentage, 50.0);
    });

    test('Calculates RAID 5 Parity: (N-1) usable', () {
      // 4 drives * 4 TB = 16 TB raw, 12 TB usable, 4 TB parity
      final res = StorageCalculatorService.calculate(
        mode: RaidMode.raid5,
        driveCount: 4,
        driveCapacity: 4.0,
      );
      expect(res.rawCapacity, 16.0);
      expect(res.usableCapacity, 12.0);
      expect(res.redundancyCapacity, 4.0);
      expect(res.efficiencyPercentage, 75.0);
    });

    test('Calculates RAID 6 Dual Parity: (N-2) usable', () {
      // 6 drives * 4 TB = 24 TB raw, 16 TB usable, 8 TB parity
      final res = StorageCalculatorService.calculate(
        mode: RaidMode.raid6,
        driveCount: 6,
        driveCapacity: 4.0,
      );
      expect(res.rawCapacity, 24.0);
      expect(res.usableCapacity, 16.0);
      expect(res.redundancyCapacity, 8.0);
    });

    test('Calculates RAID 10 Striped Mirrors: N/2 usable', () {
      // 4 drives * 8 TB = 32 TB raw, 16 TB usable
      final res = StorageCalculatorService.calculate(
        mode: RaidMode.raid10,
        driveCount: 4,
        driveCapacity: 8.0,
      );
      expect(res.rawCapacity, 32.0);
      expect(res.usableCapacity, 16.0);
      expect(res.efficiencyPercentage, 50.0);
    });

    test('Enforces minimum drives per RAID mode', () {
      expect(
        () => StorageCalculatorService.calculate(
          mode: RaidMode.raid5,
          driveCount: 2, // Needs at least 3
          driveCapacity: 1.0,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
