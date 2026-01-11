import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:millime/core/build_info.dart';
import 'package:millime/core/repository/auth_repository.dart';
import 'package:millime/core/utils/http_client_wrapper.dart';
import 'package:millime/core/utils/navigator_service.dart';
import 'package:millime/routes/app_routes.dart';

/// Authentication Provider for state management using Provider pattern
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository.instance;

  late HttpClientWrapper httpClientWrapper;
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isRefreshingToken = false; // Token refresh loading state
  String? _errorMessage;
  String? _currentPhoneNumber;
  String? _currentPassword;
  String? _currentPin;
  dynamic _userAccount;
  String? _authMethod; // 'password' or 'pin'
  
  // Token management
  Timer? _tokenRefreshTimer;
  DateTime? _lastTokenCheck;
  static const int _tokenCheckIntervalMinutes = 5;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isRefreshingToken => _isRefreshingToken;
  String? get errorMessage => _errorMessage;
  String? get currentPhoneNumber => _currentPhoneNumber;
  String? get currentPassword => _currentPassword;
  String? get currentPin => _currentPin;
  dynamic get userAccount => _userAccount;
  String? get authMethod => _authMethod;
  AuthRepository get authRepository => _authRepository;



  /// Initialize authentication provider
  void initialize(String backendServer) {
    _authRepository.initialize(backendServer);
    httpClientWrapper=new HttpClientWrapper();
    _checkAuthStatus();
    _initializeTokenRefresh();
  }

  /// Initialize automatic token refresh
  void _initializeTokenRefresh() {
    _startTokenRefreshTimer();
  }

  /// Start periodic token refresh timer
  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer();
    
    if (_isAuthenticated) {
      _tokenRefreshTimer = Timer.periodic(
        Duration(minutes: _tokenCheckIntervalMinutes),
        (timer) {
          _checkAndRefreshToken();
        },
      );
    }
  }


  Future<dynamic> getCompteByTelGestionPlus(String tel) async {
    dynamic compte;
    try {
      final response = await httpClientWrapper.getUrl(
          'http://${backendServer}:8081/compte/telgestplus/' + tel + '/');

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        compte = jsonDecode(response.body);
        clearError();

        return compte;
      } else if (response.statusCode == 422) {
          return Future.error(response);
       
      } 

      return null;
    } catch (e) {
      return null;
    }
  }



  /// Check and refresh token if needed
  Future<void> _checkAndRefreshToken() async {
    if (!_isAuthenticated || _isRefreshingToken) {
      return;
    }

    try {
      final shouldRefresh = await _authRepository.shouldRefreshToken();
      if (shouldRefresh) {
        print('Token needs refresh - attempting refresh...');
        await _performTokenRefresh();
      }
    } catch (e) {
      print('Token refresh check error: $e');
    }
  }

  /// Perform token refresh with error handling
  Future<bool> _performTokenRefresh() async {
    if (_isRefreshingToken) {
      return false; // Already refreshing
    }

    try {
      _isRefreshingToken = true;
      notifyListeners();

      final success = await _authRepository.refreshAccessToken();

      if (success) {
        print('Token refreshed successfully in AuthProvider');
        _errorMessage = null;
      } else {
        print('Token refresh failed - logging out user');
        _errorMessage = 'Session expirée, veuillez vous reconnecter';
        
        // Logout user after a delay to show error message
        Future.delayed(Duration(seconds: 2), () {
          logout();
        });
      }

      return success;
    } catch (e) {
      print('Token refresh error in AuthProvider: $e');
      _errorMessage = 'Erreur de rafraîchissement de session';
      return false;
    } finally {
      _isRefreshingToken = false;
      notifyListeners();
    }
  }

  /// Stop token refresh timer
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Check current authentication status
  void _checkAuthStatus() {
    _isAuthenticated = _authRepository.isAuthenticated;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Login with phone number and password
  Future<bool> loginWithPassword(BuildContext context, String phoneNumber, String password) async {
    try {
      _setLoading(true);
      clearError();

      // Validate input
      if (phoneNumber.isEmpty || password.isEmpty) {
        _setError('Veuillez remplir tous les champs');
        return false;
      }

      if (phoneNumber.length < 8) {
        _setError('Numéro de téléphone invalide');
        return false;
      }

      // Perform login
      final result = await _authRepository.login(context, phoneNumber, password);
      
      if (result != null) {
        _isAuthenticated = true;
        _currentPhoneNumber = phoneNumber;
        _currentPassword = password;
        _authMethod = 'password';
        _userAccount = await _authRepository.getAccountByPhoneNumber(phoneNumber);
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.accountDashboardScreen);

        _startTokenRefreshTimer();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Échec de la connexion');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      if (e is AuthException) {
        if (e.code == 'NEED_EMAIL_VERIFICATION') {
          // First login detected - store phone number and redirect to password update screen
          _currentPhoneNumber = phoneNumber;
          _setError('Première connexion - mise à jour du mot de passe requise');
          // Navigate to password update screen after a brief delay, passing phone number
          Future.delayed(Duration(milliseconds: 777), () {
            NavigatorService.pushNamed(
              AppRoutes.passwordUpdateScreen,
              arguments: {'phoneNumber': phoneNumber},
            );
          });
          return false;
        }
        _setError(e.message);
      } else {
        _setError('Erreur de connexion');
      }
      return false;
    }
  }

  /// Login with phone number and PIN
  Future<bool> loginWithPin(BuildContext context, String phoneNumber, String pin) async {
    try {
      _setLoading(true);
      clearError();

      // Validate input
      if (phoneNumber.isEmpty || pin.isEmpty) {
        _setError('Veuillez remplir tous les champs');
        return false;
      }

      if (phoneNumber.length < 8) {
        _setError('Numéro de téléphone invalide');
        return false;
      }

      if (pin.length != 6) {
        _setError('Le code PIN doit contenir 6 chiffres');
        return false;
      }

      // Perform login with PIN
      final result = await _authRepository.loginWithPin(context, phoneNumber, pin);
      
      if (result != null) {
        _isAuthenticated = true;
        _currentPhoneNumber = phoneNumber;
        _currentPin = pin;
        _authMethod = 'pin';
        _userAccount = await _authRepository.getAccountByPhoneNumber(phoneNumber);
        
        _startTokenRefreshTimer();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Échec de la connexion avec PIN');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      if (e is AuthException) {
        if (e.code == 'FIRST_LOGIN') {
          // First login detected - store phone number and redirect to password update screen
          _currentPhoneNumber = phoneNumber;
          _setError('Première connexion - mise à jour du mot de passe requise');
          // Navigate to password update screen after a brief delay, passing phone number
          Future.delayed(Duration(milliseconds: 500), () {
            NavigatorService.pushNamed(
              AppRoutes.passwordUpdateScreen,
              arguments: {'phoneNumber': phoneNumber},
            );
          });
          return false;
        }
        _setError(e.message);
      } else {
        _setError('Erreur de connexion avec PIN');
      }
      return false;
    }
  }

  /// Logout user
  void logout() {
    _authRepository.logout();
    _authRepository.clearAllTokens();
    
    _isAuthenticated = false;
    _currentPhoneNumber = null;
    _currentPassword = null;
    _currentPin = null;
    _userAccount = null;
    _authMethod = null;
    _errorMessage = null;
    _isRefreshingToken = false;
    
    _stopTokenRefreshTimer();
    
    notifyListeners();
    
    // Navigate to login screen
    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
  }

  /// Update password
  Future<bool> updatePassword(String oldPassword, String newPassword, String confirmPassword, {bool isFirstLogin = false, String? phoneNumber}) async {
    try {
      _setLoading(true);
      clearError();

      // Validate input
      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        _setError('Veuillez remplir tous les champs');
        _setLoading(false);
        return false;
      }

      if (newPassword != confirmPassword) {
        _setError('Les mots de passe ne correspondent pas');
        _setLoading(false);
        return false;
      }

      if (newPassword.length < 6) {
        _setError('Le mot de passe doit contenir au moins 6 caractères');
        _setLoading(false);
        return false;
      }

      // Use provided phone number for first login, otherwise use stored one
      final String phoneToUse = isFirstLogin 
          ? (phoneNumber ?? _currentPhoneNumber ?? '')
          : (_currentPhoneNumber ?? '');
      
      if (phoneToUse.isEmpty) {
        _setError('Numéro de téléphone non disponible');
        _setLoading(false);
        return false;
      }

      // Update password
      final success = await _authRepository.updatePassword(
        phoneToUse,
        oldPassword,
        newPassword,
      );

      if (success) {
        _currentPassword = newPassword;
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Échec de la mise à jour du mot de passe');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      if (e is AuthException) {
        _setError(e.message);
      } else {
        _setError('Erreur lors de la mise à jour du mot de passe');
      }
      return false;
    }
  }

  /// Update password and PIN
  Future<bool> updatePasswordAndPin(String oldPassword, String newPassword, String confirmPassword, String pin) async {
    try {
      _setLoading(true);
      clearError();

      // Validate input
      if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || pin.isEmpty) {
        _setError('Veuillez remplir tous les champs');
        return false;
      }

      if (newPassword != confirmPassword) {
        _setError('Les mots de passe ne correspondent pas');
        return false;
      }

      if (newPassword.length < 6) {
        _setError('Le mot de passe doit contenir au moins 6 caractères');
        return false;
      }

      if (pin.length != 4) {
        _setError('Le code PIN doit contenir 4 chiffres');
        return false;
      }

      if (_currentPhoneNumber == null) {
        _setError('Numéro de téléphone non disponible');
        return false;
      }

      // Update password and PIN
      final success = await _authRepository.updatePasswordAndPin(
        _currentPhoneNumber!,
        oldPassword,
        newPassword,
        pin,
      );

      if (success) {
        _currentPassword = newPassword;
        _currentPin = pin;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Échec de la mise à jour');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      if (e is AuthException) {
        _setError(e.message);
      } else {
        _setError('Erreur lors de la mise à jour');
      }
      return false;
    }
  }

  /// Send OTP for password reset
  Future<bool> sendOtpForPasswordReset(String phoneNumber) async {
    try {
      _setLoading(true);
      clearError();

      if (phoneNumber.isEmpty || phoneNumber.length < 8) {
        _setError('Numéro de téléphone invalide');
        return false;
      }

      final success = await _authRepository.sendOtpForPasswordReset(phoneNumber);
      
      _setLoading(false);
      
      if (!success) {
        _setError('Échec de l\'envoi du code OTP');
      }
      
      return success;
    } catch (e) {
      _setLoading(false);
      _setError('Erreur lors de l\'envoi du code OTP');
      return false;
    }
  }

  /// Verify OTP and reset password
  Future<bool> verifyOtpAndResetPassword(String phoneNumber, String otp, String newPassword, String confirmPassword) async {
    try {
      _setLoading(true);
      clearError();

      // Validate input
      if (phoneNumber.isEmpty || otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
        _setError('Veuillez remplir tous les champs');
        return false;
      }

      if (newPassword != confirmPassword) {
        _setError('Les mots de passe ne correspondent pas');
        return false;
      }

      if (newPassword.length < 6) {
        _setError('Le mot de passe doit contenir au moins 6 caractères');
        return false;
      }

      final success = await _authRepository.verifyOtpAndResetPassword(phoneNumber, otp, newPassword);
      
      _setLoading(false);
      
      if (success) {
        // Navigate to login screen after successful password reset
        NavigatorService.pushNamed(AppRoutes.loginScreen);
        return true;
      } else {
        _setError('Code OTP incorrect ou expiré');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Erreur lors de la réinitialisation du mot de passe');
      return false;
    }
  }

  /// Check if user has PIN authentication available
  bool get hasPinAuth {
    return _userAccount != null && _userAccount["pin"] != null;
  }

  /// Get authentication methods available for user
  List<String> get availableAuthMethods {
    List<String> methods = [];
    
    if (hasPinAuth) {
      methods.add('pin');
    }
    
    // Password is always available if user is authenticated
    if (_isAuthenticated) {
      methods.add('password');
    }
    
    return methods;
  }

  /// Switch authentication method
  void switchAuthMethod(String method) {
    if (availableAuthMethods.contains(method)) {
      _authMethod = method;
      notifyListeners();
    }
  }

  /// Navigate to home screen after successful authentication
  void navigateToHome(BuildContext context) {
    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.accountDashboardScreen);
  }

  /// Navigate to account recovery screen
  void navigateToAccountRecovery(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.accountRecoveryScreen);
  }

  /// Navigate to registration screen
  void navigateToRegistration(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.termsConditionsScreenV2);
  }

  // ===== TOKEN MANAGEMENT METHODS =====

  /// Manually refresh token
  Future<bool> refreshToken() async {
    if (!_isAuthenticated) {
      _setError('Non authentifié');
      return false;
    }

    return await _performTokenRefresh();
  }

  /// Check token status
  Future<Map<String, dynamic>> getTokenStatus() async {
    return await _authRepository.getTokenStatus();
  }

  /// Check if session is still valid
  Future<bool> checkSessionValidity() async {
    try {
      final isValid = await _authRepository.isSessionValid();
      if (!isValid) {
        _isAuthenticated = false;
        notifyListeners();
      }
      return isValid;
    } catch (e) {
      print('Session validity check error: $e');
      return false;
    }
  }

  /// Handle app resume - check and refresh token
  Future<void> onAppResume() async {
    if (!_isAuthenticated) {
      return;
    }

    try {
      // Check if token needs refresh when app resumes
      final shouldRefresh = await _authRepository.shouldRefreshToken();
      if (shouldRefresh) {
        await _performTokenRefresh();
      }
    } catch (e) {
      print('App resume token check error: $e');
    }
  }

  /// Handle token refresh failure
  void handleTokenRefreshFailure() {
    _errorMessage = 'Session expirée, veuillez vous reconnecter';
    _authRepository.handleTokenRefreshFailure();
    
    // Logout after showing error message
    Future.delayed(Duration(seconds: 3), () {
      logout();
    });
    
    notifyListeners();
  }

  /// Get token information for debugging
  Future<Map<String, dynamic>?> getTokenInfo() async {
    return await _authRepository.getTokenInfo();
  }

  /// Validate current token
  Future<bool> validateCurrentToken() async {
    return await _authRepository.isTokenValid();
  }

  /// Get valid access token
  Future<String?> getValidAccessToken() async {
    return await _authRepository.getValidAccessToken();
  }

  @override
  void dispose() {
    _stopTokenRefreshTimer();
    super.dispose();
  }

  void setErrorMessage(String? err) {
      _errorMessage=err;
  }
}