import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global language provider for reactive language management across the entire app
/// This provider manages the current language state and persists it to shared preferences
class AppLanguageProvider extends ChangeNotifier {
  AppLanguageProvider() {
    _initialize();
  }

  // Current language code
  String _currentLanguage = 'fr'; // Default to French
  static const String _kLanguageKey = 'app_language';

  /// Get the current language code
  String get currentLanguage => _currentLanguage;

  /// Initialize the provider by loading saved language from shared preferences
  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_kLanguageKey) ?? 'fr';
      await setLanguage(savedLanguage, saveToPreferences: false);
    } catch (e) {
      // Fallback to French if there's an error loading preferences
      _currentLanguage = 'fr';
      notifyListeners();
    }
  }

  /// Change the app language and notify all listeners
  /// 
  /// [languageCode] should be one of: 'fr', 'en', 'ar'
  /// [saveToPreferences] determines whether to persist the language choice
  Future<void> setLanguage(
    String languageCode, {
    bool saveToPreferences = true,
  }) async {
    // Validate language code
    if (!['fr', 'en', 'ar'].contains(languageCode)) {
      debugPrint('Invalid language code: $languageCode');
      return;
    }

    // Update the current language
    final previousLanguage = _currentLanguage;
    _currentLanguage = languageCode;

    // Save to shared preferences if requested
    if (saveToPreferences) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kLanguageKey, languageCode);
      } catch (e) {
        debugPrint('Error saving language preference: $e');
      }
    }

    // Notify all listeners only if language actually changed
    if (previousLanguage != _currentLanguage) {
      notifyListeners();
      debugPrint('Language changed from $previousLanguage to $_currentLanguage');
    }
  }

  /// Check if current language is French
  bool get isFrench => _currentLanguage == 'fr';

  /// Check if current language is English
  bool get isEnglish => _currentLanguage == 'en';

  /// Check if current language is Arabic (RTL)
  bool get isArabic => _currentLanguage == 'ar';

  /// Check if current language is RTL (Arabic)
  bool get isRTL => _currentLanguage == 'ar';

  /// Get the display name of the current language
  String get currentLanguageDisplayName {
    switch (_currentLanguage) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default: // 'fr'
        return 'Français';
    }
  }

  /// Get the localized language name for a given code
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default: // 'fr'
        return 'Français';
    }
  }

  /// Reset language to default (French)
  Future<void> resetToDefault() async {
    await setLanguage('fr');
  }

  /// Get the current locale for the app
  Locale getCurrentLocale() {
    switch (_currentLanguage) {
      case 'en':
        return const Locale('en');
      case 'ar':
        return const Locale('ar');
      default: // 'fr'
        return const Locale('fr');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}