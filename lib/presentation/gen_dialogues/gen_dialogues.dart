
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';

class GenDialogues extends StatelessWidget {
  final String? iconPath;
  final String title;
  final String message;
  final List<Widget> buttons;
  final double? width;
  final double? height;

  GenDialogues({
    Key? key,
    this.iconPath,
    required this.title,
    required this.message,
    required this.buttons,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // To maintain the gradient background
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6BA8B8).withAlpha(204),
              Color(0xFF9BC4CC).withAlpha(153),
              appTheme.whiteCustom.withAlpha(77),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: width ?? 400.h,
            height: height,
            margin: EdgeInsets.symmetric(horizontal: 45.h),
            padding: EdgeInsets.symmetric(horizontal: 26.h, vertical: 26.h),
            decoration: BoxDecoration(
              color: appTheme.white_A700,
              borderRadius: BorderRadius.circular(24.h),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildContentSection(context),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5.h),
      margin: EdgeInsets.only(top: 5.h, left: 12.h),
      child: Column(
        children: [
          if (iconPath != null)
            iconPath!.endsWith('.svg')
                ? SvgPicture.asset(
                    iconPath!,
                    height: 50.h,
                    width: 50.h,
                    fit: BoxFit.contain,
                  )
                : CustomImageView(
                    imagePath: iconPath,
                    height: 50.h,
                    width: 50.h,
                    fit: BoxFit.contain,
                  ),
          SizedBox(height: 10.h),
          Container(
            width: 295.h,
            height: 28.h,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.title20SemiBoldQuicksandCentered
                  .copyWith(color: appTheme.black_900, letterSpacing: 0.5),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyleHelper.instance.title20SemiBoldQuicksandCentered
                .copyWith(color: appTheme.black_900, letterSpacing: 0.5, fontSize: 9.fSize, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.h),
      child: Column(
        spacing: 8.h,
        children: [
          ...buttons,
        ],
      ),
    );
  }
}
