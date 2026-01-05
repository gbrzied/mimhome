// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_language_provider.dart';

/// Translation constants for multilingual support
/// Supports French (default), English, and Arabic
/// Now integrated with AppLanguageProvider for reactive language management
class AppTranslations {
  // Language codes
  static const String french = 'fr';
  static const String english = 'en';
  static const String arabic = 'ar';

  // Legacy currentLanguage for backward compatibility
  // This will be deprecated in favor of AppLanguageProvider
  static String currentLanguage = french;

  /// Get current language from provider if available, fallback to static
  static String _getCurrentLanguage(BuildContext? context) {
    if (context != null) {
      try {
        final provider = Provider.of<AppLanguageProvider>(context, listen: false);
        return provider.currentLanguage;
      } catch (e) {
        // Provider not available, use static fallback
      }
    }
    return currentLanguage;
  }

  /// Get the current language from context or static fallback
  static String getCurrentLanguage([BuildContext? context]) {
    return _getCurrentLanguage(context);
  }



  // ===== UTILITY METHODS =====

  /// Set the current language (legacy method for backward compatibility)
  /// For new code, use AppLanguageProvider.setLanguage instead
  static void setLanguage(String languageCode) {
    if ([french, english, arabic].contains(languageCode)) {
      currentLanguage = languageCode;
    }
  }

  /// Get current language from provider (preferred method)
  /// This method will be used by new implementations
  static String getCurrentLanguageFromProvider(BuildContext context) {
    return Provider.of<AppLanguageProvider>(context, listen: false).currentLanguage;
  }

  /// Get localized string with fallback
  static String getLocalizedString(
    String frenchText,
    String englishText,
    String arabicText,
  ) {
    switch (currentLanguage) {
      case english:
        return englishText;
      case arabic:
        return arabicText;
      default: // French
        return frenchText;
    }
  }

  /// Check if current language is RTL (Arabic)
  /// Can be used with or without context
  static bool get isCurrentLanguageRTL {
    return currentLanguage == arabic;
  }

  /// Check if current language is RTL using provider
  /// Preferred method when context is available
  static bool isCurrentLanguageRTLFromProvider(BuildContext context) {
    return Provider.of<AppLanguageProvider>(context, listen: false).isRTL;
  }

  /// Get text direction for current language
  /// Can be used with or without context
  static TextDirection get textDirection {
    return isCurrentLanguageRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get text direction for current language using provider
  /// Preferred method when context is available
  static TextDirection textDirectionFromProvider(BuildContext context) {
    return Provider.of<AppLanguageProvider>(context, listen: false).isRTL 
        ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get text alignment for current language
  /// Can be used with or without context
  static TextAlign get textAlignment {
    return isCurrentLanguageRTL ? TextAlign.right : TextAlign.left;
  }

  /// Get text alignment for current language using provider
  /// Preferred method when context is available
  static TextAlign textAlignmentFromProvider(BuildContext context) {
    return Provider.of<AppLanguageProvider>(context, listen: false).isRTL 
        ? TextAlign.right : TextAlign.left;
  }

  // ===== LANGUAGE SELECTOR STRINGS =====

  /// Language selector title
  static String get language {
    switch (currentLanguage) {
      case english:
        return 'Language';
      case arabic:
        return 'اللغة';
      default: // French
        return 'Langue';
    }
  }

  /// Language selector subtitle
  static String get selectLanguage {
    switch (currentLanguage) {
      case english:
        return 'Select Language';
      case arabic:
        return 'اختر اللغة';
      default: // French
        return 'Choisir la langue';
    }
  }


}