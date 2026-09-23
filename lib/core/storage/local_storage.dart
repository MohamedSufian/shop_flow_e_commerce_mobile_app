import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central place for everything we persist on-device.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboarding = 'onboarding_done';
  static const _kThemeMode = 'theme_mode';

  bool get isOnboardingDone => _prefs.getBool(_kOnboarding) ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool(_kOnboarding, true);

  ThemeMode get themeMode {
    switch (_prefs.getString(_kThemeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) => _prefs.setString(_kThemeMode, mode.name);

  // Recent searches (most recent first, max 8)
  static const _kRecent = 'recent_searches';
  List<String> get recentSearches => _prefs.getStringList(_kRecent) ?? const [];

  Future<List<String>> addRecentSearch(String q) async {
    final list = [q, ...recentSearches.where((e) => e.toLowerCase() != q.toLowerCase())].take(8).toList();
    await _prefs.setStringList(_kRecent, list);
    return list;
  }

  Future<List<String>> removeRecentSearch(String q) async {
    final list = recentSearches.where((e) => e != q).toList();
    await _prefs.setStringList(_kRecent, list);
    return list;
  }

  Future<void> clearRecentSearches() => _prefs.remove(_kRecent);

  // Generic helpers — used later for favorites, cart & address.
  List<String> getStringList(String key) => _prefs.getStringList(key) ?? const [];
  Future<void> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);
  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
}
