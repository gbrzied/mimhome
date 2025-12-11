import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Display Styles
  // Large text styles typically used for headers and hero elements

  TextStyle get display42SemiBoldDMSans => TextStyle(
        fontSize: 42.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'DM Sans',
        color: appTheme.onPrimary,
      );

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline30MediumDMSans => TextStyle(
        fontSize: 30.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'DM Sans',
        color: appTheme.onPrimary,
      );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  TextStyle get title18SemiBoldSyne => TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Syne',
        color: appTheme.secondaryColor,
      );

  TextStyle get title16MediumManrope => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Manrope',
        color: appTheme.onPrimary,
      );

  TextStyle get title16BoldManrope => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Manrope',
        color: appTheme.secondaryColor,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body15SemiBoldManrope => TextStyle(
        fontSize: 15.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Manrope',
        color: appTheme.secondaryColor,
      );

  TextStyle get body12SemiBoldInter => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      );

  TextStyle get body12RegularDMSans => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'DM Sans',
      );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label11MediumInter => TextStyle(
        fontSize: 11.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: appTheme.onSurface,
      );

  TextStyle get label11MediumManrope => TextStyle(
        fontSize: 11.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Manrope',
        color: appTheme.onSurface,
      );

  TextStyle get label10BoldManrope => TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Manrope',
        color: appTheme.secondaryColor,
      );

  TextStyle get label10MediumInter => TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: appTheme.gray_600,
      );

  TextStyle get label6MediumInter => TextStyle(
        fontSize: 6.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      );



  TextStyle get title20SemiBoldSyne => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Syne',
        color: appTheme.onBackground,
      );

  TextStyle get title16SemiBoldPoppins => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: appTheme.onBackground,
      );
 
  TextStyle get title16MediumSyne => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Syne',
        color: appTheme.primaryColor,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14RegularSyne => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Syne',
        color: appTheme.onSurfaceVariant,
      );

  TextStyle get body12MediumPoppins => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
        color: appTheme.onSurface,
      );


      // Title Styles
  // Medium text styles for titles and subtitles


  TextStyle get title18SemiBoldQuicksand => TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Quicksand',
        color: appTheme.onBackground,
      );

  TextStyle get title38BoldQuicksand => TextStyle(
        fontSize: 38.fSize,
        fontWeight: FontWeight.w500, // Changed from w700 to w600 for thinner appearance
        fontFamily: 'Quicksand',
        height: 1.0, // 100% line height
        letterSpacing: -0.5, // More negative for rounder appearance
        color: const Color(0xFF2E2E2E), // Darker for main title
      );

  TextStyle get title20RegularQuicksand => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Quicksand',
        height: 1.0, // 100% line height
        letterSpacing: -0.5, // More negative for rounder appearance
        color: const Color(0xFF9E9E9E), // Lighter grey as requested
      );

  TextStyle get title14SemiBoldQuicksand => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500, // Changed from w600 to w500 for thinner appearance
        fontFamily: 'Quicksand',
        letterSpacing: -0.3,
        color: const Color(0xFF9E9E9E), // Lighter grey as requested
      );

  TextStyle get title16SemiBoldManrope => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Manrope',
        color: appTheme.onPrimary,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14BoldManrope => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Manrope',
        color: appTheme.onBackground,
      );

  TextStyle get body14SemiBoldManrope => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Manrope',
        color: appTheme.onBackground,
      );

  TextStyle get body12RegularManrope => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Manrope',
        color: appTheme.dividerColor,
      );

  TextStyle get body12ExtraBoldManrope => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w800,
        fontFamily: 'Manrope',
        color: appTheme.onBackground,
      );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label10SemiBoldManrope => TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Manrope',
      );

  TextStyle get label10RegularManrope => TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Manrope',
        color: appTheme.disabledColor,
      );

  TextStyle get label9BoldManrope => TextStyle(
        fontSize: 9.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Manrope',
        height: 1.0, // 100% line height
      );

  TextStyle get title20SemiBoldQuicksandCentered => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w500, // Changed from w600 to w400 for thinner appearance
        fontFamily: 'Quicksand',
        height: 1.0, // 100% line height
        letterSpacing: 1.5, // Increased letter spacing for better readability

      );
}
