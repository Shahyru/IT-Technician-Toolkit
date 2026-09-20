import 'package:flutter/material.dart';
import '../../../core/services/network_speed_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/result_card.dart';
import '../../../core/widgets/favorite_button.dart';

class NetworkSpeedScreen extends StatefulWidget {
  const NetworkSpeedScreen({super.key});

  @override
  State<NetworkSpeedScreen> createState() => _NetworkSpeedScreenState();
}

class _NetworkSpeedScreenState extends State<NetworkSpeedScreen> {
  final TextEditingController _fileSizeController = TextEditingController(text: '10');
  String _fileUnit = 'GB';

  final TextEditingController _speedController = TextEditingController(text: '100');
  String _speedUnit = 'Mbps';

  double _efficiency = 90.0;

  NetworkSpeedResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _fileSizeController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  void _calculate() {
    final size = double.tryParse(_fileSizeController.text.trim()) ?? 0.0;
    final speed = double.tryParse(_speedController.text.trim()) ?? 1.0;

    if (size >= 0 && speed > 0) {
      setState(() {
        _result = NetworkSpeedService.calculate(
          fileSize: size,
          fileUnit: _fileUnit,
          networkSpeed: speed,
          speedUnit: _speedUnit,
          efficiencyPercentage: _efficiency,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Speed & Transfer Time'),
        actions: const [
          FavoriteButton(itemId: 'tool-network-speed'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Inputs Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('File & Connection Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  // File size row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _fileSizeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'File / Payload Size', prefixIcon: Icon(Icons.folder_zip_outlined)),
                          onChanged: (_) => _calculate(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _fileUnit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: const [
                            DropdownMenuItem(value: 'MB', child: Text('MB (decimal)')),
                            DropdownMenuItem(value: 'GB', child: Text('GB (decimal)')),
                            DropdownMenuItem(value: 'TB', child: Text('TB (decimal)')),
                            DropdownMenuItem(value: 'MiB', child: Text('MiB (binary)')),
                            DropdownMenuItem(value: 'GiB', child: Text('GiB (binary)')),
                            DropdownMenuItem(value: 'TiB', child: Text('TiB (binary)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _fileUnit = val);
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Speed row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _speedController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Network Bandwidth', prefixIcon: Icon(Icons.speed_outlined)),
                          onChanged: (_) => _calculate(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _speedUnit,
                          decoration: const InputDecoration(labelText: 'Speed Unit'),
                          items: const [
                            DropdownMenuItem(value: 'Kbps', child: Text('Kbps')),
                            DropdownMenuItem(value: 'Mbps', child: Text('Mbps')),
                            DropdownMenuItem(value: 'Gbps', child: Text('Gbps')),
                            DropdownMenuItem(value: 'KB/s', child: Text('KB/s')),
                            DropdownMenuItem(value: 'MB/s', child: Text('MB/s')),
                            DropdownMenuItem(value: 'GB/s', child: Text('GB/s')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _speedUnit = val);
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Real-world network efficiency slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TCP Overhead / Real-World Efficiency:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${_efficiency.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                  Slider(
                    value: _efficiency,
                    min: 50,
                    max: 100,
                    divisions: 50,
                    label: '${_efficiency.toInt()}%',
                    onChanged: (val) {
                      setState(() => _efficiency = val);
                      _calculate();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_result != null) ...[
              // Highlight banner
              AppCard(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                borderColor: theme.colorScheme.primary.withOpacity(0.3),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated Transfer Duration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    SelectableText(
                      _result!.formattedTime,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'At ${_result!.actualSpeedMBs.toStringAsFixed(2)} MB/s actual throughput (${_efficiency.toInt()}% efficiency)',
                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ResultCard(
                title: 'Throughput Metrics',
                rows: [
                  ResultRowData(label: 'Theoretical Link Speed', value: '${_result!.theoreticalSpeedMbps.toStringAsFixed(2)} Mbps (${_result!.theoreticalSpeedMBs.toStringAsFixed(2)} MB/s)'),
                  ResultRowData(label: 'Expected Actual Speed', value: '${_result!.actualSpeedMbps.toStringAsFixed(2)} Mbps (${_result!.actualSpeedMBs.toStringAsFixed(2)} MB/s)', valueColor: Colors.greenAccent),
                  ResultRowData(label: 'Estimated Seconds', value: '${_result!.totalSeconds.toStringAsFixed(1)} seconds'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
