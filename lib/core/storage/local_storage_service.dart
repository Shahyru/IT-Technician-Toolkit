import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/history_item.dart';
import 'storage_interface.dart';

class LocalStorageService implements ILocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Testing helper to inject mock prefs
  void setPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }

  SharedPreferences get _requirePrefs {
    if (_prefs == null) {
      throw StateError('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // --- Favorites ---

  @override
  Future<bool> saveFavorite(String id) async {
    final favorites = getFavorites().toSet();
    final added = favorites.add(id);
    if (added) {
      await _requirePrefs.setStringList(AppConstants.keyFavorites, favorites.toList());
    }
    return added;
  }

  @override
  Future<bool> removeFavorite(String id) async {
    final favorites = getFavorites().toSet();
    final removed = favorites.remove(id);
    if (removed) {
      await _requirePrefs.setStringList(AppConstants.keyFavorites, favorites.toList());
    }
    return removed;
  }

  @override
  List<String> getFavorites() {
    return _prefs?.getStringList(AppConstants.keyFavorites) ?? [];
  }

  @override
  bool isFavorite(String id) {
    return getFavorites().contains(id);
  }

  @override
  Future<void> clearFavorites() async {
    await _requirePrefs.remove(AppConstants.keyFavorites);
  }

  // --- History ---

  @override
  Future<void> saveHistory(HistoryItem item) async {
    final items = getHistory();
    // Remove duplicate entry if existing
    items.removeWhere((h) => h.id == item.id);
    // Insert at front
    items.insert(0, item);
    // Cap at max limit (50 items)
    if (items.length > AppConstants.maxHistoryItems) {
      items.removeRange(AppConstants.maxHistoryItems, items.length);
    }
    final encoded = items.map((e) => jsonEncode(e.toJson())).toList();
    await _requirePrefs.setStringList(AppConstants.keyHistory, encoded);
  }

  @override
  List<HistoryItem> getHistory() {
    final raw = _prefs?.getStringList(AppConstants.keyHistory) ?? [];
    final items = <HistoryItem>[];
    for (final str in raw) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        items.add(HistoryItem.fromJson(map));
      } catch (_) {}
    }
    return items;
  }

  @override
  Future<void> clearHistory() async {
    await _requirePrefs.remove(AppConstants.keyHistory);
  }

  // --- Theme ---

  @override
  Future<void> saveTheme(String themeMode) async {
    await _requirePrefs.setString(AppConstants.keyThemeMode, themeMode);
  }

  @override
  String getTheme() {
    return _prefs?.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  // --- Checklist State ---

  @override
  Future<void> saveChecklistState(String checklistId, Set<String> completedStepIds) async {
    final key = '${AppConstants.keyChecklistPrefix}$checklistId';
    await _requirePrefs.setStringList(key, completedStepIds.toList());
  }

  @override
  Set<String> getChecklistState(String checklistId) {
    final key = '${AppConstants.keyChecklistPrefix}$checklistId';
    return (_prefs?.getStringList(key) ?? []).toSet();
  }

  @override
  Future<void> saveChecklistNote(String checklistId, String note) async {
    final key = '${AppConstants.keyChecklistNotesPrefix}$checklistId';
    await _requirePrefs.setString(key, note);
  }

  @override
  String getChecklistNote(String checklistId) {
    final key = '${AppConstants.keyChecklistNotesPrefix}$checklistId';
    return _prefs?.getString(key) ?? '';
  }

  @override
  Future<void> resetChecklistState(String checklistId) async {
    await _requirePrefs.remove('${AppConstants.keyChecklistPrefix}$checklistId');
    await _requirePrefs.remove('${AppConstants.keyChecklistNotesPrefix}$checklistId');
  }

  // --- Settings ---

  @override
  Future<void> saveStartPage(String route) async {
    await _requirePrefs.setString(AppConstants.keyStartPage, route);
  }

  @override
  String getStartPage() {
    return _prefs?.getString(AppConstants.keyStartPage) ?? '/';
  }

  @override
  Future<void> saveCompactCards(bool enabled) async {
    await _requirePrefs.setBool(AppConstants.keyCompactCards, enabled);
  }

  @override
  bool getCompactCards() {
    return _prefs?.getBool(AppConstants.keyCompactCards) ?? false;
  }

  @override
  Future<void> saveShowRecentTools(bool enabled) async {
    await _requirePrefs.setBool(AppConstants.keyShowRecentTools, enabled);
  }

  @override
  bool getShowRecentTools() {
    return _prefs?.getBool(AppConstants.keyShowRecentTools) ?? true;
  }

  @override
  Future<void> resetAllData() async {
    await _requirePrefs.clear();
  }
}
