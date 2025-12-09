import 'package:cible/core/utils/navigator_service.dart';
import 'package:cible/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../models/login_screen_model.dart';

class LoginScreenProvider extends ChangeNotifier {
  LoginScreenModel loginScreenModel = LoginScreenModel();

  void initialize() {
    // Initialize default values
    notifyListeners();
  }

  void updatePhoneNumber(String phoneNumber) {
    loginScreenModel.phoneNumberController = phoneNumber;
    notifyListeners();
  }

  void updateErrorMessage(String? errorMessage) {
    loginScreenModel.errorMessage = errorMessage;
    notifyListeners();
  }

  void validatePhoneNumber(BuildContext context) {
    final phoneNumber = loginScreenModel.phoneNumberController;
    
    if (phoneNumber == null || phoneNumber.isEmpty) {
      updateErrorMessage('Veuillez entrer votre numéro de téléphone');
      return;
    }

    // Simulate validation logic
    if (phoneNumber.length < 8) {
      updateErrorMessage('Numéro de téléphone invalide');
      return;
    }

    // Clear error and proceed with login
    updateErrorMessage(null);
    
    // Navigate to next screen or perform login logic
    // For now, just clear the field
    updatePhoneNumber('');
  }

  void navigateToRegistration(BuildContext context) {
    // Navigation logic to registration screen
    // This would typically use NavigatorService.pushNamed()
        NavigatorService.pushNamed(AppRoutes.termsConditionsScreenV2);

  }
}