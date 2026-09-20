class RamModule {
  final String id;
  double capacity;
  String unit; // 'MB', 'GB'

  RamModule({
    required this.id,
    required this.capacity,
    this.unit = 'GB',
  });

  /// Capacity in Megabytes (MB)
  double get capacityInMb {
    if (unit == 'GB') {
      return capacity * 1024.0;
    }
    return capacity;
  }
}

class RamCalculatorService {
  /// Calculates total RAM from a list of dynamic modules
  static double calculateTotalInGb(List<RamModule> modules) {
    if (modules.isEmpty) return 0.0;
    final totalMb = modules.fold<double>(0.0, (sum, m) => sum + m.capacityInMb);
    return totalMb / 1024.0;
  }

  /// Converts bytes to human readable memory string
  static Map<String, String> getFormattedConversions(double totalGb) {
    final bytes = totalGb * 1024.0 * 1024.0 * 1024.0;
    return {
      'Bytes': bytes.toStringAsFixed(0),
      'KB': (bytes / 1000).toStringAsFixed(2),
      'MB': (bytes / (1000 * 1000)).toStringAsFixed(2),
      'GB': (bytes / (1000 * 1000 * 1000)).toStringAsFixed(2),
      'TB': (bytes / (1000 * 1000 * 1000 * 1000)).toStringAsFixed(4),
      'KiB': (bytes / 1024).toStringAsFixed(2),
      'MiB': (bytes / (1024 * 1024)).toStringAsFixed(2),
      'GiB': (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2),
      'TiB': (bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(4),
    };
  }
}
