import 'dart:async';
import 'dart:io';

class PingSample {
  final int seq;
  final int timeMs;
  final bool success;
  final String? error;

  const PingSample({
    required this.seq,
    required this.timeMs,
    required this.success,
    this.error,
  });
}

class PingSummary {
  final String target;
  final String? resolvedIp;
  final int sent;
  final int received;
  final int lost;
  final double lossPercentage;
  final int? minLatencyMs;
  final int? avgLatencyMs;
  final int? maxLatencyMs;
  final List<PingSample> samples;

  const PingSummary({
    required this.target,
    this.resolvedIp,
    required this.sent,
    required this.received,
    required this.lost,
    required this.lossPercentage,
    this.minLatencyMs,
    this.avgLatencyMs,
    this.maxLatencyMs,
    required this.samples,
  });
}

class PingService {
  bool _isCancelled = false;

  void cancel() {
    _isCancelled = true;
  }

  /// Streams ping events one by one
  Stream<PingSample> pingTarget({
    required String host,
    int count = 4,
    int timeoutSeconds = 2,
    void Function(String? resolvedIp)? onResolved,
  }) async* {
    _isCancelled = false;
    String cleanHost = host.trim();
    if (cleanHost.startsWith('http://')) {
      cleanHost = cleanHost.replaceFirst('http://', '');
    }
    if (cleanHost.startsWith('https://')) {
      cleanHost = cleanHost.replaceFirst('https://', '');
    }
    if (cleanHost.contains('/')) {
      cleanHost = cleanHost.split('/')[0];
    }
    if (cleanHost.contains(':')) {
      cleanHost = cleanHost.split(':')[0];
    }

    String? resolvedIp;
    try {
      final addresses = await InternetAddress.lookup(cleanHost)
          .timeout(Duration(seconds: timeoutSeconds));
      if (addresses.isNotEmpty) {
        resolvedIp = addresses.first.address;
        onResolved?.call(resolvedIp);
      }
    } catch (e) {
      yield PingSample(
        seq: 1,
        timeMs: 0,
        success: false,
        error: 'Unable to resolve "$cleanHost": Check network connection or DNS.',
      );
      return;
    }

    for (int i = 1; i <= count; i++) {
      if (_isCancelled) break;

      final stopwatch = Stopwatch()..start();
      bool success = false;
      String? sampleError;

      try {
        // Attempt fast socket connection on standard port (80 or 443 or 53)
        final socket = await Socket.connect(
          resolvedIp ?? cleanHost,
          80,
          timeout: Duration(seconds: timeoutSeconds),
        ).catchError((_) async {
          // If port 80 fails or refused, try port 443
          return await Socket.connect(
            resolvedIp ?? cleanHost,
            443,
            timeout: Duration(seconds: timeoutSeconds),
          );
        }).catchError((_) async {
          // If 443 fails, try port 53 (DNS)
          return await Socket.connect(
            resolvedIp ?? cleanHost,
            53,
            timeout: Duration(seconds: timeoutSeconds),
          );
        });

        stopwatch.stop();
        socket.destroy();
        success = true;
      } on SocketException catch (e) {
        stopwatch.stop();
        // If connection was refused by target host, it means the host IS reachable and responded with RST!
        if (e.osError?.errorCode == 10061 || // Windows WSAECONNREFUSED
            e.osError?.errorCode == 111 ||   // Linux ECONNREFUSED
            e.osError?.errorCode == 61) {    // macOS ECONNREFUSED
          success = true;
        } else {
          sampleError = 'Request timed out';
        }
      } on TimeoutException {
        stopwatch.stop();
        sampleError = 'Request timed out after ${timeoutSeconds}s';
      } catch (e) {
        stopwatch.stop();
        sampleError = 'Network unreachable';
      }

      final elapsedMs = stopwatch.elapsedMilliseconds;

      yield PingSample(
        seq: i,
        timeMs: success ? (elapsedMs == 0 ? 1 : elapsedMs) : 0,
        success: success,
        error: sampleError,
      );

      if (i < count && !_isCancelled) {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }
  }

  /// Calculates aggregate summary from samples
  static PingSummary buildSummary(String target, String? resolvedIp, List<PingSample> samples) {
    final sent = samples.length;
    final successful = samples.where((s) => s.success).toList();
    final received = successful.length;
    final lost = sent - received;
    final lossPct = sent > 0 ? (lost / sent) * 100 : 0.0;

    int? minMs;
    int? maxMs;
    int? avgMs;

    if (successful.isNotEmpty) {
      final times = successful.map((s) => s.timeMs).toList();
      times.sort();
      minMs = times.first;
      maxMs = times.last;
      avgMs = (times.reduce((a, b) => a + b) / times.length).round();
    }

    return PingSummary(
      target: target,
      resolvedIp: resolvedIp,
      sent: sent,
      received: received,
      lost: lost,
      lossPercentage: lossPct,
      minLatencyMs: minMs,
      avgLatencyMs: avgMs,
      maxLatencyMs: maxMs,
      samples: samples,
    );
  }
}
