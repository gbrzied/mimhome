import 'package:millime/enrol/account_type_selection_screen/models/account_type_selection_screen_model.dart';
import 'package:millime/enrol/account_type_selection_screen/provider/account_type_selection_provider.dart';
import 'package:millime/widgets/custom_progress_app_bar.dart';
import 'package:millime/widgets/custum_button.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../localizationMillime/localization/app_localization.dart';
import '../../widgets/custom_image_view.dart';

class AccountTypePersSelectionScreen extends StatefulWidget {
  AccountTypePersSelectionScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AccountTypeSelectionProvider>(
      create: (context) => AccountTypeSelectionProvider(),
      child: AccountTypePersSelectionScreen(),
    );
  }

  @override
  State<AccountTypePersSelectionScreen> createState() =>
      _AccountTypePersSelectionScreenState();
}

class _AccountTypePersSelectionScreenState
    extends State<AccountTypePersSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountTypeSelectionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteCustom,
      appBar: _buildAppBar(context),
      bottomNavigationBar: Consumer<AccountTypeSelectionProvider>(
        builder: (context, provider, child) {
          return _buildBottomButton(context, provider);
        },
      ),
      body: Consumer<AccountTypeSelectionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: _buildMainContent(context, provider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomProgressAppBar(
      currentStep: 1,
      totalSteps: 5,
      onBackPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMainContent(
      BuildContext context, AccountTypeSelectionProvider provider) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, right: 32.h, left: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context),
          SizedBox(height: 10.h),
          _buildAccountTypeSection(context, provider),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            'key_account_opening_request'.tr,
            style: TextStyleHelper.instance.title18SemiBoldQuicksand
                .copyWith(height: 1.67, letterSpacing: 0.5),
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.h),
          decoration: BoxDecoration(
            color: appTheme.color161567,
            borderRadius: BorderRadius.circular(14.h),
          ),
          child: Text(
            'key_account_opening_description'.tr,
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.label10RegularManrope
                .copyWith(height: 3.0),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeSection(
      BuildContext context, AccountTypeSelectionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            'key_choose_account_type'.tr,
            style: TextStyleHelper.instance.body14SemiBoldManrope
                .copyWith(height: 1.43),
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.h),
          child: Column(
            spacing: 22.h,
            children: [
              _buildAccountTypeCard(
                context,
                provider,
                imagePath: ImageConstant.imgPP,
                title: 'key_individual_person'.tr,
                subtitle: 'key_personal_account_description'.tr,
                isSelected:
                    provider.accountTypeSelectionModel.selectedAccountTypePMPP ==
                        AccountTypePMPP.individual,
                onTap: () => provider.selectAccountTypePMPP(AccountTypePMPP.individual),
              ),
              _buildAccountTypeCard(
                context,
                provider,
                imagePath: ImageConstant.imgPM,
                title: 'key_legal_entity'.tr,
                subtitle: 'key_business_account_description'.tr,
                isSelected:
                    provider.accountTypeSelectionModel.selectedAccountTypePMPP ==
                        AccountTypePMPP.business,
                onTap: () => provider.selectAccountTypePMPP(AccountTypePMPP.business),
                isBusinessCard: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeCard(
    BuildContext context,
    AccountTypeSelectionProvider provider, {
    required String imagePath,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool isBusinessCard = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.h),
        decoration: BoxDecoration(
          color: appTheme.whiteCustom,
          border: Border.all(
            color: isSelected ? appTheme.primaryColor : appTheme.blue_gray_100_01,
            width: 1.h,
          ),
          borderRadius: BorderRadius.circular(14.h),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBusinessCard)
                    Container(
                      width: 102.h,
                      height: 72.h,
                      margin: EdgeInsets.only(left: 12.h, top: 4.h),
                      child: Stack(
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgCaptureDCran,
                            width: 86.h,
                            height: 72.h,
                            alignment: Alignment.centerRight,
                          ),
                          CustomImageView(
                            imagePath: imagePath,
                            width: 102.h,
                            height: 72.h,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      margin: EdgeInsets.only(left: 18.h, top: 2.h),
                      child: CustomImageView(
                        imagePath: imagePath,
                        width: 86.h,
                        height: 72.h,
                      ),
                    ),
                  SizedBox(height: isBusinessCard ? 6.h : 8.h),
                  Padding(
                    padding: EdgeInsets.only(left: isBusinessCard ? 2.h : 0),
                    child: Text(
                      title,
                      style: TextStyleHelper.instance.body14BoldManrope
                          .copyWith(height: 1.43),
                    ),
                  ),
                  SizedBox(height: isBusinessCard ? 10.h : 11.h),
                  Padding(
                    padding: EdgeInsets.only(left: isBusinessCard ? 0 : 1.h),
                    child: Text(
                      subtitle,
                      style: TextStyleHelper.instance.body12RegularManrope
                          .copyWith(height: 1.42),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 26.h,
                height: 24.h,
                margin: EdgeInsets.only(top: isBusinessCard ? 0 : 2.h),
                decoration: BoxDecoration(
                  color: appTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Center(
                  child: CustomImageView(
                    imagePath: ImageConstant.imgTick,
                    width: 14.h,
                    height: 12.h,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(
      BuildContext context, AccountTypeSelectionProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 35.h, vertical: 24.h),
      child: CustomButton(
        text: "key_next".tr,
        width: double.infinity,
        onPressed: () {
  provider.selectAccountTypePMPP(provider.accountTypeSelectionModel.selectedAccountTypePMPP ?? AccountTypePMPP.individual);
          provider.navigateToNextScreen(context);
        },
      ),
    );
  }
}
