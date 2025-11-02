import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// Custom button component with optional icon and customizable styling
/// Supports left icon, custom text, background colors, and responsive design
///
/// @param text - Button text content
/// @param leftIcon - Optional path to left icon image
/// @param onPressed - Callback function when button is pressed
/// @param backgroundColor - Background color of the button
/// @param textColor - Color of the button text
/// @param borderRadius - Border radius for rounded corners
/// @param padding - Internal padding of the button
/// @param height - Custom height for the button
/// @param width - Custom width for the button
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    this.text,
    this.leftIcon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.height,
    this.width,
  }) : super(key: key);

  /// Button text content
  final String? text;

  /// Path to the left icon image (SVG, PNG, or network URL)
  final String? leftIcon;

  /// Callback function triggered when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Color of the button text
  final Color? textColor;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// Internal padding of the button
  final EdgeInsets? padding;

  /// Custom height for the button
  final double? height;

  /// Custom width for the button
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? appTheme.color26FFFF,
          foregroundColor: textColor ?? appTheme.white_A700,
          elevation: 0,
          shadowColor: appTheme.transparentCustom,
          padding: padding ??
              EdgeInsets.symmetric(
                vertical: 2.h,
                horizontal: 10.h,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius?.h ?? 12.h),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leftIcon != null) ...[
              CustomImageView(
                imagePath: leftIcon!,
                height: 16.h,
                width: 16.h,
                color: textColor ?? appTheme.white_A700,
              ),
              SizedBox(width: 4.h),
            ],
            if (text != null)
              Text(
                text!,
                style: TextStyleHelper.instance.label11MediumManrope.copyWith(
                    color: textColor ?? appTheme.white_A700, height: (16 / 11)),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
