import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/models/command_item.dart';

class ReferenceRepository {
  static List<CommandItem>? _cachedWindows;
  static List<CommandItem>? _cachedLinux;
  static List<CommandItem>? _cachedPowershell;

  static Future<List<CommandItem>> getWindowsCommands() async {
    if (_cachedWindows != null) return _cachedWindows!;
    try {
      final jsonStr = await rootBundle.loadString('assets/commands/windows.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedWindows = list.map((e) => CommandItem.fromJson(e as Map<String, dynamic>, platform: 'windows')).toList();
      return _cachedWindows!;
    } catch (_) {
      return [];
    }
  }

  static Future<List<CommandItem>> getLinuxCommands() async {
    if (_cachedLinux != null) return _cachedLinux!;
    try {
      final jsonStr = await rootBundle.loadString('assets/commands/linux.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedLinux = list.map((e) => CommandItem.fromJson(e as Map<String, dynamic>, platform: 'linux')).toList();
      return _cachedLinux!;
    } catch (_) {
      return [];
    }
  }

  static Future<List<CommandItem>> getPowerShellCommands() async {
    if (_cachedPowershell != null) return _cachedPowershell!;
    try {
      final jsonStr = await rootBundle.loadString('assets/commands/powershell.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedPowershell = list.map((e) => CommandItem.fromJson(e as Map<String, dynamic>, platform: 'powershell')).toList();
      return _cachedPowershell!;
    } catch (_) {
      return [];
    }
  }

  static Future<List<CommandItem>> getAllCommands() async {
    final win = await getWindowsCommands();
    final lin = await getLinuxCommands();
    final ps = await getPowerShellCommands();
    return [...win, ...lin, ...ps];
  }

  static void setMockData({
    List<CommandItem>? windows,
    List<CommandItem>? linux,
    List<CommandItem>? powershell,
  }) {
    if (windows != null) _cachedWindows = windows;
    if (linux != null) _cachedLinux = linux;
    if (powershell != null) _cachedPowershell = powershell;
  }
}
