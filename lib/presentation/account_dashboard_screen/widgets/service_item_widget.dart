import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/service_item_model.dart';

class ServiceItemWidget extends StatelessWidget {
  final ServiceItemModel serviceItem;
  final VoidCallback? onTap;

  ServiceItemWidget({
    Key? key,
    required this.serviceItem,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 1.h, vertical: 6.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageView(
              imagePath: serviceItem.icon ?? '',
              height: 36.h,
              width: 36.h,
            ),
            SizedBox(height: 4.h),
            Text(
              serviceItem.title ?? '',
              style: TextStyleHelper.instance.label10BoldManrope,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
