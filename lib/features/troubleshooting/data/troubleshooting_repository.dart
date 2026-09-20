import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/models/checklist_item.dart';

class TroubleshootingRepository {
  static List<ChecklistItem>? _cachedChecklists;

  static Future<List<ChecklistItem>> getChecklists() async {
    if (_cachedChecklists != null) return _cachedChecklists!;
    try {
      final jsonStr = await rootBundle.loadString('assets/troubleshooting/checklists.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedChecklists = list.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
      return _cachedChecklists!;
    } catch (_) {
      return [];
    }
  }

  static Future<ChecklistItem?> getChecklistById(String id) async {
    final checklists = await getChecklists();
    try {
      return checklists.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static void setMockChecklists(List<ChecklistItem> checklists) {
    _cachedChecklists = checklists;
  }
}
