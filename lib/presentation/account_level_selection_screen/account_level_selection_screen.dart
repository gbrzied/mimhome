import 'package:millime/widgets/custum_button.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountLevelSelectionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomProgressAppBar(
        currentStep: 2,
        totalSteps: 5,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Consumer<AccountLevelSelectionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.h),
              child: Column(
                spacing: 36.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.only(left: 20.h),
                    child: Text(
                      'Choisir le niveau du compte',
                      style: TextStyleHelper.instance.title18SemiBoldQuicksand
                          .copyWith(height: 1.28),
                    ),
                  ),
                  _buildAccountTypeCard(context),
                  _buildAccountLevelsList(context, provider),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<AccountLevelSelectionProvider>(
        builder: (context, provider, child) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 34.h, vertical: 24.h),
            child: CustomButton(
              width: double.infinity,
              text: 'Suivant',
              onPressed: () {
                provider.onNextPressed(context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountTypeCard(BuildContext context) {
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
                        imagePath: ImageConstant.imgPP,
                        width: 78.h,
                        height: 66.h,
                      ),
                      Text(
                        'Personne Physique',
                        style: TextStyleHelper.instance.body14BoldManrope
                            .copyWith(height: 1.43),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          'Compte personnel pour particuliers',
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
      child: Column(
        spacing: 14.h,
        children: [
          _buildAccountLevelCard(
            context,
            provider,
            provider.accountLevelSelectionModel.niveau1,
            0,
          ),
          _buildAccountLevelCard(
            context,
            provider,
            provider.accountLevelSelectionModel.niveau2,
            1,
          ),
        ],
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
    bool isNiveau2 = index == 1;

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
                    levelModel?.title ?? (isNiveau2 ? 'Niveau 2' : 'Niveau 1'),
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
                          'Solde maximal',
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
                        'Cumul mensuel',
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
