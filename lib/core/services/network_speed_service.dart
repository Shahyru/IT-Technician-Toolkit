class NetworkSpeedResult {
  final double totalSeconds;
  final String formattedTime;
  final double theoreticalSpeedMbps;
  final double actualSpeedMbps;
  final double theoreticalSpeedMBs;
  final double actualSpeedMBs;

  const NetworkSpeedResult({
    required this.totalSeconds,
    required this.formattedTime,
    required this.theoreticalSpeedMbps,
    required this.actualSpeedMbps,
    required this.theoreticalSpeedMBs,
    required this.actualSpeedMBs,
  });
}

class NetworkSpeedService {
  /// Converts file size to bits
  static double fileSizeToBits(double size, String unit) {
    switch (unit) {
      case 'KB':
        return size * 1000 * 8;
      case 'MB':
        return size * 1000 * 1000 * 8;
      case 'GB':
        return size * 1000 * 1000 * 1000 * 8;
      case 'TB':
        return size * 1000 * 1000 * 1000 * 1000 * 8;
      case 'KiB':
        return size * 1024 * 8;
      case 'MiB':
        return size * 1024 * 1024 * 8;
      case 'GiB':
        return size * 1024 * 1024 * 1024 * 8;
      case 'TiB':
        return size * 1024 * 1024 * 1024 * 1024 * 8;
      default:
        return size * 8;
    }
  }

  /// Converts speed to bits per second (bps)
  static double speedToBps(double speed, String unit) {
    switch (unit) {
      case 'Kbps':
        return speed * 1e3;
      case 'Mbps':
        return speed * 1e6;
      case 'Gbps':
        return speed * 1e9;
      case 'KB/s':
        return speed * 8 * 1e3;
      case 'MB/s':
        return speed * 8 * 1e6;
      case 'GB/s':
        return speed * 8 * 1e9;
      case 'bps':
      default:
        return speed;
    }
  }

  /// Formats seconds into "X days, Y hours, Z minutes, W seconds"
  static String formatDuration(double totalSeconds) {
    if (totalSeconds.isNaN || totalSeconds.isInfinite || totalSeconds < 0) {
      return 'Indeterminate';
    }
    final int sec = totalSeconds.round();
    if (sec == 0) return '< 1 second';

    final int days = sec ~/ 86400;
    final int hours = (sec % 86400) ~/ 3600;
    final int minutes = (sec % 3600) ~/ 60;
    final int seconds = sec % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days ${days == 1 ? "day" : "days"}');
    if (hours > 0) parts.add('$hours ${hours == 1 ? "hour" : "hours"}');
    if (minutes > 0) parts.add('$minutes ${minutes == 1 ? "minute" : "minutes"}');
    if (seconds > 0 || parts.isEmpty) parts.add('$seconds ${seconds == 1 ? "second" : "seconds"}');

    return parts.join(' ');
  }

  /// Calculates file transfer time
  static NetworkSpeedResult calculate({
    required double fileSize,
    required String fileUnit,
    required double networkSpeed,
    required String speedUnit,
    required double efficiencyPercentage, // e.g. 90%
  }) {
    if (networkSpeed <= 0) {
      throw const FormatException('Network speed must be greater than zero');
    }
    if (fileSize < 0) {
      throw const FormatException('File size cannot be negative');
    }
    final efficiency = (efficiencyPercentage <= 0 ? 1.0 : efficiencyPercentage) / 100.0;

    final totalBits = fileSizeToBits(fileSize, fileUnit);
    final theoreticalBps = speedToBps(networkSpeed, speedUnit);
    final actualBps = theoreticalBps * efficiency;

    final totalSeconds = actualBps > 0 ? (totalBits / actualBps) : 0.0;

    final theoreticalMbps = theoreticalBps / 1e6;
    final actualMbps = actualBps / 1e6;
    final theoreticalMBs = theoreticalBps / (8 * 1e6);
    final actualMBs = actualBps / (8 * 1e6);

    return NetworkSpeedResult(
      totalSeconds: totalSeconds,
      formattedTime: formatDuration(totalSeconds),
      theoreticalSpeedMbps: theoreticalMbps,
      actualSpeedMbps: actualMbps,
      theoreticalSpeedMBs: theoreticalMBs,
      actualSpeedMBs: actualMBs,
    );
  }
}
