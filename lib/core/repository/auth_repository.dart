import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:millime/core/utils/http_client_wrapper.dart';

/// Authentication Repository for OAuth2/OpenID Connect authentication
class AuthRepository {
  static AuthRepository? _instance;
  static AuthRepository get instance => _instance ??= AuthRepository._();
  
  AuthRepository._();

  late HttpClientWrapper _httpClient;
  String? _backendServer;
  static const String _clientId = 'flutter-client';
  static const String _realm = 'millime';

  /// Initialize the repository with backend server
  void initialize(String backendServer) {
    _backendServer = backendServer;
    _httpClient = HttpClientWrapper();
    _httpClient.setBackendServer(backendServer);
  }

  /// Get SSO URL for authentication
  String getSSOUrl() {
    return "http://$_backendServer:8080/realms/$_realm";
  }

  /// Authenticate user with username and password
  static Future<String?> authenticate(String username, String password) async {
    try {
      final url = "${instance.getSSOUrl()}/protocol/openid-connect/token";
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'content-type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'username': username,
          'password': password,
          'grant_type': 'password',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        print('Authentication failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  /// Login with phone number and password
  Future<dynamic> login(BuildContext context, String phoneNumber, String password) async {
    try {
      final url = "${getSSOUrl()}/protocol/openid-connect/token";

      Map<String, String> headers = {
        'content-type': 'application/x-www-form-urlencoded',
      };

      Map<String, String> data = {
        'client_id': _clientId,
        'username': phoneNumber,
        'password': password,
        'grant_type': 'password'
      };

      final response = await _httpClient.postUrl(
        url,
        headers: headers,
        body: data,
        requiresAuth: false, // Don't add Authorization header for OAuth2 login
      );

      print('Login response: ${response.body}');
      print('Login status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final token = json.decode(response.body);
        
        // Update HTTP client with tokens
        _httpClient.updateTokens(
          token["access_token"], 
          token["refresh_token"]
        );
        
        return token;
      } else if (response.statusCode == 401) {
        // Check for first login indicator in response
        final responseBody = json.decode(response.body);
        final errorDescription = responseBody['error_description'] ?? '';
        
        if (errorDescription.toString().contains('FIRST_LOGIN') || 
            responseBody['error'] == 'FIRST_LOGIN' ||
            responseBody['first_login'] == true) {
          throw AuthException("FIRST_LOGIN", "Première connexion - mise à jour du mot de passe requise");
        }
        
        throw AuthException("NOT_AUTHORIZED", "Numéro de téléphone ou mot de passe incorrect");
      } else if (response.statusCode == 400) {
        throw AuthException("NEED_EMAIL_VERIFICATION", "Veuillez vérifier votre adresse email");
      } else {
        throw AuthException("SERVER_ERROR", "Erreur du serveur");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("NETWORK_ERROR", "Erreur de connexion");
    }
  }

  /// Login with phone number and PIN
  Future<dynamic> loginWithPin(BuildContext context, String phoneNumber, String pin) async {
    try {
      // First, get user account info
      final accountInfo = await getAccountByPhoneNumber(phoneNumber);
      
      if (accountInfo == null) {
        throw AuthException("USER_NOT_FOUND", "Utilisateur non trouvé");
      }

      // Extract PIN from account info (PIN is part of the stored data)
      final storedPin = accountInfo["pin"]?.toString();
      if (storedPin == null || storedPin.isEmpty) {
        throw AuthException("PIN_NOT_SET", "Code PIN non configuré");
      }

      // Validate PIN (assuming PIN is stored with some formatting)
      // This is a simplified validation - adjust based on your backend logic
      if (pin.length == 4 && pin == storedPin.substring(storedPin.length - 4)) {
        // Use the full password (PIN + additional data) for authentication
        final fullPassword = storedPin; // This should be the complete password
        
        // Perform login with the extracted password
        return await login(context, phoneNumber, fullPassword);
      } else {
        throw AuthException("INVALID_PIN", "Code PIN incorrect");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("LOGIN_ERROR", "Erreur lors de la connexion avec PIN");
    }
  }

  /// Get account information by phone number
  Future<dynamic?> getAccountByPhoneNumber(String phoneNumber) async {
    try {
      final url = "${_httpClient.getBackendUrl()}/compte/telgestion/$phoneNumber";
      
      final response = await _httpClient.getUrl(url);
      
      if (response.statusCode == 200 && response.contentLength! > 0) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting account info: $e');
      return null;
    }
  }

  /// Update password
  Future<bool> updatePassword(String phoneNumber, String oldPassword, String newPassword, 
      {bool temporary = false, bool notifyBySMS = false, bool notifyByEmail = true}) async {
    try {
      final url = "${_httpClient.getBackendUrl()}/api/user/$phoneNumber/reset-password";
      
      final response = await _httpClient.postUrl(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: {
          'newPassword': newPassword,
          'oldPassword': oldPassword,
          'temporaire': temporary,
          'notifBySMS': notifyBySMS,
          'notifByMAIL': notifyByEmail
        },
        requiresAuth: false
      );

      if (response.statusCode <= 206) {
        return response.contentLength! > 0 ? false : true;
      } else {
        throw AuthException("UPDATE_FAILED", "Échec de la mise à jour du mot de passe");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("NETWORK_ERROR", "Erreur de connexion lors de la mise à jour");
    }
  }

  /// Update password and PIN
  Future<bool> updatePasswordAndPin(String phoneNumber, String oldPassword, String newPassword, 
      String pin, {bool temporary = false, bool notifyBySMS = false, bool notifyByEmail = true}) async {
    try {
      final url = "${_httpClient.getBackendUrl()}/api/user/$phoneNumber/reset-password";
      
      final response = await _httpClient.postUrl(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: {
          'newPassword': newPassword,
          'oldPassword': oldPassword,
          'temporaire': temporary,
          'notifBySMS': notifyBySMS,
          'notifByMAIL': notifyByEmail,
          'pin': pin
        },
      );

      if (response.statusCode <= 206) {
        return response.contentLength! > 0 ? false : true;
      } else {
        throw AuthException("UPDATE_FAILED", "Échec de la mise à jour");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("NETWORK_ERROR", "Erreur de connexion lors de la mise à jour");
    }
  }

  /// Send OTP for password reset
  Future<bool> sendOtpForPasswordReset(String phoneNumber) async {
    try {
      // This would typically call your backend to send OTP
      final url = "${_httpClient.getBackendUrl()}/user/otp/send";
      
      final response = await _httpClient.postUrl(
        url,
        body: {'phoneNumber': phoneNumber},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  /// Verify OTP and reset password
  Future<bool> verifyOtpAndResetPassword(String phoneNumber, String otp, String newPassword) async {
    try {
      final url = "${_httpClient.getBackendUrl()}/user/otp/verify";
      
      final response = await _httpClient.postUrl(
        url,
        body: {
          'phoneNumber': phoneNumber,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  /// Logout user
  void logout() {
    _httpClient.clearTokens();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _httpClient.isAuthenticated;

  /// Get current access token
  String? get accessToken => _httpClient.accessToken;

  /// Get current refresh token
  String? get refreshToken => _httpClient.refreshToken;

  /// Get HTTP client for other API calls
  HttpClientWrapper get httpClient => _httpClient;

  // ===== TOKEN REFRESH METHODS =====

  /// Check if current token is valid and not expired
  Future<bool> isTokenValid() async {
    try {
      return await _httpClient.validateToken();
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  /// Check if token should be refreshed (within buffer time)
  Future<bool> shouldRefreshToken() async {
    try {
      final tokenInfo = await getTokenInfo();
      return tokenInfo?['shouldRefresh'] ?? false;
    } catch (e) {
      print('Token refresh check error: $e');
      return true; // Refresh if we can't check
    }
  }

  /// Get token expiry information
  Future<Map<String, dynamic>?> getTokenInfo() async {
    try {
      return await _httpClient.getTokenInfo();
    } catch (e) {
      print('Token info error: $e');
      return null;
    }
  }

  /// Manually refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    try {
      print('Attempting to refresh access token...');
      final success = await _httpClient.refreshTokens();
      
      if (success) {
        print('Access token refreshed successfully');
        return true;
      } else {
        print('Failed to refresh access token');
        return false;
      }
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  /// Check token expiry status
  Future<Map<String, dynamic>> getTokenStatus() async {
    try {
      final tokenInfo = await getTokenInfo();
      
      if (tokenInfo == null) {
        return {
          'isAuthenticated': false,
          'isExpired': true,
          'shouldRefresh': false,
          'timeRemaining': 0,
          'expiresAt': null,
        };
      }

      return {
        'isAuthenticated': _httpClient.isAuthenticated,
        'isExpired': tokenInfo['isExpired'] ?? false,
        'shouldRefresh': tokenInfo['shouldRefresh'] ?? false,
        'timeRemaining': tokenInfo['timeRemaining'] ?? 0,
        'expiresAt': tokenInfo['expiresAt'],
      };
    } catch (e) {
      print('Token status check error: $e');
      return {
        'isAuthenticated': false,
        'isExpired': true,
        'shouldRefresh': true,
        'timeRemaining': 0,
        'expiresAt': null,
      };
    }
  }

  /// Validate and refresh token if needed
  Future<String?> getValidAccessToken() async {
    try {
      // Check if we have a valid token
      if (!_httpClient.isAuthenticated) {
        return null;
      }

      // Get token (will automatically refresh if needed)
      final token = await _httpClient.validAccessToken;
      
      if (token == null) {
        print('No valid access token available');
        return null;
      }

      // Validate token
      final isValid = await isTokenValid();
      if (!isValid) {
        print('Current token is invalid, attempting refresh...');
        final refreshSuccess = await refreshAccessToken();
        if (refreshSuccess) {
          return await _httpClient.validAccessToken;
        } else {
          return null;
        }
      }

      return token;
    } catch (e) {
      print('Error getting valid access token: $e');
      return null;
    }
  }

  /// Clear all stored tokens (for logout or token invalidation)
  void clearAllTokens() {
    try {
      _httpClient.clearTokens();
      print('All tokens cleared successfully');
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  /// Check if user session is active and valid
  Future<bool> isSessionValid() async {
    try {
      final tokenStatus = await getTokenStatus();
      final isAuthenticated = tokenStatus['isAuthenticated'] as bool;
      final isExpired = tokenStatus['isExpired'] as bool;
      
      return isAuthenticated && !isExpired;
    } catch (e) {
      print('Session validation error: $e');
      return false;
    }
  }

  /// Handle token refresh failure (triggers logout)
  void handleTokenRefreshFailure() {
    print('Token refresh failed - clearing session and triggering logout');
    clearAllTokens();
    // Note: The actual logout and navigation will be handled by AuthProvider
  }

  /// Preemptively refresh token (called periodically or on app resume)
  Future<bool> preemptiveTokenRefresh() async {
    try {
      final shouldRefresh = await shouldRefreshToken();
      
      if (shouldRefresh) {
        print('Preemptively refreshing token...');
        return await refreshAccessToken();
      }
      
      return true; // No refresh needed
    } catch (e) {
      print('Preemptive token refresh error: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.dispose();
  }
}

