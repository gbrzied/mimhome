import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';
import '../models/terms_conditions_model.dart';

// Import Notif model - assuming it exists in the project
// If not, we'll need to create a simple Notif class

class TermsConditionsProvider extends ChangeNotifier {
  TermsConditionsModel termsConditionsModel = TermsConditionsModel();

  // Backend configuration - same as old login_store.dart
  String backendServer = '192.168.1.13'
  ; // Default to localhost, can be configured
  String userTel = ''; // User's phone number

  void initialize() {
    // Initialize default values
    notifyListeners();
  }

  void toggleSection(String key) {
    termsConditionsModel.expandedSections![key] = !(termsConditionsModel.expandedSections![key] ?? false);
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    termsConditionsModel.termsAccepted = value;
    notifyListeners();
  }

  void setPrivacyAccepted(bool value) {
    termsConditionsModel.privacyAccepted = value;
    notifyListeners();
  }

  void toggleArticleExpansion(int documentIndex, int articleIndex) {
    // Initialize the document articles map if it doesn't exist
    termsConditionsModel.documentArticles ??= {};

    // Initialize the document map if it doesn't exist
    termsConditionsModel.documentArticles![documentIndex] ??= {};

    // Toggle the article expansion state
    termsConditionsModel.documentArticles![documentIndex]![articleIndex] =
        !(termsConditionsModel.documentArticles![documentIndex]![articleIndex] ?? false);
    notifyListeners();
  }

  bool getArticleExpandedState(int documentIndex, int articleIndex) {
    return termsConditionsModel.documentArticles?[documentIndex]?[articleIndex] ?? false;
  }

  void setDocumentAccepted(int documentIndex, bool value) {
    // Initialize the document accepted map if it doesn't exist
    termsConditionsModel.documentAccepted ??= {};

    // Set the document acceptance state
    termsConditionsModel.documentAccepted![documentIndex] = value;
    notifyListeners();
  }

  bool getDocumentAcceptedState(int documentIndex) {
    return termsConditionsModel.documentAccepted?[documentIndex] ?? false;
  }

  void navigateToNextScreen(BuildContext context) {
    // Navigation logic if needed
  }

  // Server-side validation methods (similar to old LoginStore logic)
  Future<bool?> isValideNumTelGestion(String numTel) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:8081/wallet/public/' + numTel + '/tel'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        return Future.value(false); // Phone already exists
      } else if (response.statusCode <= 206) {
        return Future.value(true); // Phone is available
      } else {
        return Future.error('Connection error');
      }
    } catch (ex) {
      return Future.error('Connection error');
    }
  }

  Future<bool?> isValideEmailGestion(String email) async {
    if (email.isEmpty) return false;

    final res = email.split("@");
    if (res.length != 2) return false;

    final user = res[0];
    final res1 = res[1].split(".");

    if (res1.length != 2) return false;

    final domaine = res1[0];
    final suffixe = res1[1];

    var queryParameters = {
      'user': user,
      'domaine': domaine,
      'suffixe': suffixe
    };

    var uri = Uri.http('localhost:8081', '/wallet/email', queryParameters);

    var response = await http.get(uri, headers: {
      'Content-Type': 'text/plain; charset=utf-8',
    });

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return Future.value(false); // Email already exists
    } else {
      return Future.value(true); // Email is available
    }
  }

  // ===== EXACT BACKEND CALLS FROM OLD LOGIN_STORE.DART =====

  // OTP generation - exact implementation from old code
  Future<dynamic> getOtpByNoTelGestion(String noTelGest, String montant) async {
    dynamic otp;
    try {
      if (noTelGest == null) return Future.error('Num de Tél non fournie');

      String strMontant;
      if (montant != null && '0'.allMatches(montant).length != 2) {
        strMontant = '&montant=' + montant;
      } else {
        strMontant = "";
      }

      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/otp/generate?noTelGest=' +
              noTelGest + strMontant));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        otp = jsonDecode(response.body);
        return otp;
      } else if (response.statusCode <= 206) {
        return null;
      } else if (response.statusCode == 422) {
        return response;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }

  // Nominative OTP generation - exact implementation from old code
  Future<dynamic> getOtpNominatifByNoTelGestion(String noTelGest, String montant,
      String code, String numId, String nom, String prenom) async {
    dynamic otp;
    try {
      if (noTelGest == null) return Future.error('Num de Tél non fournie');

      String strMontant;
      if (montant != null && '0'.allMatches(montant).length != 2) {
        strMontant = '&montant=' + montant;
      } else {
        strMontant = "";
      }

      final response = await http.post(
        Uri.parse('http://${backendServer}:8081/otp/generate'),
        body: {
          'userTel': termsConditionsModel.phoneNumber,
          'noTelGest': noTelGest,
          'montant': montant,
          'codeId': code,
          'numId': numId,
          'nom': nom,
          'prenom': prenom
        }
      );

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        otp = jsonDecode(response.body);
        return otp;
      } else if (response.statusCode <= 206) {
        return null;
      } else if (response.statusCode == 422) {
        return response;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }

  // OTP validation and login - simple comparison for now
  Future<bool> validateOtpAndLogin(BuildContext context, String enteredOtp) async {
    // Compare entered OTP with generated oneTimePass
    if (enteredOtp == oneTimePass.toString()) {
      // OTP matches - navigate to account type selection screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.accountTypeSelectionScreen);
      return true;
    } else {
      // OTP doesn't match
      return false;
    }
  }


  // Legacy validateOtp method for backward compatibility
  bool validateOtp(String enteredOtp) {
    return termsConditionsModel.generatedOtp == enteredOtp;
  }

  // ===== EXACT IMPLEMENTATION FROM OLD LOGIN_STORE.DART =====

  // Observable variable for OTP - exact from old code
  late int oneTimePass = 123;

  // sendOtp method - EXACT implementation from old login_store.dart (simplified)
  Future<void> sendOtp(String tel) async {
    int otpMax;
    int otpMin;
    otpMin = 100000;
    otpMax = 1000000;

    // Generate OTP exactly as in old code
    oneTimePass = otpMin + Random().nextInt(otpMax - otpMin);

    ///use back end Api to notify the client
    print('OTP sent to $tel: $oneTimePass');
  }

  // handleNextButtonPress method - EXACT logic from old login_store.dart
  Future<void> handleNextButtonPress(BuildContext context, String phoneNumber) async {
    // Validate actions before proceeding - exact from old code
    if (phoneNumber.isEmpty) {
      buildSuccessMessage(context, 'Numéro de téléphone requis', isError: true);
      return;
    }

    // Send OTP using exact sendOtp method
    await sendOtp(phoneNumber);

    // Navigate to OTP screen - exact flow from old code
    Navigator.of(context).pushNamed(
      AppRoutes.otpScreen,
      arguments: phoneNumber,
    );
  }

  // Error and success message handling - exact implementation from old code
  void buildSuccessMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? appTheme.errorColor : appTheme.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show loading state
  void showLoading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(appTheme.onPrimary),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: appTheme.primaryColor,
        duration: const Duration(seconds: 10), // Long duration for loading
      ),
    );
  }

  // Hide loading state
  void hideLoading(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}