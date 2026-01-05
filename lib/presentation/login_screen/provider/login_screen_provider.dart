import 'package:millime/core/utils/functions.dart';
import 'package:millime/core/utils/navigator_service.dart';
import 'package:millime/core/provider/auth_provider.dart';
import 'package:millime/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../models/login_screen_model.dart';
import 'package:millime/core/build_info.dart';

class LoginScreenProvider extends ChangeNotifier {
  LoginScreenModel loginScreenModel = LoginScreenModel();
  AuthProvider? _authProvider;

  // Form validation state
  bool _isFormValid = false;
  String? _phoneNumberError;
  String? _passwordError;

  // Form field states
  String _phoneNumber = '';
  String _password = '';

  // Proxy getters for AuthProvider properties
  bool get isLoading {
    final provider = authProvider;
    final loading = provider?.isLoading ?? false;
    // debugPrint('LoginScreenProvider: isLoading = $loading (provider: ${provider != null})');
    return loading;
  }
  
  String? get errorMessage {
    final provider = authProvider;
    final error = provider?.errorMessage;
    // debugPrint('LoginScreenProvider: errorMessage = $error (provider: ${provider != null})');
    return error;
  }
  
  bool get isAuthenticated {
    final provider = authProvider;
    final authenticated = provider?.isAuthenticated ?? false;
    // debugPrint('LoginScreenProvider: isAuthenticated = $authenticated (provider: ${provider != null})');
    return authenticated;
  }

  // Form validation getters
  bool get isFormValid => _isFormValid;
  String? get phoneNumberError => _phoneNumberError;
  String? get passwordError => _passwordError;

  // Form field getters
  String get phoneNumber => _phoneNumber;
  String get password => _password;

  void initialize() {
    try {
      // Initialize AuthProvider with backend server
      _authProvider = AuthProvider();
      _authProvider!.initialize(backendServer);
      debugPrint('LoginScreenProvider: AuthProvider initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('LoginScreenProvider: Failed to initialize AuthProvider: $e');
      // Initialize with null AuthProvider but continue
      _authProvider = null;
      notifyListeners();
    }
  }

  /// Update phone number and validate
  void updatePhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    _validatePhoneNumber();
    _updateFormValidity();
    
    // Reset password field when phone number changes
    if (loginScreenModel.phoneNumberController != phoneNumber) {
      _password = '';
      loginScreenModel.passwordController = '';
    }
    
    loginScreenModel.phoneNumberController = phoneNumber;
    notifyListeners();
  }

  /// Update password and validate
  void updatePassword(String password) {
    _password = password;
    _validatePassword();
    _updateFormValidity();
    loginScreenModel.passwordController = password;
    notifyListeners();
  }

  /// Clear all form errors
  void clearErrors() {
    _phoneNumberError = null;
    _passwordError = null;
    _authProvider?.clearError();
    loginScreenModel.errorMessage = null;
    notifyListeners();
  }

  /// Clear all form fields
  void clearForm() {
    _phoneNumber = '';
    _password = '';
    loginScreenModel.phoneNumberController = '';
    loginScreenModel.passwordController = '';
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

  /// Update overall form validity
  void _updateFormValidity() {
    bool hasPhoneNumber = _phoneNumber.trim().isNotEmpty && _phoneNumber.length >= 8 && isValidTunisianMobile(_phoneNumber);
    bool hasPassword = _password.isNotEmpty && _password.length >= 6;
    
    // Form is valid if phone number is valid and password is provided
    _isFormValid = hasPhoneNumber && hasPassword;
  }

  /// Legacy method for backward compatibility
  void validatePhoneNumber(BuildContext context) {
    _validatePhoneNumber();
    
    if (_phoneNumberError != null) {
      updateErrorMessage(_phoneNumberError);
      return;
    }

    // Clear error and proceed - password field will now be visible
    updateErrorMessage(null);
  }

  /// Update error message
  void updateErrorMessage(String? errorMessage) {
    loginScreenModel.errorMessage = errorMessage;
    if (errorMessage == null) {
      _authProvider?.clearError();
    }
    notifyListeners();
  }

  /// Login with phone number and password
  Future<bool> loginWithPassword(BuildContext context) async {
    try {
      // Validate inputs before attempting login
      if (_phoneNumber.trim().isEmpty) {
        _phoneNumberError = 'Veuillez entrer votre numéro de téléphone';
        notifyListeners();
        return false;
      }
      
      if (_password.isEmpty) {
        _passwordError = 'Veuillez entrer votre mot de passe';
        notifyListeners();
        return false;
      }

      // Ensure AuthProvider is initialized
      final provider = authProvider;
      if (provider == null) {
        debugPrint('LoginScreenProvider: AuthProvider is null, cannot proceed with login');
        updateErrorMessage('Service d\'authentification non disponible');
        return false;
      }
      
      debugPrint('LoginScreenProvider: Attempting login for phone: $_phoneNumber');
      final success = await provider.loginWithPassword(context, _phoneNumber, _password);
      
      if (success) {
        debugPrint('LoginScreenProvider: Login successful, clearing form');
        // Clear form on successful login
        clearForm();
      } else {
        debugPrint('LoginScreenProvider: Login failed');
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('LoginScreenProvider: Login with password error: $e');
      updateErrorMessage('Erreur de connexion: ${e.toString()}');
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
      NavigatorService.pushNamedAndRemoveUntil(AppRoutes.accountDashboardScreen);
    }
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
      debugPrint('LoginScreenProvider: Lazy initializing AuthProvider');
      try {
        _authProvider = AuthProvider();
        _authProvider!.initialize(backendServer);
        debugPrint('LoginScreenProvider: AuthProvider lazy initialized successfully');
      } catch (e) {
        debugPrint('LoginScreenProvider: Failed to lazy initialize AuthProvider: $e');
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
      default:
        return null;
    }
  }

  /// Validate entire form
  bool validateForm() {
    _validatePhoneNumber();
    _validatePassword();
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

  /// Get authentication method (always 'password' for this screen)
  String get authMethod => 'password';

  /// Check if AuthProvider is available
  bool get isAuthProviderAvailable {
    final provider = authProvider;
    return provider != null;
  }

  /// Debug method to check AuthProvider status
  void debugAuthProviderStatus() {
    final provider = authProvider;
    debugPrint('LoginScreenProvider Debug:');
    debugPrint('  AuthProvider available: ${provider != null}');
    debugPrint('  Backend server: $backendServer');
    if (provider != null) {
      debugPrint('  AuthProvider isLoading: ${provider.isLoading}');
      debugPrint('  AuthProvider isAuthenticated: ${provider.isAuthenticated}');
      debugPrint('  AuthProvider errorMessage: ${provider.errorMessage}');
    }
  }
}