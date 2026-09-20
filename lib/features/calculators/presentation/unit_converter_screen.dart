import 'package:flutter/material.dart';
import '../../../core/services/unit_conversion_service.dart';
import '../../../core/utils/clipboard_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/favorite_button.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  ConversionCategory _selectedCategory = ConversionCategory.data;
  final TextEditingController _fromController = TextEditingController(text: '1');
  final TextEditingController _toController = TextEditingController();

  String _fromUnit = 'GB (decimal)';
  String _toUnit = 'GiB (binary)';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _updateAvailableUnits();
    _convert(isFromSource: true);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _updateAvailableUnits() {
    final units = UnitConversionService.getUnitsForCategory(_selectedCategory);
    if (!units.contains(_fromUnit)) _fromUnit = units.first;
    if (!units.contains(_toUnit)) {
      _toUnit = units.length > 1 ? units[1] : units.first;
    }
  }

  void _convert({required bool isFromSource}) {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      final inputVal = double.tryParse(
        isFromSource ? _fromController.text.trim() : _toController.text.trim(),
      );

      if (inputVal == null) {
        if (isFromSource) {
          _toController.clear();
        } else {
          _fromController.clear();
        }
        _isUpdating = false;
        return;
      }

      final result = UnitConversionService.convert(
        category: _selectedCategory,
        value: inputVal,
        fromUnit: isFromSource ? _fromUnit : _toUnit,
        toUnit: isFromSource ? _toUnit : _fromUnit,
      );

      String formatted;
      if (result.abs() >= 1e6 || (result.abs() > 0 && result.abs() < 1e-4)) {
        formatted = result.toStringAsExponential(4);
      } else {
        formatted = result.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
      }

      setState(() {
        if (isFromSource) {
          _toController.text = formatted;
        } else {
          _fromController.text = formatted;
        }
      });
    } catch (_) {
      // Ignored for partial inputs
    } finally {
      _isUpdating = false;
    }
  }

  void _swapUnits() {
    setState(() {
      final tempUnit = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tempUnit;
    });
    _convert(isFromSource: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = UnitConversionService.getUnitsForCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        actions: const [
          FavoriteButton(itemId: 'tool-unit-converter'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ConversionCategory.values.map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.displayName),
                      selected: selected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategory = cat;
                            _updateAvailableUnits();
                          });
                          _convert(isFromSource: true);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Conversion Interactive Card
            AppCard(
              child: Column(
                children: [
                  // FROM Unit Field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _fromController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          decoration: const InputDecoration(labelText: 'From Value'),
                          onChanged: (_) => _convert(isFromSource: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _fromUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: units.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _fromUnit = val);
                              _convert(isFromSource: true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Swap Button
                  IconButton(
                    icon: const Icon(Icons.swap_vert_circle, size: 36),
                    color: theme.colorScheme.primary,
                    tooltip: 'Swap Units',
                    onPressed: _swapUnits,
                  ),
                  const SizedBox(height: 8),

                  // TO Unit Field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _toController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.primary,
                          ),
                          decoration: const InputDecoration(labelText: 'To Value'),
                          onChanged: (_) => _convert(isFromSource: false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _toUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: units.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _toUnit = val);
                              _convert(isFromSource: true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy Result'),
                        onPressed: () => ClipboardUtils.copyWithFeedback(
                          context,
                          '${_toController.text} $_toUnit',
                          message: 'Converted value copied',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Reference Overview Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedCategory.displayName} Quick Guide',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  if (_selectedCategory == ConversionCategory.data) ...[
                    _guideItem('Decimal Units (10^3)', '1 KB = 1,000 Bytes | 1 MB = 1,000,000 Bytes | 1 GB = 1,000,000,000 Bytes'),
                    _guideItem('Binary Units (2^10)', '1 KiB = 1,024 Bytes | 1 MiB = 1,048,576 Bytes | 1 GiB = 1,073,741,824 Bytes'),
                    _guideItem('Storage vs OS', 'Drive makers advertise decimal GB/TB. Windows displays binary GiB/TiB (explaining "missing" space).'),
                  ] else if (_selectedCategory == ConversionCategory.network) ...[
                    _guideItem('Bits vs Bytes', '8 bits (b) = 1 Byte (B). Network bandwidth is in bits/sec, file size is in Bytes.'),
                    _guideItem('Throughput Rule', 'A 100 Mbps broadband connection theoretically downloads at max ~12.5 MB/s.'),
                  ] else if (_selectedCategory == ConversionCategory.temperature) ...[
                    _guideItem('Formulas', '°F = (°C × 9/5) + 32 | K = °C + 273.15'),
                  ] else ...[
                    _guideItem('Metric standard', 'Standard SI conversion factors applied.'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
