import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/models/port_item.dart';

class PortRepository {
  static List<PortItem>? _cachedPorts;

  static Future<List<PortItem>> getPorts() async {
    if (_cachedPorts != null) return _cachedPorts!;
    try {
      final jsonStr = await rootBundle.loadString('assets/networking/ports.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedPorts = list.map((e) => PortItem.fromJson(e as Map<String, dynamic>)).toList();
      return _cachedPorts!;
    } catch (_) {
      return [];
    }
  }

  static void setMockPorts(List<PortItem> ports) {
    _cachedPorts = ports;
  }
}
