import '../models/history_item.dart';

abstract class ILocalStorageService {
  Future<void> init();

  // Favorites
  Future<bool> saveFavorite(String id);
  Future<bool> removeFavorite(String id);
  List<String> getFavorites();
  bool isFavorite(String id);
  Future<void> clearFavorites();

  // History
  Future<void> saveHistory(HistoryItem item);
  List<HistoryItem> getHistory();
  Future<void> clearHistory();

  // Theme
  Future<void> saveTheme(String themeMode);
  String getTheme();

  // Checklist State
  Future<void> saveChecklistState(String checklistId, Set<String> completedStepIds);
  Set<String> getChecklistState(String checklistId);
  Future<void> saveChecklistNote(String checklistId, String note);
  String getChecklistNote(String checklistId);
  Future<void> resetChecklistState(String checklistId);

  // Settings
  Future<void> saveStartPage(String route);
  String getStartPage();
  Future<void> saveCompactCards(bool enabled);
  bool getCompactCards();
  Future<void> saveShowRecentTools(bool enabled);
  bool getShowRecentTools();

  // Reset
  Future<void> resetAllData();
}
