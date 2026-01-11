
import '../../widgets/custum_button.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import 'provider/wallet_setup_confirmation_provider.dart';

class WalletSetupConfirmationScreen extends StatefulWidget {
  WalletSetupConfirmationScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<WalletSetupConfirmationProvider>(
      create: (context) => WalletSetupConfirmationProvider(),
      //child: WalletSetupConfirmationScreen(),

       builder: (context, child) => WalletSetupConfirmationScreen(),
    );
  }

  @override
  State<WalletSetupConfirmationScreen> createState() =>
      _WalletSetupConfirmationScreenState();
}

class _WalletSetupConfirmationScreenState
    extends State<WalletSetupConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletSetupConfirmationProvider>().initialize();
    });
  }

@override
Widget build(BuildContext context) {
  return Consumer<WalletSetupConfirmationProvider>(
    builder: (context, provider, child) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 350.h,
                margin: EdgeInsets.symmetric(horizontal: 45.h),
                padding: EdgeInsets.symmetric(vertical: 26.h),
                decoration: BoxDecoration(
                  color: appTheme.white_A700,
                  borderRadius: BorderRadius.circular(24.h),
                ),
                child: Column(
                  children: [
                    _buildContentSection(context, provider),
                    _buildActionButtons(context, provider),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildContentSection(
      BuildContext context, WalletSetupConfirmationProvider provider) {
    return Container(
      padding: EdgeInsets.only(top: 5.h),
      margin: EdgeInsets.only(top: 5.h, left: 12.h),
      child: Column(
        children: [
          // Wallet illustration image
          CustomImageView(
            imagePath: ImageConstant.imgWalletInfo,
            height: 180.h,
            width: 180.h,
            fit: BoxFit.contain,
            margin: EdgeInsets.only(bottom: 5.h),
          ),
          Text(
            "Do you want to define\n a default Wallet ?",
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.title20SemiBoldSyne
                .copyWith(height: 1.4),
          ),
          SizedBox(height: 6.h),
          Text(
            "define a default wallet to recieve all transactions into it",
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.body14RegularSyne
                .copyWith(height: 1.43),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WalletSetupConfirmationProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      margin: EdgeInsets.only(left: 8.h, right: 4.h),
      child: Column(
        spacing: 8.h,
        children: [
          CustomButton(
            text: "Yes, define now",
            width: double.infinity,
            variant: CustomButtonVariant.filled,
            margin: EdgeInsets.only(top: 16.h),
            onPressed: () {
              provider.onYesDefinePressed(context);
            },
          ),
          CustomButton(
            text: "No, keep",
            width: double.infinity,
            variant: CustomButtonVariant.outlined,
            onPressed: () {
              provider.onNoKeepPressed(context);
            },
          ),
        ],
      ),
    );
  }
}
