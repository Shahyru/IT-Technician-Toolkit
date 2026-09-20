import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/ping_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/favorite_button.dart';

class PingScreen extends StatefulWidget {
  const PingScreen({super.key});

  @override
  State<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends State<PingScreen> {
  final TextEditingController _hostController = TextEditingController(text: '8.8.8.8');
  final PingService _pingService = PingService();
  StreamSubscription<PingSample>? _sub;

  int _packetCount = 4;
  int _timeoutSeconds = 2;

  bool _isRunning = false;
  String? _resolvedIp;
  final List<PingSample> _samples = [];
  PingSummary? _summary;
  String? _errorMessage;

  @override
  void dispose() {
    _sub?.cancel();
    _pingService.cancel();
    _hostController.dispose();
    super.dispose();
  }

  void _startPing() {
    final host = _hostController.text.trim();
    if (host.isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid IP address or hostname');
      return;
    }

    _sub?.cancel();
    setState(() {
      _isRunning = true;
      _samples.clear();
      _summary = null;
      _resolvedIp = null;
      _errorMessage = null;
    });

    final stream = _pingService.pingTarget(
      host: host,
      count: _packetCount,
      timeoutSeconds: _timeoutSeconds,
      onResolved: (ip) {
        if (mounted) {
          setState(() => _resolvedIp = ip);
        }
      },
    );

    _sub = stream.listen(
      (sample) {
        if (mounted) {
          setState(() {
            _samples.add(sample);
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Network reachability test failed: $err';
            _isRunning = false;
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isRunning = false;
            _summary = PingService.buildSummary(host, _resolvedIp, _samples);
          });
        }
      },
    );
  }

  void _stopPing() {
    _pingService.cancel();
    _sub?.cancel();
    setState(() {
      _isRunning = false;
      if (_samples.isNotEmpty) {
        _summary = PingService.buildSummary(_hostController.text.trim(), _resolvedIp, _samples);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ping Reachability Tool'),
        actions: const [
          FavoriteButton(itemId: 'tool-ping'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Controls Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Host & Connection Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hostController,
                    enabled: !_isRunning,
                    decoration: const InputDecoration(
                      labelText: 'Destination Host or IP',
                      hintText: 'e.g. 1.1.1.1 or google.com',
                      prefixIcon: Icon(Icons.dns_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _packetCount,
                          decoration: const InputDecoration(labelText: 'Packet Count'),
                          items: const [
                            DropdownMenuItem(value: 4, child: Text('4 Packets')),
                            DropdownMenuItem(value: 8, child: Text('8 Packets')),
                            DropdownMenuItem(value: 16, child: Text('16 Packets')),
                            DropdownMenuItem(value: 30, child: Text('30 Packets')),
                          ],
                          onChanged: _isRunning ? null : (val) => setState(() => _packetCount = val ?? 4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _timeoutSeconds,
                          decoration: const InputDecoration(labelText: 'Timeout / Echo'),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1 Second')),
                            DropdownMenuItem(value: 2, child: Text('2 Seconds')),
                            DropdownMenuItem(value: 4, child: Text('4 Seconds')),
                          ],
                          onChanged: _isRunning ? null : (val) => setState(() => _timeoutSeconds = val ?? 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRunning ? null : _startPing,
                          icon: _isRunning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.play_arrow),
                          label: Text(_isRunning ? 'Testing...' : 'Start Ping'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_isRunning) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _stopPing,
                          icon: const Icon(Icons.stop, color: Colors.redAccent),
                          label: const Text('Stop'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              ErrorDisplay(title: 'Ping Notice', message: _errorMessage!),
              const SizedBox(height: 16),
            ],

            // Resolved IP Badge
            if (_resolvedIp != null) ...[
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 10),
                    Text('Resolved IP Address: ', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                    SelectableText(_resolvedIp!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Live Packet Stream
            if (_samples.isNotEmpty) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Live Packet Stream', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_samples.length}/$_packetCount sent', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                    ..._samples.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              s.success ? Icons.check : Icons.close,
                              size: 16,
                              color: s.success ? Colors.greenAccent : Colors.redAccent,
                            ),
                            const SizedBox(width: 10),
                            Text('Seq ${s.seq}:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.success ? 'Reply received in ${s.timeMs} ms' : (s.error ?? 'Timed out'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: s.success ? null : Colors.redAccent.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Summary Statistics Card
            if (_summary != null) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ping Statistics Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Packets stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('Packets Sent', _summary!.sent.toString(), Colors.blueAccent),
                        _statItem('Received', _summary!.received.toString(), Colors.greenAccent),
                        _statItem('Lost', '${_summary!.lost} (${_summary!.lossPercentage.toStringAsFixed(0)}%)',
                            _summary!.lost == 0 ? Colors.greenAccent : Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    // Round trip latency stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('Min Latency', _summary!.minLatencyMs != null ? '${_summary!.minLatencyMs} ms' : 'N/A', Colors.grey),
                        _statItem('Avg Latency', _summary!.avgLatencyMs != null ? '${_summary!.avgLatencyMs} ms' : 'N/A', theme.colorScheme.primary),
                        _statItem('Max Latency', _summary!.maxLatencyMs != null ? '${_summary!.maxLatencyMs} ms' : 'N/A', Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
