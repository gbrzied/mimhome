import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/transaction_item_model.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionItemModel transactionItem;
  final VoidCallback? onTap;

  TransactionItemWidget({
    Key? key,
    required this.transactionItem,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 2.h),
            decoration: BoxDecoration(
              color: (transactionItem.isPositive ?? false)
                  ? Color(0xFFC5F9EF)
                  : appTheme.deep_orange_100,
              borderRadius: BorderRadius.circular(6.h),
            ),
            child: Text(
              transactionItem.type ?? '',
              style: TextStyleHelper.instance.label6MediumInter.copyWith(
                  color: (transactionItem.isPositive ?? false)
                      ? Color(0xFF2B6F71)
                      : appTheme.pink_900),
            ),
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transactionItem.name ?? '',
                      style: TextStyleHelper.instance.body12SemiBoldInter
                          .copyWith(color: appTheme.black_900),
                    ),
                    Text(
                      transactionItem.amount ?? '',
                      style: TextStyleHelper.instance.body12SemiBoldInter
                          .copyWith(
                              color: (transactionItem.isPositive ?? false)
                                  ? Color(0xFF39AE99)
                                  : appTheme.red_A700),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      transactionItem.date ?? '',
                      style: TextStyleHelper.instance.label11MediumInter,
                    ),
                    SizedBox(width: 4.h),
                    Container(
                      height: 2.h,
                      width: 2.h,
                      decoration: BoxDecoration(
                        color: appTheme.gray_600,
                        borderRadius: BorderRadius.circular(1.h),
                      ),
                    ),
                    SizedBox(width: 4.h),
                    Text(
                      transactionItem.time ?? '',
                      style: TextStyleHelper.instance.label10MediumInter,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
