import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/account_level_selection_model.dart';

class AccountLevelSelectionProvider extends ChangeNotifier {
  AccountLevelSelectionModel accountLevelSelectionModel =
      AccountLevelSelectionModel();

  int selectedLevelIndex = 1; // Default to Niveau 2 (selected in design)
  bool isLoading = false;

  void initialize() {
    // Initialize account level data
    accountLevelSelectionModel.niveau1 = AccountLevelModel(
      title: 'Niveau 1',
      maxBalance: '500.000 TND',
      monthlyLimit: '250.000 TND',
      isSelected: false,
    );

    accountLevelSelectionModel.niveau2 = AccountLevelModel(
      title: 'Niveau 2',
      maxBalance: '500.000 TND',
      monthlyLimit: '250.000 TND',
      isSelected: true,
    );

    notifyListeners();
  }

  void selectAccountLevel(int levelIndex) {
    selectedLevelIndex = levelIndex;

    // Update selection state in models
    if (accountLevelSelectionModel.niveau1 != null) {
      accountLevelSelectionModel.niveau1!.isSelected = levelIndex == 0;
    }
    if (accountLevelSelectionModel.niveau2 != null) {
      accountLevelSelectionModel.niveau2!.isSelected = levelIndex == 1;
    }

    notifyListeners();
  }

  void onNextPressed(BuildContext context) {
    isLoading = true;
    notifyListeners();

    // Simulate form processing
    Future.delayed(Duration(milliseconds: 500), () {
      isLoading = false;
      notifyListeners();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Niveau de compte sélectionné avec succès'),
          backgroundColor: appTheme.cyan_900,
        ),
      );

      // Navigate to personal informations screen
      NavigatorService.pushNamed(AppRoutes.personalInformationsScreen);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
