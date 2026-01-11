import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../core/utils/translation_constants.dart';
import '../../../providers/app_language_provider.dart';
import 'provider/language_selection_provider.dart';

// ignore_for_file: must_be_immutable
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<LanguageSelectionProvider>(
      create: (context) => LanguageSelectionProvider(),
      child: const LanguageSelectionScreen(),
    );
  }

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguageSelectionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.selectLanguage),
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<LanguageSelectionProvider, AppLanguageProvider>(
        builder: (context, languageProvider, appLanguageProvider, child) {
          return Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.language,
                  style: TextStyleHelper.instance.title16SemiBoldManrope.copyWith(
                    fontSize: 18.fSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: ListView(
                    children: [
                      // Main Language Menu Item (Expandable)
                      _buildMainLanguageMenu(
                        context,
                        languageProvider,
                        appLanguageProvider,
                      ),
                      SizedBox(height: 8.h),
                      // Information Card
                      Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.all(16.h),
                        decoration: BoxDecoration(
                          color: appTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12.h),
                          border: Border.all(
                            color: appTheme.borderColor,
                            width: 1.h,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: appTheme.primaryColor,
                                  size: 20.h,
                                ),
                                SizedBox(width: 8.h),
                                Text(
                                  AppTranslations.getLocalizedString(
                                    'Information',
                                    'Information',
                                    'معلومات',
                                  ),
                                  style: TextStyleHelper.instance.label11MediumManrope.copyWith(
                                    fontSize: 14.fSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              AppTranslations.getLocalizedString(
                                'Le changement de langue sera appliqué immédiatement et affectera toute l\'application.',
                                'Language change will be applied immediately and will affect the entire application.',
                                'سيتم تطبيق تغيير اللغة فوراً وسيؤثر على كامل التطبيق.',
                              ),
                              style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                                fontSize: 12.fSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String languageCode,
    required String languageName,
    required String languageNameAr,
    required String languageNameEn,
    required IconData flagIcon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSubMenu = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(
          horizontal: isSubMenu ? 8.h : 16.h,
          vertical: isSubMenu ? 8.h : 16.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? appTheme.primaryColor.withValues(alpha: 0.1) : appTheme.surfaceColor,
          borderRadius: BorderRadius.circular(isSubMenu ? 8.h : 12.h),
          border: Border.all(
            color: isSelected ? appTheme.primaryColor : appTheme.borderColor.withValues(alpha: 0.5),
            width: isSelected ? 2.h : 1.h,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSubMenu ? 6.h : 8.h),
              decoration: BoxDecoration(
                color: isSelected ? appTheme.primaryColor : appTheme.onSurfaceVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isSubMenu ? 6.h : 8.h),
              ),
              child: Icon(
                flagIcon,
                color: isSelected ? Colors.white : appTheme.onSurfaceVariant,
                size: isSubMenu ? 16.h : 20.h,
              ),
            ),
            SizedBox(width: isSubMenu ? 12.h : 16.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLanguageDisplayName(languageCode, languageNameAr, languageNameEn),
                    style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                      fontSize: isSubMenu ? 14.fSize : 16.fSize,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? appTheme.primaryColor : appTheme.onSurface,
                    ),
                  ),
                  if (!isSubMenu) ...[
                    SizedBox(height: 2.h),
                    Text(
                      languageCode.toUpperCase(),
                      style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                        fontSize: 12.fSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: appTheme.primaryColor,
                size: isSubMenu ? 20.h : 24.h,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: appTheme.onSurfaceVariant,
                size: isSubMenu ? 20.h : 24.h,
              ),
          ],
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode, String languageNameAr, String languageNameEn) {
    switch (languageCode) {
      case AppTranslations.english:
        return languageNameEn;
      case AppTranslations.arabic:
        return languageNameAr;
      default: // French
        return 'Français';
    }
  }

  Widget _buildMainLanguageMenu(
    BuildContext context,
    LanguageSelectionProvider languageProvider,
    AppLanguageProvider appLanguageProvider,
  ) {
    // Get current selected language display name
    String currentLanguageName = _getCurrentLanguageDisplayName(appLanguageProvider.currentLanguage);
    
    return Container(
      decoration: BoxDecoration(
        color: appTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: appTheme.borderColor,
          width: 1.h,
        ),
      ),
      child: Column(
        children: [
          // Main Language Menu Item
          GestureDetector(
            onTap: languageProvider.toggleLanguageMenu,
            child: Container(
              padding: EdgeInsets.all(16.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      color: appTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: Icon(
                      Icons.language,
                      color: appTheme.primaryColor,
                      size: 20.h,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.language,
                          style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                            fontSize: 16.fSize,
                            fontWeight: FontWeight.w500,
                            color: appTheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          currentLanguageName,
                          style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                            fontSize: 12.fSize,
                            color: appTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: languageProvider.isLanguageMenuExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: appTheme.onSurfaceVariant,
                      size: 24.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Animated Language Options Submenu
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: languageProvider.isLanguageMenuExpanded ? null : 0,
            child: ClipRect(
              child: Offstage(
                offstage: !languageProvider.isLanguageMenuExpanded,
                child: Column(
                  children: [
                    Divider(
                      height: 1.h,
                      color: appTheme.borderColor,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      child: Column(
                        children: [
                          SizedBox(height: 8.h),
                          _buildLanguageOption(
                            context,
                            languageCode: AppTranslations.french,
                            languageName: 'Français',
                            languageNameAr: 'الفرنسية',
                            languageNameEn: 'French',
                            flagIcon: Icons.language,
                            isSelected: appLanguageProvider.currentLanguage == AppTranslations.french,
                            onTap: () => languageProvider.changeLanguage(AppTranslations.french),
                            isSubMenu: true,
                          ),
                          SizedBox(height: 4.h),
                          _buildLanguageOption(
                            context,
                            languageCode: AppTranslations.english,
                            languageName: 'English',
                            languageNameAr: 'الإنجليزية',
                            languageNameEn: 'English',
                            flagIcon: Icons.language_outlined,
                            isSelected: appLanguageProvider.currentLanguage == AppTranslations.english,
                            onTap: () => languageProvider.changeLanguage(AppTranslations.english),
                            isSubMenu: true,
                          ),
                          SizedBox(height: 4.h),
                          _buildLanguageOption(
                            context,
                            languageCode: AppTranslations.arabic,
                            languageName: 'العربية',
                            languageNameAr: 'العربية',
                            languageNameEn: 'Arabic',
                            flagIcon: Icons.language,
                            isSelected: appLanguageProvider.currentLanguage == AppTranslations.arabic,
                            onTap: () => languageProvider.changeLanguage(AppTranslations.arabic),
                            isSubMenu: true,
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentLanguageDisplayName(String currentLanguage) {
    switch (currentLanguage) {
      case AppTranslations.english:
        return 'English';
      case AppTranslations.arabic:
        return 'العربية';
      default: // French
        return 'Français';
    }
  }
}