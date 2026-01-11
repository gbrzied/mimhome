import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_image_view.dart';
import 'models/bill_payment_selection_model.dart';
import 'provider/bill_payment_selection_provider.dart';

class BillPaymentSelectionScreen extends StatefulWidget {
  BillPaymentSelectionScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<BillPaymentSelectionProvider>(
      create: (context) => BillPaymentSelectionProvider(),
      builder: (context, child) => BillPaymentSelectionScreen(),

    );
  }

  @override
  State<BillPaymentSelectionScreen> createState() =>
      _BillPaymentSelectionScreenState();
}

class _BillPaymentSelectionScreenState
    extends State<BillPaymentSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BillPaymentSelectionProvider>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomAppBar(
        title: 'Paiements par facture',
        leadingIcon: ImageConstant.imgArrowLeft,
        onLeadingPressed: () => NavigatorService.goBack(),
      ),
      body: Consumer<BillPaymentSelectionProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.only(
              top: 16.h,
              left: 24.h,
              right: 24.h,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    spacing: 20.h,
                    children: provider.billPaymentModel.billOptions
                            ?.map((billOption) {
                          return _buildBillPaymentCard(
                            context,
                            billOption,
                            provider.onBillOptionTapped,
                          );
                        }).toList() ??
                        [],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillPaymentCard(
    BuildContext context,
    BillOptionModel billOption,
    Function(String) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(billOption.type ?? ''),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.circular(14.h),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(17, 197, 193, 231).withAlpha(184),
              offset: Offset(0, 4),
              blurRadius: 30.h,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    billOption.title ?? '',
                    style: TextStyleHelper.instance.title16SemiBoldPoppins,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    billOption.description ?? '',
                    style: TextStyleHelper.instance.body12MediumPoppins,
                  ),
                ],
              ),
            ),
            CustomImageView(
              imagePath: billOption.icon ?? '',
              width: billOption.iconWidth?.h ?? 66.h,
              height: billOption.iconHeight?.h ?? 72.h,
            ),
          ],
        ),
      ),
    );
  }
}
