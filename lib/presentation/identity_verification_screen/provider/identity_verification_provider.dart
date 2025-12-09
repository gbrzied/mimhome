import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/identity_verification_model.dart';

class IdentityVerificationProvider extends ChangeNotifier {
  IdentityVerificationModel identityVerificationModel =
      IdentityVerificationModel();

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() {
    // Initialize default values
    identityVerificationModel.showCard = false;
    notifyListeners();
  }

  void toggleCardVisibility() {
    identityVerificationModel.showCard =
        !(identityVerificationModel.showCard ?? false);
    notifyListeners();
  }

  void navigateToNextScreen(BuildContext context) {
    // Navigation logic for next screen
          NavigatorService.pushNamed(AppRoutes.finEnrolScreen);

  }
}