import 'package:millime/core/utils/functions.dart';
import 'package:millime/core/utils/navigator_service.dart';
import 'package:millime/core/provider/auth_provider.dart';
import 'package:millime/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../models/login_pass_pin_model.dart';
import 'package:millime/core/build_info.dart';


class LoginPassPinProvider extends ChangeNotifier {
  LoginPassPinModel loginScreenModel = LoginPassPinModel();
  AuthProvider? _authProvider;

  // Form validation state
  bool _isFormValid = false;
  String? _phoneNumberError;
  String? _passwordError;
  String? _pinError;

  // Form field states
  String _phoneNumber = '';
  String _password = '';
  String _pin = '';
  bool _rememberMe = false;

  // Proxy getters for AuthProvider properties
  bool get isLoading => _authProvider?.isLoading ?? false;
  String? get errorMessage => _authProvider?.errorMessage;
  bool get isAuthenticated => _authProvider?.isAuthenticated ?? false;

  // Form validation getters
  bool get isFormValid => _isFormValid;
  String? get phoneNumberError => _phoneNumberError;
  String? get passwordError => _passwordError;
  String? get pinError => _pinError;

  // Form field getters
  String get phoneNumber => _phoneNumber;
  String get password => _password;
  String get pin => _pin;
  bool get rememberMe => _rememberMe;

  void initialize() {
    // Initialize AuthProvider with backend server
    // In a real app, this would come from configuration
    _authProvider = AuthProvider();
    _authProvider!.initialize(backendServer); // Default backend server
    notifyListeners();
  }

  /// Update phone number and validate
  void updatePhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    _validatePhoneNumber();
    _updateFormValidity();
    notifyListeners();
  }

  /// Update password and validate
  void updatePassword(String password) {
    _password = password;
    _validatePassword();
    _updateFormValidity();
    notifyListeners();
  }

  /// Update PIN and validate
  void updatePin(String pin) {
    _pin = pin;
    _validatePin();
    _updateFormValidity();
    notifyListeners();
  }

  /// Update remember me preference
  void updateRememberMe(bool rememberMe) {
    _rememberMe = rememberMe;
    notifyListeners();
  }

  /// Clear all form errors
  void clearErrors() {
    _phoneNumberError = null;
    _passwordError = null;
    _pinError = null;
    _authProvider?.clearError();
    notifyListeners();
  }

  /// Clear all form fields
  void clearForm() {
    _phoneNumber = '';
    _password = '';
    _pin = '';
    _rememberMe = false;
    clearErrors();
    _updateFormValidity();
    notifyListeners();
  }

  /// Validate phone number
  void _validatePhoneNumber() {
    if (_phoneNumber.trim().isEmpty) {
      _phoneNumberError = 'Veuillez entrer votre numéro de téléphone';
      return;
    }
    if (_phoneNumber.length < 8) {
      _phoneNumberError = 'Numéro de téléphone invalide';
      return;
    }
    if (!isValidTunisianMobile(_phoneNumber)) {
      _phoneNumberError = 'Format de numéro invalide';
      return;
    }
    _phoneNumberError = null;
  }

  /// Validate password
  void _validatePassword() {
    if (_password.isEmpty) {
      _passwordError = 'Veuillez entrer votre mot de passe';
      return;
    }
    if (_password.length < 6) {
      _passwordError = 'Le mot de passe doit contenir au moins 6 caractères';
      return;
    }
    _passwordError = null;
  }

  /// Validate PIN
  void _validatePin() {
    if (_pin.isEmpty) {
      _pinError = 'Veuillez entrer votre code PIN';
      return;
    }
    if (_pin.length != 4) {
      _pinError = 'Le code PIN doit contenir 4 chiffres';
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(_pin)) {
      _pinError = 'Le code PIN ne doit contenir que des chiffres';
      return;
    }
    _pinError = null;
  }

  /// Update overall form validity
  void _updateFormValidity() {
    bool hasPhoneNumber = _phoneNumber.trim().isNotEmpty && _phoneNumber.length >= 8;
    bool hasValidPassword = _password.isNotEmpty && _password.length >= 6;
    bool hasValidPin = _pin.length == 4 && RegExp(r'^[0-9]+$').hasMatch(_pin);
    
    // Form is valid if phone number is valid AND (password is valid OR PIN is valid)
    _isFormValid = hasPhoneNumber && (hasValidPassword || hasValidPin);
  }

  /// Update error message
  void updateErrorMessage(String? errorMessage) {
    // Use AuthProvider's error handling
    _authProvider?.clearError();
    if (errorMessage != null) {
      // We'll set this directly in the login methods
    }
    notifyListeners();
  }

  /// Login with phone number and password
  Future<bool> loginWithPassword(BuildContext context, String phoneNumber, String password) async {
    try {
      // Validate inputs before attempting login
      if (phoneNumber.trim().isEmpty) {
        _phoneNumberError = 'Veuillez entrer votre numéro de téléphone';
        notifyListeners();
        return false;
      }
      
      if (password.isEmpty) {
        _passwordError = 'Veuillez entrer votre mot de passe';
        notifyListeners();
        return false;
      }

      if (_authProvider == null) return false;
      final success = await _authProvider!.loginWithPassword(context, phoneNumber, password);
      
      if (success) {
        // Clear form on successful login
        clearForm();
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Login with password error: $e');
      return false;
    }
  }

  /// Login with phone number and PIN
  Future<bool> loginWithPin(BuildContext context, String phoneNumber, String pin) async {
    try {
      // Validate inputs before attempting login
      if (phoneNumber.trim().isEmpty) {
        _phoneNumberError = 'Veuillez entrer votre numéro de téléphone';
        notifyListeners();
        return false;
      }
      
      if (pin.isEmpty) {
        _pinError = 'Veuillez entrer votre code PIN';
        notifyListeners();
        return false;
      }

      if (pin.length != 6) {
        _pinError = 'Le code PIN doit contenir 4 chiffres';
        notifyListeners();
        return false;
      }

      if (_authProvider == null) return false;
      final success = await _authProvider!.loginWithPin(context, phoneNumber, pin);
      
      if (success) {
        // Clear form on successful login
        clearForm();
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Login with PIN error: $e');
      return false;
    }
  }

  /// Navigate to home screen after successful authentication
  void navigateToHome(BuildContext context) {
    _authProvider?.navigateToHome(context);
  }

  /// Navigate to account recovery screen
  void navigateToAccountRecovery(BuildContext context) {
    _authProvider?.navigateToAccountRecovery(context);
  }

  void navigateToRegistration(BuildContext context) {
    // Navigation logic to registration screen
    NavigatorService.pushNamed(AppRoutes.termsConditionsScreenV2);
  }

  /// Get AuthProvider instance
  AuthProvider? get authProvider => _authProvider;

  /// Check if form can be submitted
  bool canSubmitForm() {
    return _isFormValid && !isLoading;
  }

  /// Get validation error for a specific field
  String? getFieldError(String fieldName) {
    switch (fieldName) {
      case 'phoneNumber':
        return _phoneNumberError;
      case 'password':
        return _passwordError;
      case 'pin':
        return _pinError;
      default:
        return null;
    }
  }

  /// Validate entire form
  bool validateForm() {
    _validatePhoneNumber();
    _validatePassword();
    _validatePin();
    _updateFormValidity();
    notifyListeners();
    return _isFormValid;
  }

  // dispose() is handled by ChangeNotifier
}