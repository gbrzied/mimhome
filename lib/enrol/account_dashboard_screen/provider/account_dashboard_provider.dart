import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/image_constant.dart';
import '../../../widgets/custom_bottom_app_bar.dart';
import '../models/account_dashboard_model.dart';
import '../models/service_item_model.dart';
import '../models/transaction_item_model.dart';

class AccountDashboardProvider extends ChangeNotifier {
  AccountDashboardModel accountDashboardModel = AccountDashboardModel();
  int selectedBottomBarIndex = 0;
  List<CustomBottomAppBarItem> bottomBarItems = [];

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() {
    _initializeServiceItems();
    _initializeTransactionItems();
    _initializeBottomBarItems();
    notifyListeners();
  }

  void _initializeServiceItems() {
    accountDashboardModel.serviceItems = [
      ServiceItemModel(
        icon: ImageConstant.imgIconAlimcarte,
        title: 'Transfert',
        id: '31:204',
      ),
      ServiceItemModel(
        icon: ImageConstant.imgIconAlimcarte36x38,
        title: 'Retrait',
        id: '31:199',
      ),
      ServiceItemModel(
        icon: ImageConstant.imgIconRecharge,
        title: 'Recharge',
        id: '31:209',
      ),
      ServiceItemModel(
        icon: ImageConstant.imgIconAlimcarte34x40,
        title: 'carte/wallet',
        id: '31_95_272_331_70_70',
      ),
    ];
  }

  void _initializeTransactionItems() {
    accountDashboardModel.transactionItems = [
      TransactionItemModel(
        type: 'Cash in',
        name: 'Foulen fouleni',
        amount: '+280.000 TND',
        date: '8 oct 2025',
        time: '18:30:00',
        icon: ImageConstant.imgImageCashIn,
        isPositive: true,
        id: '31:124',
      ),
      TransactionItemModel(
        type: 'Cash out',
        name: 'Foulen fouleni',
        amount: '-150.000 TND',
        date: '7 oct 2025',
        time: '18:30:00',
        icon: ImageConstant.imgCaptureDCran,
        isPositive: false,
        id: '31:138',
      ),
    ];
  }

  void _initializeBottomBarItems() {
    bottomBarItems = [
      CustomBottomAppBarItem(
        icon: ImageConstant.imgNavHome,
        title: 'Home',
        routeName: '/home',
      ),
      CustomBottomAppBarItem(
        icon: ImageConstant.imgNavFavoris,
        title: 'Favoris',
        routeName: '/favoris',
      ),
   
      CustomBottomAppBarItem(
        icon: ImageConstant.imgNavServices,
        title: 'Services',
        routeName: '/services',
      ),
      CustomBottomAppBarItem(
        icon: ImageConstant.imgNavProfil,
        title: 'Profil',
        routeName: '/profil',
      ),
    ];
  }

  void onDefaultButtonPressed() {
    // Handle default button press
    NavigatorService.pushNamed(AppRoutes.walletSetupConfirmationScreen);
    notifyListeners();
  }

  void onSeeMoreServicesPressed() {
    // Handle see more services press
    notifyListeners();
  }

  void onServiceItemTap(ServiceItemModel serviceItem) {
    // Handle service item tap
    if (serviceItem.title == 'Transfert') {
      NavigatorService.pushNamed(AppRoutes.transferScreen);
    }
    //  NavigatorService.pushNamed(AppRoutes.billPaymentSelectionScreen);

    notifyListeners();
  }

  void onScanQRCodePressed() {
    // Handle scan QR code press
    notifyListeners();
  }

  void onBillsServicesPressed() {
    // Handle bills & services press
      // Navigate to bill payment selection screen
    NavigatorService.pushNamed(AppRoutes.billPaymentSelectionScreen);
    notifyListeners();
  }

  void onSeeMoreTransactionsPressed() {
    // Handle see more transactions press
    notifyListeners();
  }

  void onTransactionItemTap(TransactionItemModel transactionItem) {
    // Handle transaction item tap
    notifyListeners();
  }

  void onBottomBarItemTapped(int index) {
    selectedBottomBarIndex = index;
    // Handle navigation based on index
    notifyListeners();
  }

  void onFabTapped() {
    // Handle floating action button tap
    notifyListeners();
  }
}
