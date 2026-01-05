import 'package:millime/widgets/custum_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../localizationMillime/localization/app_localization.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_progress_app_bar.dart';
import './provider/account_level_selection_provider.dart';
import 'models/account_level_selection_model.dart';

class AccountLevelSelectionScreen extends StatefulWidget {
  AccountLevelSelectionScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AccountLevelSelectionProvider>(
      create: (context) => AccountLevelSelectionProvider(),
      child: AccountLevelSelectionScreen(),
    );
  }

  @override
  State<AccountLevelSelectionScreen> createState() =>
      _AccountLevelSelectionScreenState();
}

class _AccountLevelSelectionScreenState
    extends State<AccountLevelSelectionScreen> {
  String? selectedAccountTypePPPM;

  @override
  void initState() {
    super.initState();
    _loadSelectedAccountTypePPPM();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AccountLevelSelectionProvider>().initialize();
    });
  }

  Future<void> _loadSelectedAccountTypePPPM() async {
    // Load selected account type from shared preferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountTypePPPM = prefs.getString('selected_account_typePPPM');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomProgressAppBar(
        currentStep: 2,
        totalSteps: 5,
        showBackButton: false,
      ),
      body: Consumer<AccountLevelSelectionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.h),
                    child: Column(
                      spacing: 20.h,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),
                        Padding(
                          padding: EdgeInsets.only(left: 20.h),
                          child: Text(
                            'key_choose_account_level'.tr,
                            style: TextStyleHelper.instance.title18SemiBoldQuicksand
                                .copyWith(height: 1.28),
                          ),
                        ),
                        _buildAccountTypeCard(context),
                        _buildAccountLevelsList(context, provider),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 34.h, vertical: 24.h),
                child: CustomButton(
                  width: double.infinity,
                  text: 'key_next'.tr,
                  onPressed: () {
                    provider.onNextPressed(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccountTypeCard(BuildContext context) {
    bool isIndividual = (selectedAccountTypePPPM ?? 'individual') == 'individual' ;
    String imagePath = isIndividual ? ImageConstant.imgPP : ImageConstant.imgPM;
    String title = isIndividual ? 'key_individual_account'.tr : 'key_business_account'.tr;
    String subtitle = isIndividual
        ? 'key_personal_account_description'.tr
        : 'key_business_account_description'.tr;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgRectangle2,
            width: double.infinity,
            height: 198.h,
            radius: BorderRadius.circular(14.h),
          ),
          CustomImageView(
            imagePath: ImageConstant.imgRectangle4,
            width: double.infinity,
            height: 206.h,
            radius: BorderRadius.circular(14.h),
          ),
          Container(
            width: double.infinity,
            height: 206.h,
            padding: EdgeInsets.all(26.h),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  margin: EdgeInsets.only(left: 2.h, bottom: 12.h),
                  decoration: BoxDecoration(
                    color: appTheme.white_A700,
                    border: Border.all(
                      color: appTheme.cyan_900,
                      width: 1.h,
                    ),
                    borderRadius: BorderRadius.circular(14.h),
                  ),
                  child: Column(
                    spacing: 2.h,
                    children: [
                      CustomImageView(
                        imagePath: imagePath,
                        width: 78.h,
                        height: 66.h,
                      ),
                      Text(
                        title,
                        style: TextStyleHelper.instance.body14BoldManrope
                            .copyWith(height: 1.43),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          subtitle,
                          style: TextStyleHelper.instance.body12RegularManrope
                              .copyWith(height: 1.42),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountLevelsList(
      BuildContext context, AccountLevelSelectionProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.h),
      margin: EdgeInsets.only(bottom: 32.h),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: provider.accountLevelSelectionModel.levels?.length ?? 0,
        separatorBuilder: (context, index) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          return _buildAccountLevelCard(
            context,
            provider,
            provider.accountLevelSelectionModel.levels?[index],
            index,
          );
        },
      ),
    );
  }

  Widget _buildAccountLevelCard(
    BuildContext context,
    AccountLevelSelectionProvider provider,
    AccountLevelModel? levelModel,
    int index,
  ) {
    bool isSelected = provider.selectedLevelIndex == index;

    return GestureDetector(
      onTap: () => provider.selectAccountLevel(index),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.h),
        margin: EdgeInsets.symmetric(horizontal: 2.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          border: Border.all(
            color: isSelected ?appTheme.primaryColor: appTheme.blue_gray_100_01,
            width: 1.h,
          ),
          borderRadius: BorderRadius.circular(14.h),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 22.h, bottom: 2.h),
                  child: Text(
                    levelModel?.title ?? 'key_level'.tr + ' ${index + 1}',
                    style: TextStyleHelper.instance.body12ExtraBoldManrope
                        .copyWith(height: 1.43),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 26.h,
                    height: 24.h,
                    margin: EdgeInsets.only(bottom: 2.h),
                    padding: EdgeInsets.all(6.h),
                    decoration: BoxDecoration(
                      color: appTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                    child: CustomImageView(
                      imagePath: ImageConstant.imgTick,
                      width: 14.h,
                      height: 12.h,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 8.h,
                left: 22.h,
                right: 22.h,
              ),
              child: Row(
                spacing: 8.h,
                children: [
                  Container(
                    width: 30.h,
                    height: 26.h,
                    decoration: BoxDecoration(
                      color: appTheme.cyan_50_19,
                      borderRadius: BorderRadius.circular(5.h),
                    ),
                    child: Center(
                      child: CustomImageView(
                        imagePath: ImageConstant.imgTrendingUp,
                        width: 20.h,
                        height: 20.h,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'key_max_balance'.tr,
                          style: TextStyleHelper.instance.label10SemiBoldManrope
                              .copyWith(color: appTheme.gray_400, height: 1.4),
                        ),
                        Text(
                          levelModel?.maxBalance ?? '500.000 TND',
                          style: TextStyleHelper.instance.body12ExtraBoldManrope
                              .copyWith(height: 1.42),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 22.h,
                right: 22.h,
                bottom: 16.h,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30.h,
                    height: 26.h,
                    decoration: BoxDecoration(
                      color: appTheme.blue_gray_50,
                      borderRadius: BorderRadius.circular(5.h),
                    ),
                    child: Center(
                      child: CustomImageView(
                        imagePath: ImageConstant.imgRefresh,
                        width: 20.h,
                        height: 20.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'key_monthly_cumulative'.tr,
                        style: TextStyleHelper.instance.label10SemiBoldManrope
                            .copyWith(color: appTheme.gray_400, height: 1.4),
                      ),
                      Text(
                        levelModel?.monthlyLimit ?? '250.000 TND',
                        style: TextStyleHelper.instance.body12ExtraBoldManrope
                            .copyWith(height: 1.42),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
