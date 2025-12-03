import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomAppBar - A flexible and reusable AppBar component
 * 
 * This component provides a customizable AppBar with optional leading icon,
 * configurable title text, and responsive design. It implements PreferredSizeWidget
 * for proper integration with Scaffold.
 * 
 * @param title - The title text to display in the AppBar
 * @param leadingIcon - Optional path to the leading icon (SVG/PNG)
 * @param onLeadingPressed - Callback function when leading icon is tapped
 * @param titleColor - Color for the title text
 * @param backgroundColor - Background color of the AppBar
 * @param centerTitle - Whether to center the title text
 */
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
    this.titleColor,
    this.backgroundColor,
    this.centerTitle,
  }) : super(key: key);

  /// The title text to display in the AppBar
  final String? title;

  /// Optional path to the leading icon (SVG/PNG)
  final String? leadingIcon;

  /// Callback function when leading icon is tapped
  final VoidCallback? onLeadingPressed;

  /// Color for the title text
  final Color? titleColor;

  /// Background color of the AppBar
  final Color? backgroundColor;

  /// Whether to center the title text
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? appTheme.transparentCustom,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle ?? false,
      titleSpacing: leadingIcon != null ? 0 : 28.h,
      leading: leadingIcon != null ? _buildLeading() : null,
      title: title != null ? _buildTitle() : null,
      leadingWidth: leadingIcon != null ? 62.h : null,
    );
  }

  Widget _buildLeading() {
    return GestureDetector(
      onTap: onLeadingPressed,
      child: Container(
        margin: EdgeInsets.only(left: 28.h, bottom: 2.h),
        alignment: Alignment.bottomLeft,
        child: CustomImageView(
          imagePath: leadingIcon!,
          height: 12.h,
          width: 6.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      alignment: centerTitle == true ? Alignment.center : Alignment.centerLeft,
      margin: EdgeInsets.only(
        right: centerTitle == true ? 28.h : 78.h,
      ),
      child: Text(
        title!,
        style: TextStyleHelper.instance.title16BoldManrope
            .copyWith(color: titleColor ?? Color(0xFF111111), height: 1.375),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
