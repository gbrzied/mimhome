import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomProgressAppBar - A reusable AppBar component with progress tracking functionality
 * 
 * Features:
 * - Back navigation button with customizable action
 * - Linear progress indicator showing current step progress
 * - Step counter text display (e.g., "1/5", "2/5")
 * - Responsive design with proper scaling
 * - Customizable colors and styling
 * 
 * @param currentStep - Current step number (1-based indexing)
 * @param totalSteps - Total number of steps in the process
 * @param onBackPressed - Callback function for back button tap
 * @param backgroundColor - Background color of the AppBar
 * @param progressColor - Color of the progress bar fill
 * @param progressBackgroundColor - Background color of the progress bar
 * @param textColor - Color of the step counter text
 * @param backIconPath - Path to the back arrow icon
 */
class CustomProgressAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomProgressAppBar({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.onBackPressed,
    this.backgroundColor,
    this.progressColor,
    this.progressBackgroundColor,
    this.textColor,
    this.backIconPath,
  }) : super(key: key);

  /// Current step number (1-based indexing)
  final int currentStep;

  /// Total number of steps in the process
  final int totalSteps;

  /// Callback function triggered when back button is tapped
  final VoidCallback? onBackPressed;

  /// Background color of the AppBar
  final Color? backgroundColor;

  /// Color of the progress bar fill
  final Color? progressColor;

  /// Background color of the progress bar
  final Color? progressBackgroundColor;

  /// Color of the step counter text
  final Color? textColor;

  /// Path to the back arrow icon
  final String? backIconPath;

  @override
  Size get preferredSize => Size.fromHeight(48.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? appTheme.whiteCustom,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 48.h,
      flexibleSpace: SafeArea(
        bottom: false, // Don't pad bottom since AppBar handles it
        child: Container(
          padding: EdgeInsets.only(
            top: 12.h,
            right: 30.h,
            bottom: 12.h,
            left: 30.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBackButton(context),
              SizedBox(width: 18.h),
              _buildProgressBar(),
              SizedBox(width: 24.h),
              _buildStepText(),
              SizedBox(width: 14.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the back navigation button
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
      child: CustomImageView(
        imagePath: backIconPath ?? ImageConstant.imgArrowLeft,
        height: 24.h,
        width: 24.h,
      ),
    );
  }

  /// Builds the progress bar indicator
  Widget _buildProgressBar() {
    final progressValue = totalSteps > 0 ? currentStep / totalSteps : 0.0;

    return Expanded(
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: progressBackgroundColor ?? appTheme.surfaceColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          progressColor ?? appTheme.primaryColor,
        ),
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Builds the step counter text
  Widget _buildStepText() {
    return Text(
      "$currentStep/$totalSteps",
      style: TextStyleHelper.instance.label10SemiBoldManrope
          .copyWith(color: textColor ?? appTheme.onSurface, height: 1.4),
    );
  }
}
