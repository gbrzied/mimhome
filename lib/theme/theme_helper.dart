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
}
