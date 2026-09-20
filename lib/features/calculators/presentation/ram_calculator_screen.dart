import 'package:flutter/material.dart';
import '../../../core/services/ram_calculator_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/result_card.dart';
import '../../../core/widgets/favorite_button.dart';

class RamCalculatorScreen extends StatefulWidget {
  const RamCalculatorScreen({super.key});

  @override
  State<RamCalculatorScreen> createState() => _RamCalculatorScreenState();
}

class _RamCalculatorScreenState extends State<RamCalculatorScreen> {
  final List<RamModule> _modules = [
    RamModule(id: '1', capacity: 8, unit: 'GB'),
    RamModule(id: '2', capacity: 8, unit: 'GB'),
    RamModule(id: '3', capacity: 16, unit: 'GB'),
  ];

  int _nextId = 4;

  void _addModule() {
    setState(() {
      _modules.add(RamModule(id: '$_nextId', capacity: 16, unit: 'GB'));
      _nextId++;
    });
  }

  void _removeModule(int index) {
    if (_modules.length <= 1) return;
    setState(() {
      _modules.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalGb = RamCalculatorService.calculateTotalInGb(_modules);
    final conversions = RamCalculatorService.getFormattedConversions(totalGb);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RAM & Memory Calculator'),
        actions: const [
          FavoriteButton(itemId: 'tool-ram-calc'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total RAM Summary Banner
            AppCard(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              borderColor: theme.colorScheme.primary.withOpacity(0.3),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Installed Memory', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        totalGb.toStringAsFixed(totalGb.truncateToDouble() == totalGb ? 0 : 2),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('GB (${_modules.length} DIMM Modules)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Modules dynamic adder
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('DIMM Slots & Memory Modules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add DIMM Slot'),
                        onPressed: _addModule,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  ..._modules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final mod = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<double>(
                              value: mod.capacity,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('1')),
                                DropdownMenuItem(value: 2, child: Text('2')),
                                DropdownMenuItem(value: 4, child: Text('4')),
                                DropdownMenuItem(value: 8, child: Text('8')),
                                DropdownMenuItem(value: 16, child: Text('16')),
                                DropdownMenuItem(value: 32, child: Text('32')),
                                DropdownMenuItem(value: 64, child: Text('64')),
                                DropdownMenuItem(value: 128, child: Text('128')),
                                DropdownMenuItem(value: 256, child: Text('256')),
                                DropdownMenuItem(value: 512, child: Text('512')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => mod.capacity = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: mod.unit,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                              items: const [
                                DropdownMenuItem(value: 'GB', child: Text('GB')),
                                DropdownMenuItem(value: 'MB', child: Text('MB')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => mod.unit = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                            tooltip: 'Remove Module',
                            onPressed: _modules.length > 1 ? () => _removeModule(index) : null,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Conversions Table
            ResultCard(
              title: 'Memory Equivalent Values',
              rows: conversions.entries.map((e) {
                return ResultRowData(label: e.key, value: '${e.value} ${e.key}');
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
