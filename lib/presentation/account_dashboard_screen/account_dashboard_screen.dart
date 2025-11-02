
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import './provider/account_dashboard_provider.dart';
import './widgets/service_item_widget.dart';
import './widgets/transaction_item_widget.dart';

class AccountDashboardScreen extends StatefulWidget {
  AccountDashboardScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AccountDashboardProvider>(
      create: (context) => AccountDashboardProvider(),
      child: AccountDashboardScreen(),
    );
  }

  @override
  State<AccountDashboardScreen> createState() => _AccountDashboardScreenState();
}

class _AccountDashboardScreenState extends State<AccountDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountDashboardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_50_01,
      appBar: _buildAppBar(),
      body: Consumer<AccountDashboardProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                _buildBalanceCard(context, provider),
                SizedBox(height: 22.h),
                _buildServicesSection(context, provider),
                SizedBox(height: 18.h),
                _buildPaymentsSection(context, provider),
                SizedBox(height: 18.h),
                _buildTransactionsSection(context, provider),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomAppBar(),
      //floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'MILLIME',
      logoImagePath: ImageConstant.imgLogo,
      notificationImagePath: ImageConstant.imgIconNotification,
      profileImagePath: ImageConstant.imgEllipse645,
      height: 56.h,
      onNotificationTap: () {
        // Handle notification tap
      },
      onProfileTap: () {
        // Handle profile tap
      },
    );
  }

  Widget _buildBalanceCard(
      BuildContext context, AccountDashboardProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(26.h),
      margin: EdgeInsets.only(top: 12.h, right: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.h),
        gradient: LinearGradient(
          begin: Alignment(0.34, -0.94),
          end: Alignment(-0.34, 0.94),
          colors: [Color(0xFF156778), Color(0xFF228E91)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde',
                style: TextStyleHelper.instance.title16MediumManrope,
              ),
              CustomIconButton(
                text: 'Défaut',
                leftIcon: ImageConstant.imgWalletoutline,
                backgroundColor: appTheme.color26FFFF,
                textColor: appTheme.white_A700,
                borderRadius: 12.h,
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 10.h),
                onPressed: () {
                  context
                      .read<AccountDashboardProvider>()
                      .onDefaultButtonPressed();
                },
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '1 234',
                style: TextStyleHelper.instance.display42SemiBoldDMSans,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  ',567 TND',
                  style: TextStyleHelper.instance.headline30MediumDMSans,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 14.h, bottom: 18.h),
                child: CustomImageView(
                  imagePath: ImageConstant.imgVector,
                  height: 14.h,
                  width: 22.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(
      BuildContext context, AccountDashboardProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Serivces',
              style: TextStyleHelper.instance.title16BoldManrope,
            ),
            GestureDetector(
              onTap: () {
                context
                    .read<AccountDashboardProvider>()
                    .onSeeMoreServicesPressed();
              },
              child: Text(
                'Voir plus',
                style: TextStyleHelper.instance.body15SemiBoldManrope,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          spacing: 10.h,
          children:
              provider.accountDashboardModel.serviceItems?.map((serviceItem) {
                    return ServiceItemWidget(
                      serviceItem: serviceItem,
                      onTap: () {
                        context
                            .read<AccountDashboardProvider>()
                            .onServiceItemTap(serviceItem);
                      },
                    );
                  }).toList() ??
                  [],
        ),
      ],
    );
  }

  Widget _buildPaymentsSection(
      BuildContext context, AccountDashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paiements',
          style: TextStyleHelper.instance.title16BoldManrope,
        ),
        SizedBox(height: 14.h),
        Row(
          spacing: 12.h,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context
                      .read<AccountDashboardProvider>()
                      .onScanQRCodePressed();
                },
                child: Container(
                  padding: EdgeInsets.all(14.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.h),
                    gradient: LinearGradient(
                      begin: Alignment(0.34, -0.94),
                      end: Alignment(-0.34, 0.94),
                      colors: [Color(0xFF156778), Color(0xFF228E91)],
                    ),
                  ),
                  child: Row(
                    spacing: 14.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgVectorWhiteA700,
                          height: 24.h,
                          width: 24.h,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            'Scanner\n QR code',
                            style: TextStyleHelper.instance.body12SemiBoldInter
                                .copyWith(color: appTheme.white_A700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context
                      .read<AccountDashboardProvider>()
                      .onBillsServicesPressed();
                },
                child: Container(
                  padding: EdgeInsets.all(14.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.h),
                    color: appTheme.cyan_200_16,
                  ),
                  child: Row(
                    spacing: 16.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgFileDocumentM,
                          height: 24.h,
                          width: 24.h,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            'Factures & Services',
                            style: TextStyleHelper.instance.body12SemiBoldInter
                                .copyWith(color: appTheme.cyan_300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(
      BuildContext context, AccountDashboardProvider provider) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: TextStyleHelper.instance.title16BoldManrope,
              ),
              GestureDetector(
                onTap: () {
                  context
                      .read<AccountDashboardProvider>()
                      .onSeeMoreTransactionsPressed();
                },
                child: Text(
                  'Voir plus',
                  style: TextStyleHelper.instance.body15SemiBoldManrope,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: appTheme.white_A700,
            borderRadius: BorderRadius.circular(12.h),
            boxShadow: [
              BoxShadow(
                color: appTheme.cyan_50_19,
                offset: Offset(2, 4),
                blurRadius: 50,
              ),
            ],
          ),
          child: Column(
            children: provider.accountDashboardModel.transactionItems
                    ?.map((transactionItem) {
                  int index = provider.accountDashboardModel.transactionItems!
                      .indexOf(transactionItem);
                  return Column(
                    children: [
                      TransactionItemWidget(
                        transactionItem: transactionItem,
                        onTap: () {
                          context
                              .read<AccountDashboardProvider>()
                              .onTransactionItemTap(transactionItem);
                        },
                      ),
                      if (index <
                          (provider.accountDashboardModel.transactionItems!
                                  .length -
                              1)) ...[
                        SizedBox(height: 8.h),
                        Container(
                          height: 1.h,
                          width: double.infinity,
                          color: appTheme.gray_200,
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ],
                  );
                }).toList() ??
                [],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAppBar() {
    return Consumer<AccountDashboardProvider>(
      builder: (context, provider, child) {
        return CustomBottomAppBar(
          bottomBarItemList: provider.bottomBarItems,
          selectedIndex: provider.selectedBottomBarIndex,
          onItemTapped: (index) {
            provider.onBottomBarItemTapped(index);
          },
          onFabTapped: () {
            provider.onFabTapped();
          },
          fabIcon: ImageConstant.imgIconsGrid,
          fabText: 'Menu',
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<AccountDashboardProvider>(
      builder: (context, provider, child) {
        return CustomFab(
          iconPath: ImageConstant.imgIconsGrid,
          size: 28.h,
          onPressed: () {
            provider.onFabTapped();
          },
        );
      },
    );
  }
}
