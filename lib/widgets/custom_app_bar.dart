import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomAppBar - A customizable app bar widget with logo, title, notification icon and profile image
 * 
 * @param title - The title text to display in the app bar
 * @param logoImagePath - Path to the logo image (SVG supported)
 * @param notificationImagePath - Path to the notification icon image
 * @param profileImagePath - Path to the profile image
 * @param onNotificationTap - Callback function when notification icon is tapped
 * @param onProfileTap - Callback function when profile image is tapped
 * @param backgroundColor - Background color of the app bar
 * @param titleTextStyle - Text style for the title text
 * @param height - Height of the app bar
 */
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.title,
    this.logoImagePath,
    this.notificationImagePath,
    this.profileImagePath,
    this.onNotificationTap,
    this.onProfileTap,
    this.backgroundColor,
    this.titleTextStyle,
    this.height,
  }) : super(key: key);

  /// The title text to display in the app bar
  final String? title;

  /// Path to the logo image (SVG supported)
  final String? logoImagePath;

  /// Path to the notification icon image
  final String? notificationImagePath;

  /// Path to the profile image
  final String? profileImagePath;

  /// Callback function when notification icon is tapped
  final VoidCallback? onNotificationTap;

  /// Callback function when profile image is tapped
  final VoidCallback? onProfileTap;

  /// Background color of the app bar
  final Color? backgroundColor;

  /// Text style for the title text
  final TextStyle? titleTextStyle;

  /// Height of the app bar
  final double? height;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? appTheme.whiteCustom,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: height ?? 56.h,
      title: _buildAppBarContent(),
    );
  }

  Widget _buildAppBarContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.h, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (logoImagePath != null) _buildLogoSection(),
          if (title != null) _buildTitleSection(),
          Spacer(),
          if (notificationImagePath != null) _buildNotificationSection(),
          if (profileImagePath != null) _buildProfileSection(),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: CustomImageView(
        imagePath: logoImagePath!,
        height: 24.h,
        width: 38.h,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      margin: EdgeInsets.only(left: 15.h, bottom: 4.h),
      child: Text(
        title ?? "MILLIME",
        style: titleTextStyle ??
            TextStyleHelper.instance.title18SemiBoldSyne
                .copyWith(letterSpacing: 2, height: 1.22),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return GestureDetector(
      onTap: onNotificationTap,
      child: Container(
        margin: EdgeInsets.only(right: 10.h),
        child: CustomImageView(
          imagePath: notificationImagePath!,
          height: 40.h,
          width: 30.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: onProfileTap,
      child: Container(
        height: 34.h,
        width: 32.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.h),
          child: CustomImageView(
            imagePath: profileImagePath!,
            height: 34.h,
            width: 32.h,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
