import 'package:flutter/material.dart';
import '../../../core/services/storage_calculator_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/result_card.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/favorite_button.dart';

class StorageCalculatorScreen extends StatefulWidget {
  const StorageCalculatorScreen({super.key});

  @override
  State<StorageCalculatorScreen> createState() => _StorageCalculatorScreenState();
}

class _StorageCalculatorScreenState extends State<StorageCalculatorScreen> {
  RaidMode _mode = RaidMode.raid5;
  int _driveCount = 4;
  double _driveCapacity = 4.0; // in TB
  final String _unit = 'TB';

  StorageCalculationResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    setState(() => _errorMessage = null);
    try {
      final res = StorageCalculatorService.calculate(
        mode: _mode,
        driveCount: _driveCount,
        driveCapacity: _driveCapacity,
      );
      setState(() => _result = res);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('FormatException: ', '');
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage & RAID Calculator'),
        actions: const [
          FavoriteButton(itemId: 'tool-storage-calc'),
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
                  const Text('Array Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  // RAID Mode dropdown
                  DropdownButtonFormField<RaidMode>(
                    value: _mode,
                    decoration: const InputDecoration(labelText: 'RAID Mode / Configuration'),
                    items: RaidMode.values.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m.displayName));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _mode = val;
                          if (_driveCount < _mode.minDrives) {
                            _driveCount = _mode.minDrives;
                          }
                          if (_mode == RaidMode.raid10 && _driveCount % 2 != 0) {
                            _driveCount = 4;
                          }
                        });
                        _calculate();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Number of Drives
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _driveCount,
                          decoration: const InputDecoration(labelText: 'Drive Count'),
                          items: List.generate(24, (i) => i + 1).where((n) {
                            if (n < _mode.minDrives) return false;
                            if (_mode == RaidMode.raid10 && n % 2 != 0) return false;
                            return true;
                          }).map((n) {
                            return DropdownMenuItem(value: n, child: Text('$n Drives'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _driveCount = val);
                              _calculate();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Drive Capacity
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: _driveCapacity,
                          decoration: InputDecoration(labelText: 'Per-Drive Capacity ($_unit)'),
                          items: const [
                            DropdownMenuItem(value: 0.5, child: Text('500 GB / 0.5 TB')),
                            DropdownMenuItem(value: 1.0, child: Text('1 TB')),
                            DropdownMenuItem(value: 2.0, child: Text('2 TB')),
                            DropdownMenuItem(value: 4.0, child: Text('4 TB')),
                            DropdownMenuItem(value: 8.0, child: Text('8 TB')),
                            DropdownMenuItem(value: 12.0, child: Text('12 TB')),
                            DropdownMenuItem(value: 16.0, child: Text('16 TB')),
                            DropdownMenuItem(value: 20.0, child: Text('20 TB')),
                            DropdownMenuItem(value: 24.0, child: Text('24 TB')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _driveCapacity = val);
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              ErrorDisplay(title: 'Configuration Error', message: _errorMessage!),
              const SizedBox(height: 16),
            ],

            if (_result != null) ...[
              // Usable Capacity Main Banner
              AppCard(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                borderColor: theme.colorScheme.primary.withOpacity(0.3),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated Usable Storage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _result!.usableCapacity.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$_unit (${_result!.efficiencyPercentage.toStringAsFixed(0)}% Storage Efficiency)',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _result!.efficiencyPercentage / 100.0,
                      backgroundColor: theme.colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detail Statistics
              ResultCard(
                title: 'Storage & Redundancy Breakdown',
                rows: [
                  ResultRowData(label: 'Total Raw Capacity', value: '${_result!.rawCapacity.toStringAsFixed(1)} $_unit'),
                  ResultRowData(label: 'Usable Space', value: '${_result!.usableCapacity.toStringAsFixed(1)} $_unit', valueColor: Colors.greenAccent),
                  ResultRowData(label: 'Parity / Mirroring', value: '${_result!.redundancyCapacity.toStringAsFixed(1)} $_unit'),
                  ResultRowData(label: 'Capacity Overhead', value: '${_result!.capacityLoss.toStringAsFixed(1)} $_unit'),
                  ResultRowData(label: 'Fault Tolerance', value: _result!.faultTolerance, isMonospace: false),
                ],
              ),
              const SizedBox(height: 16),

              // RAID Architectural Note
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Engineering Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _result!.note,
                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Calculations are theoretical estimates. File systems (NTFS, EXT4, ZFS, Btrfs), sector formatting, and filesystem metadata reserve an additional 2-5% capacity.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
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
}
