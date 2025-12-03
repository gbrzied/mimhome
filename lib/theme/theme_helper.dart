import 'package:flutter/material.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  var _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get blue_gray_700 => Color(0xFF2B6F71);
  Color get cyan_300 => Color(0xFF5ED2D2);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get cyan_900 => Color(0xFF156778);
  Color get teal_400 => Color(0xFF228E91);
  Color get blue_gray_700_01 => Color(0xFF2E5E68);
  Color get teal_900 => Color(0xFF01475A);
  Color get cyan_200_16 => Color(0x168DE0E0);
  Color get cyan_100 => Color(0xFFC5F9EF);
  Color get black_900 => Color(0xFF000000);
  Color get teal_400_01 => Color(0xFF39AE99);
  Color get gray_600 => Color(0xFF787878);
  Color get gray_200 => Color(0xFFEAEAEB);
  Color get pink_900 => Color(0xFF712B2B);
  Color get deep_orange_100 => Color(0xFFF9C5C5);
  Color get red_A700 => Color(0xFFFD0A0A);
  Color get cyan_50_19 => Color(0x19CEFCF8);
  Color get gray_50 => Color(0xFFFCFCFD);
  Color get blue_gray_900 => Color(0xFF33363F);
  Color get teal_300 => Color(0xFF43A0A3);
  Color get gray_50_01 => Color(0xFFFAFBFA);
  Color get gray_400 => Color(0xFFBEBCBC);


  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get greyCustom => Colors.grey;
  Color get color26FFFF => Color(0x26FFFFFF);
  Color get color7FFFFF => Color(0x7FFFFFFF);
  Color get color190000 => Color(0x19000000);
  Color get color8C0000 => Color(0x8C000000);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;


    // App Colors
  Color get blue_gray_100_66 => Color(0x66D9D7D7);
  Color get gray_700 => Color(0xFF5B5F5F);
  
  Color get gray_900 => Color(0xFF111111);
  Color get blue_gray_900_01 => Color(0xFF333333);
  Color get gray_500 => Color(0xFF979797);
  Color get deep_purple_800_11 => Color(0x113629B7);
 
  Color get colorFF6BA8 => Color(0xFF6BA8B8);
  Color get colorFF9BC4 => Color(0xFF9BC4CC);



  Color get blue_gray_100 => Color(0xFFD9D9D9);
  Color get blue_gray_100_01 => Color(0xFFD2CFCA);
  Color get blue_gray_50 => Color(0xFFEDF3F3);
  Color get gray_300 => Color(0xFFE3E4E8);

  Color get redCustom => Colors.red;
  Color get color161567 => Color(0x16156778);
  Color get colorFF52D1 => Color(0xFF52D1C6);



}
