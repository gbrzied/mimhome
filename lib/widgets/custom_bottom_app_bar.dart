import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomBottomAppBar - A customizable bottom navigation bar with floating action button
 * 
 * Features:
 * - Bottom navigation with icon and text labels
 * - Central floating action button with gradient background
 * - Active/inactive states for navigation items
 * - Customizable navigation items and callbacks
 * - Responsive design with proper scaling
 * 
 * @param bottomBarItemList List of navigation items
 * @param selectedIndex Currently selected navigation index
 * @param onItemTapped Callback when navigation item is tapped
 * @param onFabTapped Callback when floating action button is tapped
 * @param fabIcon Icon for the floating action button
 * @param fabText Text label for the floating action button
 */
class CustomBottomAppBar extends StatelessWidget {
  CustomBottomAppBar({
    Key? key,
    required this.bottomBarItemList,
    required this.onItemTapped,
    this.selectedIndex = 0,
    this.onFabTapped,
    this.fabIcon,
    this.fabText,
  }) : super(key: key);

  /// List of bottom bar navigation items
  final List<CustomBottomAppBarItem> bottomBarItemList;

  /// Currently selected navigation index
  final int selectedIndex;

  /// Callback function when a navigation item is tapped
  final Function(int) onItemTapped;

  /// Callback function when FAB is tapped
  final VoidCallback? onFabTapped;

  /// Icon path for the floating action button
  final String? fabIcon;

  /// Text label for the floating action button
  final String? fabText;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 116.h,
      color: appTheme.color7FFFFF,
      shape: CircularNotchedRectangle(),
      notchMargin: 8.h,
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.color7FFFFF,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.h),
            topRight: Radius.circular(16.h),
            bottomLeft: Radius.circular(20.h),
            bottomRight: Radius.circular(20.h),
          ),
          boxShadow: [
            BoxShadow(
              color: appTheme.color190000,
              blurRadius: 35.h,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 96.h,
                padding: EdgeInsets.symmetric(horizontal: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildNavigationItems(),
                ),
              ),
            ),
            Positioned(
              top: 14.h,
              left: 0,
              right: 0,
              child: _buildFloatingActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    List<Widget> items = [];
    int itemCount = bottomBarItemList.length;
    int fabPosition = itemCount ~/ 2;

    for (int i = 0; i < itemCount; i++) {
      if (i == fabPosition) {
        // Add spacing for FAB
        items.add(SizedBox(width: 60.h));
      }

      items.add(
          _buildNavigationItem(bottomBarItemList[i], i == selectedIndex, i));
    }

    return items;
  }

  Widget _buildNavigationItem(
      CustomBottomAppBarItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageView(
              imagePath: item.icon ?? '',
              height: 30.h,
              width: 30.h,
            ),
            SizedBox(height: item.title != null ? 6.h : 0),
            if (item.title != null)
              Text(
                item.title!,
                style: TextStyleHelper.instance.body12RegularDMSans.copyWith(
                    color: isSelected ? Color(0xFF2B6F71) : appTheme.black_900),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onFabTapped,
            child: Container(
              height: 56.h,
              width: 60.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.157, 0),
                  end: Alignment(1, 1),
                  colors: [
                    Color(0xFF43A0A3),
                    appTheme.cyan_900,
                  ],
                ),
                borderRadius: BorderRadius.circular(12.h),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.color8C0000,
                    blurRadius: 35.h,
                    offset: Offset(4.h, 12.h),
                  ),
                ],
              ),
              child: Center(
                child: CustomImageView(
                  imagePath: fabIcon ?? ImageConstant.imgIconsGrid,
                  height: 28.h,
                  width: 28.h,
                ),
              ),
            ),
          ),
          if (fabText != null) ...[
            SizedBox(height: 6.h),
            Text(
              fabText!,
              style: TextStyleHelper.instance.body12RegularDMSans
                  .copyWith(color: appTheme.black_900),
            ),
          ],
        ],
      ),
    );
  }
}

/// Item data model for custom bottom app bar
class CustomBottomAppBarItem {
  CustomBottomAppBarItem({
    this.icon,
    this.title,
    this.routeName,
  });

  /// Path to the navigation item icon
  final String? icon;

  /// Title text for the navigation item
  final String? title;

  /// Route name for navigation
  final String? routeName;
}
