import 'package:flutter/material.dart';
import '../../../core/services/mac_service.dart';
import '../../../core/utils/clipboard_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/result_card.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/favorite_button.dart';

class MacToolsScreen extends StatefulWidget {
  const MacToolsScreen({super.key});

  @override
  State<MacToolsScreen> createState() => _MacToolsScreenState();
}

class _MacToolsScreenState extends State<MacToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController(text: '00:1A:2B:3C:4D:5E');

  // Generator state
  MacGenerationType _genType = MacGenerationType.unicast;
  MacFormatType _genFormat = MacFormatType.colon;
  String _generatedMac = '';

  // Analysis result
  bool _isValid = true;
  String? _colonFormat;
  String? _hyphenFormat;
  String? _ciscoFormat;
  String? _rawFormat;
  String? _vendor;
  bool _isMulticast = false;
  bool _isLocal = false;
  String? _analysisError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    MacService.loadOuiDatabase().then((_) {
      if (mounted) _analyzeMac();
    });
    _generate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _analyzeMac() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _isValid = false;
        _analysisError = 'Please enter a MAC address';
      });
      return;
    }

    if (!MacService.isValid(input)) {
      setState(() {
        _isValid = false;
        _analysisError = 'Invalid MAC address format. Example: 00:1A:2B:3C:4D:5E';
      });
      return;
    }

    try {
      setState(() {
        _isValid = true;
        _analysisError = null;
        _colonFormat = MacService.format(input, MacFormatType.colon);
        _hyphenFormat = MacService.format(input, MacFormatType.hyphen);
        _ciscoFormat = MacService.format(input, MacFormatType.ciscoDot);
        _rawFormat = MacService.format(input, MacFormatType.rawHex);
        _vendor = MacService.lookupOui(input) ?? 'Unknown Vendor / Unregistered OUI';
        _isMulticast = MacService.isMulticast(input);
        _isLocal = MacService.isLocallyAdministered(input);
      });
    } catch (e) {
      setState(() {
        _isValid = false;
        _analysisError = e.toString();
      });
    }
  }

  void _generate() {
    setState(() {
      _generatedMac = MacService.generate(type: _genType, formatType: _genFormat);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MAC Address Tools'),
        actions: const [
          FavoriteButton(itemId: 'tool-mac-tools'),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Validator & Formatter'),
            Tab(icon: Icon(Icons.casino_outlined), text: 'MAC Generator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Validator, Formatter & OUI Lookup
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MAC Address Input', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          labelText: 'MAC Address',
                          hintText: '00:1A:2B:3C:4D:5E or 00-1A-... or 001a.2b3c.4d5e',
                          prefixIcon: const Icon(Icons.fingerprint),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Load sample MAC',
                            onPressed: () {
                              _inputController.text = '00:0C:29:4F:8A:1B';
                              _analyzeMac();
                            },
                          ),
                        ),
                        onChanged: (_) => _analyzeMac(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (_analysisError != null) ...[
                  ErrorDisplay(title: 'MAC Validation Error', message: _analysisError!),
                  const SizedBox(height: 16),
                ],

                if (_isValid && _colonFormat != null) ...[
                  // Status Indicators
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          backgroundColor: Colors.greenAccent.withOpacity(0.08),
                          borderColor: Colors.greenAccent.withOpacity(0.3),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                              SizedBox(width: 8),
                              Text('Valid MAC Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Text(
                            _isMulticast ? 'Multicast / Broadcast' : 'Unicast Address',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // OUI Vendor Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.06),
                    borderColor: theme.colorScheme.primary.withOpacity(0.25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('OUI Vendor Lookup (Offline)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        SelectableText(
                          _vendor ?? 'Searching...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLocal
                            ? 'Locally Administered Address (LAA - Bit 1 set)'
                            : 'Universally Administered Address (UAA - IEEE Standard)',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Formatted Outputs Card
                  ResultCard(
                    title: 'Formatted MAC Formats',
                    rows: [
                      ResultRowData(label: 'Standard Colon (Linux/Unix)', value: _colonFormat!),
                      ResultRowData(label: 'Hyphen (Windows)', value: _hyphenFormat!),
                      ResultRowData(label: 'Cisco Dot Notation', value: _ciscoFormat!),
                      ResultRowData(label: 'Raw Hex', value: _rawFormat!),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Tab 2: Random Generator
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MAC Generation Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      // Type selector
                      DropdownButtonFormField<MacGenerationType>(
                        value: _genType,
                        decoration: const InputDecoration(labelText: 'Address Mode'),
                        items: const [
                          DropdownMenuItem(
                            value: MacGenerationType.unicast,
                            child: Text('Unicast (Standard Network Device)'),
                          ),
                          DropdownMenuItem(
                            value: MacGenerationType.locallyAdministered,
                            child: Text('Locally Administered (Safe for VMs/VLANs)'),
                          ),
                          DropdownMenuItem(
                            value: MacGenerationType.random,
                            child: Text('Pure Random'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _genType = val);
                            _generate();
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Format selector
                      DropdownButtonFormField<MacFormatType>(
                        value: _genFormat,
                        decoration: const InputDecoration(labelText: 'Output Format'),
                        items: const [
                          DropdownMenuItem(value: MacFormatType.colon, child: Text('Standard Colon (00:11:22:33:44:55)')),
                          DropdownMenuItem(value: MacFormatType.hyphen, child: Text('Hyphen (00-11-22-33-44-55)')),
                          DropdownMenuItem(value: MacFormatType.ciscoDot, child: Text('Cisco Dot (0011.2233.4455)')),
                          DropdownMenuItem(value: MacFormatType.rawHex, child: Text('Raw Hex (001122334455)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _genFormat = val);
                            _generate();
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      ElevatedButton.icon(
                        onPressed: _generate,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate MAC Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Generated Output Display
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Generated Address', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      SelectableText(
                        _generatedMac,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy MAC'),
                            onPressed: () => ClipboardUtils.copyWithFeedback(
                              context,
                              _generatedMac,
                              message: 'MAC address copied to clipboard',
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.send, size: 16),
                            label: const Text('Send to Validator'),
                            onPressed: () {
                              _inputController.text = _generatedMac;
                              _tabController.animateTo(0);
                              _analyzeMac();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
