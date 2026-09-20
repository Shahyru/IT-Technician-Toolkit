enum RaidMode {
  single,
  raid0,
  raid1,
  raid5,
  raid6,
  raid10,
}

extension RaidModeExtension on RaidMode {
  String get displayName {
    switch (this) {
      case RaidMode.single:
        return 'Single Drive';
      case RaidMode.raid0:
        return 'RAID 0 (Striping)';
      case RaidMode.raid1:
        return 'RAID 1 (Mirroring)';
      case RaidMode.raid5:
        return 'RAID 5 (Parity)';
      case RaidMode.raid6:
        return 'RAID 6 (Dual Parity)';
      case RaidMode.raid10:
        return 'RAID 10 (1+0 Striped Mirrors)';
    }
  }

  int get minDrives {
    switch (this) {
      case RaidMode.single:
        return 1;
      case RaidMode.raid0:
        return 2;
      case RaidMode.raid1:
        return 2;
      case RaidMode.raid5:
        return 3;
      case RaidMode.raid6:
        return 4;
      case RaidMode.raid10:
        return 4; // Must be even
    }
  }
}

class StorageCalculationResult {
  final double rawCapacity;
  final double usableCapacity;
  final double redundancyCapacity;
  final double capacityLoss;
  final double efficiencyPercentage;
  final String faultTolerance;
  final String note;

  const StorageCalculationResult({
    required this.rawCapacity,
    required this.usableCapacity,
    required this.redundancyCapacity,
    required this.capacityLoss,
    required this.efficiencyPercentage,
    required this.faultTolerance,
    required this.note,
  });
}

class StorageCalculatorService {
  /// Calculates storage capacity and redundancy for specified RAID mode
  static StorageCalculationResult calculate({
    required RaidMode mode,
    required int driveCount,
    required double driveCapacity, // in TB or GB
  }) {
    if (driveCount < mode.minDrives) {
      throw FormatException('${mode.displayName} requires at least ${mode.minDrives} drives.');
    }
    if (mode == RaidMode.raid10 && driveCount % 2 != 0) {
      throw const FormatException('RAID 10 requires an even number of drives.');
    }

    final raw = driveCount * driveCapacity;
    double usable = 0.0;
    double redundancy = 0.0;
    String tolerance = '';
    String note = '';

    switch (mode) {
      case RaidMode.single:
        usable = driveCapacity;
        redundancy = 0.0;
        tolerance = 'None (0 drive failures allowed)';
        note = 'Single standalone disk. Drive failure will cause permanent data loss.';
        break;

      case RaidMode.raid0:
        usable = raw;
        redundancy = 0.0;
        tolerance = 'None (0 drive failures allowed)';
        note = 'Maximum performance striping with NO redundancy. Any single drive failure loses all data.';
        break;

      case RaidMode.raid1:
        // RAID 1 usable is 1 drive's capacity regardless of drive count (mirrors)
        usable = driveCapacity;
        redundancy = raw - usable;
        tolerance = '${driveCount - 1} drive failure(s) allowed';
        note = 'Full mirroring. Data is safe as long as at least 1 drive survives.';
        break;

      case RaidMode.raid5:
        // Usable = (N - 1) * Capacity
        usable = (driveCount - 1) * driveCapacity;
        redundancy = driveCapacity;
        tolerance = '1 drive failure allowed';
        note = 'Distributed single parity. Protects against 1 drive failure with good storage efficiency.';
        break;

      case RaidMode.raid6:
        // Usable = (N - 2) * Capacity
        usable = (driveCount - 2) * driveCapacity;
        redundancy = 2 * driveCapacity;
        tolerance = '2 drive failures allowed';
        note = 'Distributed dual parity. Safe against simultaneous failure of up to 2 drives.';
        break;

      case RaidMode.raid10:
        // Usable = (N / 2) * Capacity
        usable = (driveCount / 2) * driveCapacity;
        redundancy = raw - usable;
        tolerance = '1 drive per mirrored pair (up to ${driveCount ~/ 2} drives)';
        note = 'Striped mirrors providing excellent read/write performance and fast rebuild times.';
        break;
    }

    final loss = raw - usable;
    final efficiency = raw > 0 ? (usable / raw) * 100 : 0.0;

    return StorageCalculationResult(
      rawCapacity: raw,
      usableCapacity: usable,
      redundancyCapacity: redundancy,
      capacityLoss: loss,
      efficiencyPercentage: efficiency,
      faultTolerance: tolerance,
      note: note,
    );
  }
}
