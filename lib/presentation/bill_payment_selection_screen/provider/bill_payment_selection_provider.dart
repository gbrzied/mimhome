import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/image_constant.dart';
import '../models/bill_payment_selection_model.dart';

class BillPaymentSelectionProvider extends ChangeNotifier {
  BillPaymentSelectionModel billPaymentModel = BillPaymentSelectionModel();

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() {
    _initializeBillOptions();
    notifyListeners();
  }

  void _initializeBillOptions() {
    billPaymentModel.billOptions = [
      BillOptionModel(
        type: 'electric',
        title: 'Electric bill',
        description: 'Pay electric bill this month',
        icon: ImageConstant.imgElectric,
        iconWidth: 70,
        iconHeight: 76,
      ),
      BillOptionModel(
        type: 'water',
        title: 'Water bill',
        description: 'Pay water bill this month',
        icon: ImageConstant.imgWater,
        iconWidth: 66,
        iconHeight: 72,
      ),
      BillOptionModel(
        type: 'motorway',
        title: 'MotorWay bill',
        description: 'Pay mobile bill this month',
        icon: ImageConstant.imgMotoway,
        iconWidth: 64,
        iconHeight: 62,
      ),
      BillOptionModel(
        type: 'internet',
        title: 'Internet bill',
        description: 'Pay internet bill this month',
        icon: ImageConstant.imgInternet,
        iconWidth: 66,
        iconHeight: 72,
      ),
    ];
  }

  void onBillOptionTapped(String billType) {
    // Handle bill option selection
    // You can add navigation logic here based on the selected bill type
    print('Selected bill type: $billType');

    // Example: Navigate to specific payment screen based on bill type
    // NavigatorService.pushNamed(AppRoutes.paymentDetailsScreen);
  }
}
