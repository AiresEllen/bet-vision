import 'package:shared_preferences/shared_preferences.dart';

import '../models/analysis_settings.dart';

class LocalStorageService {
  static const _favoriteIdsKey = 'betvision.favoriteIds';
  static const _analysisSettingsKey = 'betvision.analysisSettings';

  Future<Set<String>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_favoriteIdsKey) ?? const <String>[];
    return values.toSet();
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteIdsKey, ids.toList()..sort());
  }

  Future<AnalysisSettings> loadAnalysisSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_analysisSettingsKey);
    if (raw == null || raw.isEmpty) {
      return const AnalysisSettings();
    }

    try {
      return AnalysisSettings.fromJson(raw);
    } catch (_) {
      return const AnalysisSettings();
    }
  }

  Future<void> saveAnalysisSettings(AnalysisSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_analysisSettingsKey, settings.toJson());
  }
}
