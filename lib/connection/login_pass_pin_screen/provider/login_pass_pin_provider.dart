import 'package:millime/core/utils/functions.dart';
import 'package:millime/core/utils/navigator_service.dart';
import 'package:millime/core/provider/auth_provider.dart';
import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'package:millime/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../models/login_pass_pin_model.dart';
import 'package:millime/core/build_info.dart';

class LoginPassPinProvider extends ChangeNotifier {
  LoginPassPinModel loginPassPinModel = LoginPassPinModel();
  AuthProvider? _authProvider;
  static const PIN_LENGTH = 6;
  static const ID_LENGTH = 8;
  
  // Form validation state
  bool _isFormValid = false;
  String? _phoneNumberError;
  String? _passwordError;
  String? _pinError;
  
  // Form field states
  String _phoneNumber = '';
  String _password = '';
  String _pin = '';
  
  // Current authentication mode: 'password' or 'pin'
  String _authMode = 'password';
  String get authMode => _authMode;
  
  // Account existence flag
  bool? bAccountExists;
  
  // PIN extracted from account
  String? accountPin;
  String? currentPassword;

  

  // Proxy getters for AuthProvider properties
  bool get isLoading {
    final provider = authProvider;
    final loading = provider?.isLoading ?? false;
    return loading;
  }

  String? get errorMessage {
    final provider = authProvider;
    final error = provider?.errorMessage;
    return error;
  }

  bool get isAuthenticated {
    final provider = authProvider;
    final authenticated = provider?.isAuthenticated ?? false;
    return authenticated;
  }

  // Form validation getters
  bool get isFormValid => _isFormValid;
  String? get phoneNumberError => _phoneNumberError;
  String? get passwordError => _passwordError;
  String? get pinError => _pinError;

  // Form field getters
  String get phoneNumber => _phoneNumber;
  String get password => _password;
  String get pin => _pin;

  void initialize() {
    try {
      // Initialize AuthProvider with backend server
      _authProvider = AuthProvider();
      _authProvider!.initialize(backendServer);
      debugPrint('LoginPassPinProvider: AuthProvider initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('LoginPassPinProvider: Failed to initialize AuthProvider: $e');
      // Initialize with null AuthProvider but continue
      _authProvider = null;
      notifyListeners();
    }
  }

  /// Toggle between password and PIN authentication modes
  void toggleAuthMode() {
    _authMode = _authMode == 'password' ? 'pin' : 'password';
    clearErrors();
    notifyListeners();
  }

  /// Set authentication mode explicitly
  void setAuthMode(String mode) {
    if (mode == 'password' || mode == 'pin') {
      _authMode = mode;
      clearErrors();
      notifyListeners();
    }
  }

  /// Update phone number and validate
  void updatePhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    _validatePhoneNumber();
    _updateFormValidity();
    loginPassPinModel.phoneNumberController = phoneNumber;
    notifyListeners();
  }

  /// Update password and validate
  void updatePassword(String password) {
    _password = password;
    _validatePassword();
    _updateFormValidity();
    loginPassPinModel.passwordController = password;
    notifyListeners();
  }

  /// Update PIN and validate
  void updatePin(String pin) {
    _pin = pin;
    _validatePin();
    _updateFormValidity();
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
    loginPassPinModel.phoneNumberController = '';
    loginPassPinModel.passwordController = '';
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
    if (_pin.length != 6) {
      _pinError = 'Le code PIN doit contenir 6 chiffres';
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(_pin)) {
      _pinError = 'Le code PIN ne doit contenir que des chiffres';
      return;
    }
    _pinError = null;
  }

  /// Update overall form validity
  void _updateFormValidity() {
    bool hasPhoneNumber = _phoneNumber.trim().isNotEmpty &&
        _phoneNumber.length >= 8 &&
        isValidTunisianMobile(_phoneNumber);
    
    if (_authMode == 'password') {
      bool hasPassword = _password.isNotEmpty && _password.length >= 6;
      _isFormValid = hasPhoneNumber && hasPassword;
    } else {
      bool hasPin = _pin.isNotEmpty && _pin.length == 6 && RegExp(r'^\d+$').hasMatch(_pin);
      _isFormValid = hasPhoneNumber && hasPin;
    }
  }


  /// Handle login based on current auth mode
  Future<bool> handleLogin(BuildContext context) async {
    try {
      // Validate inputs before attempting login
      if (_phoneNumber.trim().isEmpty) {
        _phoneNumberError = 'Veuillez entrer votre numéro de téléphone';
        notifyListeners();
        return false;
      }

      // Ensure AuthProvider is initialized
      final authProvider = this.authProvider;
      if (authProvider == null) {
        debugPrint('LoginPassPinProvider: AuthProvider is null, cannot proceed with login');
        _phoneNumberError = 'Service d\'authentification non disponible';
        notifyListeners();
        return false;
      }

      if (_authMode == 'password') {
        if (_password.isEmpty) {
          _passwordError = 'Veuillez entrer votre mot de passe';
          notifyListeners();
          return false;
        }

        debugPrint('LoginPassPinProvider: Attempting password login for phone: $_phoneNumber');
        final success = await authProvider.loginWithPassword(
          context,
          _phoneNumber,
          _password,
        );

        if (success) {
          debugPrint('LoginPassPinProvider: Password login successful, clearing form');
          clearForm();
        } else {
          debugPrint('LoginPassPinProvider: Password login failed');
        }

        notifyListeners();
        return success;
      } else {
        if (_pin.isEmpty) {
          _pinError = 'Veuillez entrer votre code PIN';
          notifyListeners();
          return false;
        }

        debugPrint('LoginPassPinProvider: Attempting PIN login for phone: $_phoneNumber');


        String pin=compte["pin"];
        accountPin=pin.toString().substring(ID_LENGTH,ID_LENGTH+PIN_LENGTH);
        currentPassword=pin.toString().substring(ID_LENGTH+PIN_LENGTH,pin.length);
 
 if (_pin != accountPin) {
           authProvider?.setErrorMessage('Code PIN incorrect');
          notifyListeners();
          debugPrint('LoginPassPinProvider: Incorrect PIN entered');
          return false;
        }
       final success = await authProvider.loginWithPassword(
          context,
          _phoneNumber,
          currentPassword!,
        );


        if (success) {
          debugPrint('LoginPassPinProvider: PIN login successful, clearing form');
          clearForm();
        } else {
          debugPrint('LoginPassPinProvider: PIN login failed');
        }

        notifyListeners();
        return success;
      }
    } catch (e) {
    debugPrint('LoginPassPinProvider: Login error: $e');
    _phoneNumberError = 'Erreur de connexion: ${e.toString()}';
    notifyListeners();
    return false;
  }
  }

  /// Navigate to home screen after successful authentication
  void navigateToHome(BuildContext context) {
    final provider = authProvider;
    if (provider != null) {
      provider.navigateToHome(context);
    } else {
      // Fallback navigation if AuthProvider is not available
      NavigatorService.pushNamedAndRemoveUntil(
        AppRoutes.accountDashboardScreen,
      );
    }
  }

  /// Navigate to forgot password screen
  void navigateToForgotPassword(BuildContext context) {
    // Navigate to password update screen for forgot password functionality
    NavigatorService.pushNamed(AppRoutes.passwordUpdateScreen);
  }

  /// Navigate to account recovery screen
  void navigateToAccountRecovery(BuildContext context) {
    final provider = authProvider;
    if (provider != null) {
      provider.navigateToAccountRecovery(context);
    } else {
      // Fallback navigation if AuthProvider is not available
      NavigatorService.pushNamed(AppRoutes.accountRecoveryScreen);
    }
  }

  void navigateToRegistration(BuildContext context) {
    // Navigation logic to registration screen
    NavigatorService.pushNamed(AppRoutes.termsConditionsScreenV2);
  }

  /// Ensure AuthProvider is initialized
  void _ensureAuthProviderInitialized() {
    if (_authProvider == null) {
      debugPrint('LoginPassPinProvider: Lazy initializing AuthProvider');
      try {
        _authProvider = AuthProvider();
        _authProvider!.initialize(backendServer);
        debugPrint('LoginPassPinProvider: AuthProvider lazy initialized successfully');
      } catch (e) {
        debugPrint('LoginPassPinProvider: Failed to lazy initialize AuthProvider: $e');
        _authProvider = null;
      }
    }
  }

  /// Get AuthProvider instance (with lazy initialization)
  AuthProvider? get authProvider {
    _ensureAuthProviderInitialized();
    return _authProvider;
  }

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
    if (_authMode == 'password') {
      _validatePassword();
    } else {
      _validatePin();
    }
    _updateFormValidity();
    notifyListeners();
    return _isFormValid;
  }

  /// Check if phone number is valid (for conditional UI)
  bool get isPhoneNumberValid {
    return _phoneNumber.trim().isNotEmpty &&
        _phoneNumber.length >= 8 &&
        isValidTunisianMobile(_phoneNumber);
  }

  /// Debug method to check AuthProvider status
  void debugAuthProviderStatus() {
    final provider = authProvider;
    debugPrint('LoginPassPinProvider Debug:');
    debugPrint('  AuthProvider available: ${provider != null}');
    debugPrint('  Backend server: $backendServer');
    if (provider != null) {
      debugPrint('  AuthProvider isLoading: ${provider.isLoading}');
      debugPrint('  AuthProvider isAuthenticated: ${provider.isAuthenticated}');
      debugPrint('  AuthProvider errorMessage: ${provider.errorMessage}');
    }
  }

  /// Clear password field
  void clearPassword() {
    _password = '';
    loginPassPinModel.passwordController = '';
    _passwordError = null;
    notifyListeners();
  }

  /// Login with password (convenience method)
  Future<bool> loginWithPassword(BuildContext context) async {
    return await handleLogin(context);
  }

    dynamic compte;
    /// Public getter for compte
    dynamic get compteValue => compte;
  /// Get account by phone number
  Future<dynamic> getCompteByTelGestionPlus(String tel) async {
    try {
      clearErrors();
      final authProvider = this.authProvider;
      if (authProvider == null) {
        debugPrint('LoginPassPinProvider: AuthProvider is null, cannot get account');
        _phoneNumberError = 'Service d\'authentification non disponible';
        notifyListeners();
        return null;
      }

      compte = await authProvider.getCompteByTelGestionPlus(tel);

      if (compte == null){
        bAccountExists = false;
        authProvider.setErrorMessage("key_no_account_with".tr)  ;
        //_phoneNumberError = "key_no_account_with".tr;
        notifyListeners();
      }
      else {
        bAccountExists = true;


      }
    } catch (e) {
      return null;
    }
    notifyListeners();
    return compte;
  }
}
