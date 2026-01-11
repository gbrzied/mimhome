import 'package:flutter/material.dart';
import 'package:millime/core/repository/auth_repository.dart';
import 'package:millime/core/utils/navigator_service.dart';
import 'package:millime/routes/app_routes.dart';
import 'package:millime/core/build_info.dart';
import '../models/password_update_model.dart';

class PasswordUpdateProvider extends ChangeNotifier {
  PasswordUpdateModel passwordUpdateModel = PasswordUpdateModel();

  // Form validation state
  bool _isLoading = false;
  String? _errorMessage;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Password validation state
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  String? _phoneNumber; // Store phone number from login flow
  TextEditingController? _newPasswordController;
  TextEditingController? _confirmPasswordController;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get newPasswordError => _newPasswordError;
  String? get confirmPasswordError => _confirmPasswordError;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get hasMinLength => _hasMinLength;
  bool get hasUpperCase => _hasUpperCase;
  bool get hasLowerCase => _hasLowerCase;
  bool get hasNumber => _hasNumber;
  bool get hasSpecialChar => _hasSpecialChar;
  bool get isFormValid => _hasMinLength && _hasUpperCase && _hasLowerCase && _hasNumber;

  void initialize([String? phoneNumber, TextEditingController? newPasswordController, TextEditingController? confirmPasswordController]) {
    _phoneNumber = phoneNumber;
    _newPasswordController = newPasswordController;
    _confirmPasswordController = confirmPasswordController;
    print('DEBUG: PasswordUpdateProvider.initialize() - phoneNumber: $_phoneNumber');
    notifyListeners();
  }

  /// Toggle new password visibility
  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  /// Update new password and validate
  void updateNewPassword(String password) {
    passwordUpdateModel.newPasswordController = password;
    _newPasswordController?.text = password;
    _validatePassword(password);
    _updateFormValidity();
    notifyListeners();
  }

  /// Update confirm password and validate
  void updateConfirmPassword(String password) {
    passwordUpdateModel.confirmPasswordController = password;
    _confirmPasswordController?.text = password;
    _validateConfirmPassword();
    notifyListeners();
  }

  /// Validate password against requirements
  void _validatePassword(String password) {
    if (password.isEmpty) {
      _newPasswordError = null;
      _resetPasswordRequirements();
      return;
    }

    _hasMinLength = password.length >= 8;
    _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    _hasLowerCase = password.contains(RegExp(r'[a-z]'));
    _hasNumber = password.contains(RegExp(r'[0-9]'));
    _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!_hasMinLength) {
      _newPasswordError = 'Le mot de passe doit contenir au moins 8 caractères';
    } else if (!_hasUpperCase) {
      _newPasswordError = 'Le mot de passe doit contenir une lettre majuscule';
    } else if (!_hasLowerCase) {
      _newPasswordError = 'Le mot de passe doit contenir une lettre minuscule';
    } else if (!_hasNumber) {
      _newPasswordError = 'Le mot de passe doit contenir un chiffre';
    } else {
      _newPasswordError = null;
    }
  }

  /// Reset password requirements
  void _resetPasswordRequirements() {
    _hasMinLength = false;
    _hasUpperCase = false;
    _hasLowerCase = false;
    _hasNumber = false;
    _hasSpecialChar = false;
  }

  /// Validate confirm password
  void _validateConfirmPassword() {
    final newPassword = _newPasswordController?.text ?? passwordUpdateModel.newPasswordController ?? '';
    final confirmPassword = _confirmPasswordController?.text ?? passwordUpdateModel.confirmPasswordController ?? '';

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = null;
      return;
    }

    if (newPassword != confirmPassword) {
      _confirmPasswordError = 'Les mots de passe ne correspondent pas';
    } else {
      _confirmPasswordError = null;
    }
  }

  /// Update overall form validity
  void _updateFormValidity() {
    // Check if confirm password matches new password
    final newPassword = _newPasswordController?.text ?? passwordUpdateModel.newPasswordController ?? '';
    final confirmPassword = _confirmPasswordController?.text ?? passwordUpdateModel.confirmPasswordController ?? '';

    if (confirmPassword.isNotEmpty && newPassword != confirmPassword) {
      _confirmPasswordError = 'Les mots de passe ne correspondent pas';
    } else {
      _confirmPasswordError = null;
    }
  }

  /// Clear error messages
  void clearErrors() {
    _errorMessage = null;
    _newPasswordError = null;
    _confirmPasswordError = null;
    notifyListeners();
  }

  /// Submit new password
  Future<bool> submitPassword(BuildContext context) async {
    final newPassword = _newPasswordController?.text ?? passwordUpdateModel.newPasswordController ?? '';
    final confirmPassword = _confirmPasswordController?.text ?? passwordUpdateModel.confirmPasswordController ?? '';

    // Validate all fields
    if (newPassword.isEmpty) {
      _newPasswordError = 'Veuillez entrer votre nouveau mot de passe';
      notifyListeners();
      return false;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Veuillez confirmer votre mot de passe';
      notifyListeners();
      return false;
    }

    if (!_hasMinLength || !_hasUpperCase || !_hasLowerCase || !_hasNumber) {
      _errorMessage = 'Le mot de passe ne respecte pas les exigences';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _confirmPasswordError = 'Les mots de passe ne correspondent pas';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Use stored phone number from login flow
      final phoneNumber = _phoneNumber;
      print('DEBUG: PasswordUpdateProvider.submitPassword() - phoneNumber: $phoneNumber');

      if (phoneNumber == null) {
        _errorMessage = 'Session expirée, veuillez vous reconnecter';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create AuthRepository instance directly for API call (avoiding AuthProvider token refresh)
      final authRepository = AuthRepository.instance;
      authRepository.initialize(backendServer);
      
      // Update password on server (for first login, use empty old password, no auth required)
      final success = await authRepository.updatePassword(
        phoneNumber,
        '',
        newPassword,
      );

      if (success) {
        _isLoading = false;
        notifyListeners();
        
        // Navigate to main app screen
       // NavigatorService.pushNamedAndRemoveUntil(AppRoutes.accountDashboardScreen);
        authRepository.logout();
        await NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);

        return true;
      } else {
        _errorMessage = 'Échec de la mise à jour du mot de passe';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion, veuillez réessayer';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Navigate back to login
  void navigateToLogin(BuildContext context) {
    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
  }
}
