import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/account_type_selection_screen_model.dart';

class AccountTypeSelectionProvider extends ChangeNotifier {
  AccountTypeSelectionModel accountTypeSelectionModel =
      AccountTypeSelectionModel();

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() {
    // Set default selection to Individual Person as shown in the design
    accountTypeSelectionModel.selectedAccountType = AccountType.individual;
    notifyListeners();
  }

  void selectAccountType(AccountType accountType) {
    accountTypeSelectionModel.selectedAccountType = accountType;
    notifyListeners();
  }

  void navigateToNextScreen(BuildContext context) {
    if (accountTypeSelectionModel.selectedAccountType != null) {
      // Navigate to the next screen in the account opening flow
      NavigatorService.pushNamed(AppRoutes.accountLevelSelectionScreen);
    } else {
      // Show error message if no selection is made
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un type de compte'),
          backgroundColor: appTheme.redCustom,
        ),
      );
    }
  }
}
