import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../core/utils/translation_constants.dart';
import '../../../core/utils/navigator_service.dart';
import '../../../providers/app_language_provider.dart';
import '../language_selection_screen.dart';

// ignore_for_file: must_be_immutable
class LanguageSelectionProvider extends ChangeNotifier {
  bool _isLanguageMenuExpanded = false;

  LanguageSelectionProvider() {
    initialize();
  }

  bool get isLanguageMenuExpanded => _isLanguageMenuExpanded;

  void initialize() {
    // Provider initialization logic if needed
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    // Use the global AppLanguageProvider for language changes
    final appLanguageProvider = Provider.of<AppLanguageProvider>(
      NavigatorService.navigatorKey.currentContext!,
      listen: false,
    );
    
    appLanguageProvider.setLanguage(languageCode);
    notifyListeners();
    
    // Show confirmation message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (NavigatorService.navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(NavigatorService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(
              _getLanguageChangeMessage(languageCode),
            ),
            backgroundColor: appTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  String _getLanguageChangeMessage(String languageCode) {
    switch (languageCode) {
      case AppTranslations.english:
        return 'Language changed to English successfully';
      case AppTranslations.arabic:
        return 'تم تغيير اللغة إلى العربية بنجاح';
      default: // French
        return 'Langue changée en français avec succès';
    }
  }

  void toggleLanguageMenu() {
    _isLanguageMenuExpanded = !_isLanguageMenuExpanded;
    notifyListeners();
  }

  void expandLanguageMenu() {
    _isLanguageMenuExpanded = true;
    notifyListeners();
  }

  void collapseLanguageMenu() {
    _isLanguageMenuExpanded = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}