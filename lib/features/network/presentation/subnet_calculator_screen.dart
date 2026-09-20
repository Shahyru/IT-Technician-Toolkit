import 'package:flutter/material.dart';
import '../../../core/services/subnet_calculator_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/favorite_button.dart';

class SubnetCalculatorScreen extends StatefulWidget {
  const SubnetCalculatorScreen({super.key});

  @override
  State<SubnetCalculatorScreen> createState() => _SubnetCalculatorScreenState();
}

class _SubnetCalculatorScreenState extends State<SubnetCalculatorScreen> {
  final TextEditingController _networkController = TextEditingController(text: '192.168.1.0');
  int _baseCidr = 24;
  int _targetCidr = 26;
  final TextEditingController _hostsController = TextEditingController();
  final TextEditingController _subnetsCountController = TextEditingController();

  List<SubnetEntry> _subnets = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _networkController.dispose();
    _hostsController.dispose();
    _subnetsCountController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _errorMessage = null);
    try {
      final list = SubnetCalculatorService.calculateSubnets(
        baseNetwork: _networkController.text.trim(),
        baseCidr: _baseCidr,
        targetCidr: _targetCidr,
      );
      setState(() => _subnets = list);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('FormatException: ', '');
        _subnets = [];
      });
    }
  }

  void _onHostsChanged(String val) {
    final hosts = int.tryParse(val.trim());
    if (hosts != null && hosts > 0) {
      final neededCidr = SubnetCalculatorService.cidrForHosts(hosts);
      if (neededCidr >= _baseCidr && neededCidr <= 32) {
        setState(() {
          _targetCidr = neededCidr;
        });
        _calculate();
      }
    }
  }

  void _onSubnetsCountChanged(String val) {
    final count = int.tryParse(val.trim());
    if (count != null && count > 0) {
      final neededCidr = SubnetCalculatorService.cidrForSubnets(_baseCidr, count);
      if (neededCidr >= _baseCidr && neededCidr <= 32) {
        setState(() {
          _targetCidr = neededCidr;
        });
        _calculate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subnet Planner & VLSM'),
        actions: const [
          FavoriteButton(itemId: 'tool-subnet-calc'),
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
                  const Text('Base Network Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _networkController,
                          decoration: const InputDecoration(
                            labelText: 'Base Network',
                            hintText: 'e.g. 192.168.1.0',
                            prefixIcon: Icon(Icons.hub_outlined),
                          ),
                          onChanged: (_) => _calculate(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int>(
                          value: _baseCidr,
                          decoration: const InputDecoration(labelText: 'Base CIDR'),
                          items: List.generate(33, (i) => DropdownMenuItem(value: i, child: Text('/$i'))),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _baseCidr = val;
                                if (_targetCidr < _baseCidr) {
                                  _targetCidr = _baseCidr;
                                }
                              });
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Target Subnet CIDR
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _targetCidr,
                          decoration: const InputDecoration(labelText: 'Target Subnet Mask (New CIDR)'),
                          items: List.generate(
                            33 - _baseCidr,
                            (i) {
                              final cidr = _baseCidr + i;
                              return DropdownMenuItem(
                                value: cidr,
                                child: Text('/$cidr (${1 << (32 - cidr)} addrs, ${(cidr == 32) ? 1 : ((1 << (32 - cidr)) - 2)} usable)'),
                              );
                            },
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _targetCidr = val);
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Sizers
                  const Text('Or Size Automatically by Requirements:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hostsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Required Hosts / Subnet',
                            hintText: 'e.g. 50',
                            prefixIcon: Icon(Icons.people_outline),
                          ),
                          onChanged: _onHostsChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _subnetsCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Required Subnets Count',
                            hintText: 'e.g. 4',
                            prefixIcon: Icon(Icons.view_column_outlined),
                          ),
                          onChanged: _onSubnetsCountChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              ErrorDisplay(title: 'Calculation Error', message: _errorMessage!),
              const SizedBox(height: 16),
            ],

            // Results Header
            if (_subnets.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated ${_subnets.length} Subnets (/$_targetCidr)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_subnets.first.usableHosts} Hosts / Subnet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Desktop: High-density Data Table
              if (isDesktop) ...[
                AppCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(theme.colorScheme.surface),
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Subnet / CIDR')),
                        DataColumn(label: Text('Mask')),
                        DataColumn(label: Text('Network IP')),
                        DataColumn(label: Text('Usable Range')),
                        DataColumn(label: Text('Broadcast IP')),
                        DataColumn(label: Text('Usable Hosts')),
                      ],
                      rows: _subnets.map((s) {
                        return DataRow(
                          cells: [
                            DataCell(Text(s.index.toString())),
                            DataCell(Text('${s.networkAddress}/${s.cidr}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(s.subnetMask, style: const TextStyle(fontFamily: 'monospace'))),
                            DataCell(Text(s.networkAddress, style: const TextStyle(fontFamily: 'monospace'))),
                            DataCell(Text('${s.firstHost} – ${s.lastHost}', style: const TextStyle(fontFamily: 'monospace'))),
                            DataCell(Text(s.broadcastAddress, style: const TextStyle(fontFamily: 'monospace'))),
                            DataCell(Text(s.usableHosts.toString(), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                // Mobile: Responsive Card Layout
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subnets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final s = _subnets[index];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${s.subnetName} (/${s.cidr})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${s.usableHosts} Usable',
                                  style: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          _mobileDetailRow('Network IP', s.networkAddress),
                          _mobileDetailRow('Usable Range', '${s.firstHost} - ${s.lastHost}'),
                          _mobileDetailRow('Broadcast', s.broadcastAddress),
                          _mobileDetailRow('Subnet Mask', s.subnetMask),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _mobileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          SelectableText(value, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
