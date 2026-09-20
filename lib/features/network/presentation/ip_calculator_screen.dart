import 'package:flutter/material.dart';
import '../../../core/services/ip_calculator_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/result_card.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/favorite_button.dart';

class IpCalculatorScreen extends StatefulWidget {
  const IpCalculatorScreen({super.key});

  @override
  State<IpCalculatorScreen> createState() => _IpCalculatorScreenState();
}

class _IpCalculatorScreenState extends State<IpCalculatorScreen> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.100');
  final TextEditingController _maskController = TextEditingController(text: '255.255.255.0');
  int _selectedCidr = 24;
  bool _useCidrInput = true;

  IpCalculationResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _maskController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
    });

    final ipInput = _ipController.text.trim();
    if (ipInput.isEmpty) {
      setState(() => _errorMessage = 'Please enter an IPv4 address');
      return;
    }

    try {
      if (_useCidrInput) {
        _result = IpCalculatorService.calculate(ipInput, cidrInput: _selectedCidr);
      } else {
        _result = IpCalculatorService.calculate(ipInput, maskInput: _maskController.text);
        if (_result != null) {
          _selectedCidr = _result!.cidr;
        }
      }
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
        title: const Text('IPv4 Subnet Calculator'),
        actions: const [
          FavoriteButton(itemId: 'tool-ip-calc'),
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
                  const Text(
                    'Network Parameters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // IP Address Field
                  TextFormField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address (or IP/CIDR)',
                      hintText: 'e.g. 192.168.1.100 or 10.0.0.1/24',
                      prefixIcon: Icon(Icons.computer_outlined),
                    ),
                    onChanged: (val) {
                      if (val.contains('/')) {
                        final parts = val.split('/');
                        final c = int.tryParse(parts[1]);
                        if (c != null && c >= 0 && c <= 32) {
                          _selectedCidr = c;
                          _useCidrInput = true;
                        }
                      }
                      _calculate();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mode Toggle: CIDR Slider vs Mask Field
                  Row(
                    children: [
                      const Text('Mask Format:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('CIDR (/xx)'),
                        selected: _useCidrInput,
                        onSelected: (val) {
                          setState(() {
                            _useCidrInput = true;
                            _maskController.text = IpCalculatorService.cidrToSubnetMask(_selectedCidr);
                          });
                          _calculate();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Subnet Mask'),
                        selected: !_useCidrInput,
                        onSelected: (val) {
                          setState(() {
                            _useCidrInput = false;
                          });
                          _calculate();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_useCidrInput) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Prefix: /$_selectedCidr', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          IpCalculatorService.cidrToSubnetMask(_selectedCidr),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _selectedCidr.toDouble(),
                      min: 0,
                      max: 32,
                      divisions: 32,
                      label: '/$_selectedCidr',
                      onChanged: (val) {
                        setState(() {
                          _selectedCidr = val.toInt();
                          _maskController.text = IpCalculatorService.cidrToSubnetMask(_selectedCidr);
                        });
                        _calculate();
                      },
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _maskController,
                      decoration: const InputDecoration(
                        labelText: 'Subnet Mask',
                        hintText: 'e.g. 255.255.255.0',
                        prefixIcon: Icon(Icons.grid_4x4_outlined),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              ErrorDisplay(
                title: 'Invalid IP or Mask Input',
                message: _errorMessage!,
              ),
              const SizedBox(height: 16),
            ],

            if (_result != null) ...[
              // Summary Badge Row
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                      borderColor: theme.colorScheme.primary.withOpacity(0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Classification', style: TextStyle(fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            _result!.scope,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.08),
                      borderColor: theme.colorScheme.secondary.withOpacity(0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Class', style: TextStyle(fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            _result!.ipClass,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Network Addresses Result Card
              ResultCard(
                title: 'Network & Host Boundaries',
                rows: [
                  ResultRowData(label: 'IP Address', value: _result!.ipAddress),
                  ResultRowData(label: 'Subnet Mask', value: _result!.subnetMask),
                  ResultRowData(label: 'CIDR Prefix', value: '/${_result!.cidr}'),
                  ResultRowData(label: 'Network Address', value: _result!.networkAddress),
                  ResultRowData(label: 'Broadcast Address', value: _result!.broadcastAddress),
                  ResultRowData(label: 'First Usable Host', value: _result!.firstUsableHost),
                  ResultRowData(label: 'Last Usable Host', value: _result!.lastUsableHost),
                  ResultRowData(label: 'Total Addresses', value: _result!.totalAddresses.toString()),
                  ResultRowData(
                    label: 'Usable Hosts',
                    value: _result!.usableHosts.toString(),
                    valueColor: Colors.greenAccent,
                  ),
                  ResultRowData(label: 'Wildcard Mask', value: _result!.wildcardMask),
                ],
              ),
              const SizedBox(height: 16),

              // Binary Representation Card
              ResultCard(
                title: 'Binary Structure',
                rows: [
                  ResultRowData(label: 'Binary IP', value: _result!.binaryIp),
                  ResultRowData(label: 'Binary Mask', value: _result!.binarySubnetMask),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
