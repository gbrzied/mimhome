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
        color: appTheme.white_A700,
      );

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline30MediumDMSans => TextStyle(
        fontSize: 30.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'DM Sans',
        color: appTheme.white_A700,
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
        fontWeight: FontWeight.w600,
        fontFamily: 'Syne',
        color: appTheme.blue_gray_700,
      );

  TextStyle get title16MediumManrope => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Manrope',
        color: appTheme.white_A700,
      );

  TextStyle get title16BoldManrope => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Manrope',
        color: appTheme.blue_gray_700_01,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body15SemiBoldManrope => TextStyle(
        fontSize: 15.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Manrope',
        color: appTheme.blue_gray_700,
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
        color: appTheme.gray_600,
      );

  TextStyle get label11MediumManrope => TextStyle(
        fontSize: 11.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Manrope',
      );

  TextStyle get label10BoldManrope => TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Manrope',
        color: appTheme.teal_900,
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
}
