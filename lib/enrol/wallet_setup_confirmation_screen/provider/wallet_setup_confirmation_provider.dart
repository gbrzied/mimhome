import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/wallet_setup_confirmation_model.dart';

class WalletSetupConfirmationProvider extends ChangeNotifier {
  WalletSetupConfirmationModel walletSetupConfirmationModel =
      WalletSetupConfirmationModel();

  bool isLoading = false;
  bool isDefinePressed = false;
  bool isKeepPressed = false;

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() {
    isLoading = false;
    isDefinePressed = false;
    isKeepPressed = false;
    notifyListeners();
  }

  Future<void> onYesDefinePressed(BuildContext context) async {
    isDefinePressed = true;
    isLoading = true;
    notifyListeners();

    // Simulate processing for wallet setup
    await Future.delayed(Duration(milliseconds: 500));

    // Close the dialog
    Navigator.of(context).pop();

    // Navigate to bill payment selection screen
   // NavigatorService.pushNamed(AppRoutes.billPaymentSelectionScreen);

    isLoading = false;
    isDefinePressed = false;
    notifyListeners();
  }

  Future<void> onNoKeepPressed(BuildContext context) async {
    isKeepPressed = true;
    isLoading = true;
    notifyListeners();

    // Simulate processing
    await Future.delayed(Duration(milliseconds: 300));

    // Close the dialog
    Navigator.of(context).pop();

    // Navigate to bill payment selection screen
   // NavigatorService.pushNamed(AppRoutes.billPaymentSelectionScreen);

    isLoading = false;
    isKeepPressed = false;
    notifyListeners();
  }

  void updateWalletConfiguration(bool defineDefault) {
    walletSetupConfirmationModel.isDefaultWalletDefined = defineDefault;
    walletSetupConfirmationModel.userChoice = defineDefault ? "define" : "keep";
    notifyListeners();
  }
}
