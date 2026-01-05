import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP Client Wrapper with comprehensive token refresh logic
class HttpClientWrapper {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const int _refreshBufferMinutes = 5; // Refresh token 5 minutes before expiry
  
  final http.Client _client;
  String? _backendServer;
  String? _realm;
  
  // Token refresh management
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];
  
  // Cached token values for synchronous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  DateTime? _cachedTokenExpiry;

  HttpClientWrapper({http.Client? client}) : _client = client ?? http.Client();

  /// Initialize with backend server and realm
  void setBackendServer(String backendServer, {String realm = 'millime'}) {
    _backendServer = backendServer;
    _realm = realm;
  }

  /// Update tokens after successful login
  void updateTokens(String accessToken, String refreshToken, {int expiresIn = 3600}) {
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    _cachedTokenExpiry = expiry;
    _saveToken(accessToken, refreshToken, expiry);
  }

  /// Clear all stored tokens
  void clearTokens() {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedTokenExpiry = null;
    _clearTokens();
  }

  /// Get current access token (cached)
  String? get accessToken => _cachedAccessToken;

  /// Get current refresh token (cached)
  String? get refreshToken => _cachedRefreshToken;

  /// Check if user is authenticated
  bool get isAuthenticated {
    return _cachedAccessToken != null && !_isTokenExpiredCached();
  }

  /// Get SSO URL for authentication
  String getSSOUrl() {
    return "http://$_backendServer:8080/realms/$_realm";
  }

  /// Get backend server URL
  String getBackendUrl() {
    return "http://$_backendServer:8081";
  }

  /// Get token with automatic refresh if needed
  Future<String?> get validAccessToken async {
    if (!isAuthenticated) {
      return null;
    }
    
    // Load token from storage if not cached
    if (_cachedAccessToken == null) {
      await _loadTokensFromStorage();
    }
    
    // Check if token needs refresh
    if (_shouldRefreshTokenCached()) {
      await refreshTokens();
    }
    
    return _cachedAccessToken;
  }

  /// Manually refresh tokens
  Future<bool> refreshTokens() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      return completer.future;
    }
    
    try {
      _isRefreshing = true;
      
      final refreshTokenValue = _cachedRefreshToken;
      if (refreshTokenValue == null) {
        _isRefreshing = false;
        _completeAllCompleters(false);
        return false;
      }
      
      // Use OAuth2 token endpoint for refresh
      final refreshUrl = "${getSSOUrl()}/protocol/openid-connect/token";
      
      final response = await _client.post(
        Uri.parse(refreshUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': 'flutter-client',
          'grant_type': 'refresh_token',
          'refresh_token': refreshTokenValue,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'] ?? refreshTokenValue;
        final expiresIn = data['expires_in'] ?? 3600;
        final expiry = DateTime.now().add(Duration(seconds: expiresIn));
        
        _cachedAccessToken = newAccessToken;
        _cachedRefreshToken = newRefreshToken;
        _cachedTokenExpiry = expiry;
        
        await _saveToken(newAccessToken, newRefreshToken, expiry);
        
        print('Token refreshed successfully');
        _isRefreshing = false;
        _completeAllCompleters(true);
        return true;
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        // Refresh token is invalid or expired
        print('Refresh token failed: ${response.body}');
        clearTokens();
        _isRefreshing = false;
        _completeAllCompleters(false);
        return false;
      } else {
        print('Unexpected token refresh response: ${response.statusCode}');
        _isRefreshing = false;
        _completeAllCompleters(false);
        return false;
      }
    } catch (e) {
      print('Token refresh error: $e');
      _isRefreshing = false;
      _completeAllCompleters(false);
      return false;
    }
  }

  /// Complete all pending refresh completers
  void _completeAllCompleters(bool result) {
    for (final completer in _refreshCompleters) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }
    _refreshCompleters.clear();
  }

  /// POST request with automatic token refresh
  Future<http.Response> postUrl(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      Map<String, String> requestHeaders = headers ?? {};
      
      // Add authentication if required
      if (requiresAuth) {
        final token = await validAccessToken;
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      // Only set default Content-Type if not already specified
      // Check case-insensitively for content-type
      bool hasContentType = requestHeaders.keys.any((key) => 
        key.toLowerCase() == 'content-type');
      
      print('DEBUG: hasContentType = $hasContentType');
      print('DEBUG: requestHeaders.keys = ${requestHeaders.keys.toList()}');
      print('DEBUG: requestHeaders = $requestHeaders');
      
      if (!hasContentType) {
        requestHeaders['Content-Type'] = 'application/json';
        print('DEBUG: Added default Content-Type: application/json');
      } else {
        print('DEBUG: Content-Type already exists, preserving original');
      }
      
      // Only set default Accept if not already specified
      if (!requestHeaders.containsKey('Accept')) {
        requestHeaders['Accept'] = 'application/json';
      }
      
      // Handle body encoding based on content type (case-insensitive check)
      String? actualContentType;
      try {
        actualContentType = requestHeaders.keys.firstWhere(
          (key) => key.toLowerCase() == 'content-type',
        );
      } catch (e) {
        // No content-type header found
        actualContentType = null;
      }
      
      print('DEBUG: actualContentType = $actualContentType');
      if (actualContentType != null) {
        print('DEBUG: Content-Type value = ${requestHeaders[actualContentType]}');
      }
      
      dynamic encodedBody;
      if (actualContentType != null && 
          requestHeaders[actualContentType]!.toLowerCase() == 'application/x-www-form-urlencoded') {
        // For form-urlencoded, use the map directly (http package handles this)
        encodedBody = body;
        print('DEBUG: Using form-urlencoded encoding');
      } else {
        // For JSON, encode the body
        encodedBody = body != null ? jsonEncode(body) : null;
        print('DEBUG: Using JSON encoding');
      }
      
      final response = await _client.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: encodedBody,
      );
      
      print('DEBUG: Final request headers: $requestHeaders');
      print('DEBUG: Final request body type: ${encodedBody.runtimeType}');
      
      // Handle 401 response - attempt token refresh
      if (response.statusCode == 401 && requiresAuth) {
        final refreshSuccess = await refreshTokens();
        if (refreshSuccess) {
          // Retry original request with new token
          final newToken = await validAccessToken;
          if (newToken != null) {
            requestHeaders['Authorization'] = 'Bearer $newToken';
            
            // Handle body encoding for retry (case-insensitive check)
            String? actualContentType = requestHeaders.keys.firstWhere(
              (key) => key.toLowerCase() == 'content-type',
            );
            
            dynamic encodedBody;
            if (actualContentType != null && 
                requestHeaders[actualContentType]!.toLowerCase() == 'application/x-www-form-urlencoded') {
              encodedBody = body;
            } else {
              encodedBody = body != null ? jsonEncode(body) : null;
            }
            
            return await _client.post(
              Uri.parse(url),
              headers: requestHeaders,
              body: encodedBody,
            );
          }
        } else {
          // Refresh failed - user needs to login again
          throw AuthException("TOKEN_REFRESH_FAILED", "Session expirée, veuillez vous reconnecter");
        }
      }
      
      return response;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw Exception('POST request failed: $e');
    }
  }

  /// GET request with automatic token refresh
  Future<http.Response> getUrl(
    String url, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      Map<String, String> requestHeaders = headers ?? {};
      
      // Add authentication if required
      if (requiresAuth) {
        final token = await validAccessToken;
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      requestHeaders.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      
      final response = await _client.get(
        Uri.parse(url),
        headers: requestHeaders,
      );
      
      // Handle 401 response - attempt token refresh
      if (response.statusCode == 401 && requiresAuth) {
        final refreshSuccess = await refreshTokens();
        if (refreshSuccess) {
          // Retry original request with new token
          final newToken = await validAccessToken;
          if (newToken != null) {
            requestHeaders['Authorization'] = 'Bearer $newToken';
            return await _client.get(
              Uri.parse(url),
              headers: requestHeaders,
            );
          }
        } else {
          // Refresh failed - user needs to login again
          throw AuthException("TOKEN_REFRESH_FAILED", "Session expirée, veuillez vous reconnecter");
        }
      }
      
      return response;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw Exception('GET request failed: $e');
    }
  }

  /// PUT request with automatic token refresh
  Future<http.Response> putUrl(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      Map<String, String> requestHeaders = headers ?? {};
      
      // Add authentication if required
      if (requiresAuth) {
        final token = await validAccessToken;
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      // Only set default Content-Type if not already specified
      if (!requestHeaders.containsKey('Content-Type')) {
        requestHeaders['Content-Type'] = 'application/json';
      }
      
      // Only set default Accept if not already specified
      if (!requestHeaders.containsKey('Accept')) {
        requestHeaders['Accept'] = 'application/json';
      }
      
      final response = await _client.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      
      // Handle 401 response - attempt token refresh
      if (response.statusCode == 401 && requiresAuth) {
        final refreshSuccess = await refreshTokens();
        if (refreshSuccess) {
          // Retry original request with new token
          final newToken = await validAccessToken;
          if (newToken != null) {
            requestHeaders['Authorization'] = 'Bearer $newToken';
            return await _client.put(
              Uri.parse(url),
              headers: requestHeaders,
              body: body != null ? jsonEncode(body) : null,
            );
          }
        } else {
          // Refresh failed - user needs to login again
          throw AuthException("TOKEN_REFRESH_FAILED", "Session expirée, veuillez vous reconnecter");
        }
      }
      
      return response;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw Exception('PUT request failed: $e');
    }
  }

  /// DELETE request with automatic token refresh
  Future<http.Response> deleteUrl(
    String url, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      Map<String, String> requestHeaders = headers ?? {};
      
      // Add authentication if required
      if (requiresAuth) {
        final token = await validAccessToken;
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      // Only set default Content-Type if not already specified
      if (!requestHeaders.containsKey('Content-Type')) {
        requestHeaders['Content-Type'] = 'application/json';
      }
      
      // Only set default Accept if not already specified
      if (!requestHeaders.containsKey('Accept')) {
        requestHeaders['Accept'] = 'application/json';
      }
      
      final response = await _client.delete(
        Uri.parse(url),
        headers: requestHeaders,
      );
      
      // Handle 401 response - attempt token refresh
      if (response.statusCode == 401 && requiresAuth) {
        final refreshSuccess = await refreshTokens();
        if (refreshSuccess) {
          // Retry original request with new token
          final newToken = await validAccessToken;
          if (newToken != null) {
            requestHeaders['Authorization'] = 'Bearer $newToken';
            return await _client.delete(
              Uri.parse(url),
              headers: requestHeaders,
            );
          }
        } else {
          // Refresh failed - user needs to login again
          throw AuthException("TOKEN_REFRESH_FAILED", "Session expirée, veuillez vous reconnecter");
        }
      }
      
      return response;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Validate current token
  Future<bool> validateToken() async {
    final token = _cachedAccessToken;
    if (token == null) return false;
    
    try {
      // Simple JWT validation (in production, use a proper JWT library)
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      // Check if token is expired
      return !_isTokenExpiredCached();
    } catch (e) {
      return false;
    }
  }

  /// Get token expiry information
  Future<Map<String, dynamic>?> getTokenInfo() async {
    if (_cachedTokenExpiry == null) {
      await _loadTokensFromStorage();
    }
    
    if (_cachedTokenExpiry == null) return null;
    
    final now = DateTime.now();
    final timeRemaining = _cachedTokenExpiry!.difference(now);
    
    return {
      'expiresAt': _cachedTokenExpiry!.toIso8601String(),
      'timeRemaining': timeRemaining.inSeconds,
      'isExpired': timeRemaining.isNegative,
      'shouldRefresh': _shouldRefreshTokenCached(),
    };
  }

  /// Check if token should be refreshed (within buffer time) - cached version
  bool _shouldRefreshTokenCached() {
    if (_cachedTokenExpiry == null) return true;
    
    final bufferDuration = Duration(minutes: _refreshBufferMinutes);
    return DateTime.now().isAfter(_cachedTokenExpiry!.subtract(bufferDuration));
  }

  /// Check if token is expired - cached version
  bool _isTokenExpiredCached() {
    if (_cachedTokenExpiry == null) return true;
    return DateTime.now().isAfter(_cachedTokenExpiry!);
  }

  /// Load tokens from storage
  Future<void> _loadTokensFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedAccessToken = prefs.getString(_tokenKey);
    _cachedRefreshToken = prefs.getString(_refreshTokenKey);
    
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString != null) {
      try {
        _cachedTokenExpiry = DateTime.parse(expiryString);
      } catch (e) {
        _cachedTokenExpiry = null;
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
    _completeAllCompleters(false);
    _refreshCompleters.clear();
  }

  // Private methods for token management
  
  Future<void> _saveToken(String token, String refreshToken, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  Future<bool> _isTokenExpired() async {
    if (_cachedTokenExpiry == null) {
      await _loadTokensFromStorage();
    }
    if (_cachedTokenExpiry == null) return true;
    return DateTime.now().isAfter(_cachedTokenExpiry!);
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}
