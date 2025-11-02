import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomFab - A customizable floating action button widget
 * 
 * This widget provides a Material Design floating action button with customizable
 * icon, size, colors, and callback functionality. Uses CustomImageView for 
 * consistent image handling across different formats.
 * 
 * @param iconPath - Path to the icon image (SVG, PNG, network URL, etc.)
 * @param onPressed - Callback function triggered when the FAB is pressed
 * @param size - Size of the FAB (defaults to 28.h)
 * @param backgroundColor - Background color of the FAB
 * @param iconColor - Color tint for the icon
 * @param elevation - Elevation/shadow depth of the FAB
 */
class CustomFab extends StatelessWidget {
  const CustomFab({
    Key? key,
    this.iconPath,
    this.onPressed,
    this.size,
    this.backgroundColor,
    this.iconColor,
    this.elevation,
  }) : super(key: key);

  /// Path to the icon image (SVG, PNG, network URL, etc.)
  final String? iconPath;

  /// Callback function triggered when the FAB is pressed
  final VoidCallback? onPressed;

  /// Size of the FAB
  final double? size;

  /// Background color of the FAB
  final Color? backgroundColor;

  /// Color tint for the icon
  final Color? iconColor;

  /// Elevation/shadow depth of the FAB
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final fabSize = size ?? 28.h;
    final iconSize = fabSize * 0.6; // Icon is typically 60% of FAB size

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        elevation: elevation ?? 6.0,
        mini: fabSize < 40.h, // Use mini FAB for smaller sizes
        child: CustomImageView(
          imagePath: iconPath ?? ImageConstant.imgIconsGrid,
          width: iconSize,
          height: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
