import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// Custom button widget that supports filled and outlined variants
/// with consistent styling and responsive design
class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    required this.width,
    this.variant,
    this.margin,
    this.onPressed,
  }) : super(key: key);

  /// The text to display on the button
  final String text;

  /// The width of the button
  final double width;

  /// The visual variant of the button (filled or outlined)
  final CustomButtonVariant? variant;

  /// External margin around the button
  final EdgeInsets? margin;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      child: _buildButton(),
    );
  }

  /// Builds the appropriate button widget based on variant
  Widget _buildButton() {
    final buttonVariant = variant ?? CustomButtonVariant.filled;

    switch (buttonVariant) {
      case CustomButtonVariant.filled:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: appTheme.cyan_900,
            foregroundColor: appTheme.white_A700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.h),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 30.h,
            ),
            elevation: 0,
          ),
          child: Text(
            text,
            style: TextStyleHelper.instance.title16MediumSyne
                .copyWith(height: 1.25,color:appTheme.white_A700),
          ),
        );
      case CustomButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: appTheme.cyan_900,
            side: BorderSide(
              color: appTheme.cyan_900,
              width: 1.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.h),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 30.h,
            ),
          ),
          child: Text(
            text,
            style: TextStyleHelper.instance.title16MediumSyne
                .copyWith(height: 1.25),
          ),
        );
    }
  }
}

/// Enum defining the visual variants of the custom button
enum CustomButtonVariant {
  /// Button with filled background and white text
  filled,

  /// Button with outlined border and colored text
  outlined,
}
