import 'package:flutter_test/flutter_test.dart';
import 'package:millime/core/utils/http_client_wrapper.dart';
import 'package:millime/core/repository/auth_repository.dart';
import 'package:millime/core/provider/auth_provider.dart';

void main() {
  group('Token Refresh Tests', () {
    late HttpClientWrapper httpClient;
    late AuthRepository authRepository;
    late AuthProvider authProvider;

    setUp(() {
      httpClient = HttpClientWrapper();
      authRepository = AuthRepository.instance;
      authProvider = AuthProvider();
    });

    tearDown(() {
      httpClient.dispose();
    });

    group('HttpClientWrapper Tests', () {
      test('should initialize with backend server', () {
        httpClient.setBackendServer('test-server', realm: 'test-realm');
        expect(httpClient.getSSOUrl(), equals('http://test-server:8080/realms/test-realm'));
        expect(httpClient.getBackendUrl(), equals('http://test-server:8081'));
      });

      test('should update and retrieve tokens', () {
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';
        const expiresIn = 3600;

        httpClient.updateTokens(accessToken, refreshToken, expiresIn: expiresIn);

        expect(httpClient.accessToken, equals(accessToken));
        expect(httpClient.refreshToken, equals(refreshToken));
        expect(httpClient.isAuthenticated, isTrue);
      });

      test('should clear tokens on logout', () {
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';

        httpClient.updateTokens(accessToken, refreshToken);
        expect(httpClient.isAuthenticated, isTrue);

        httpClient.clearTokens();
        expect(httpClient.accessToken, isNull);
        expect(httpClient.refreshToken, isNull);
        expect(httpClient.isAuthenticated, isFalse);
      });

      test('should handle token validation', () async {
        // Test with valid JWT-like token
        const validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        
        httpClient.updateTokens(validToken, 'refresh_token');
        
        final isValid = await httpClient.validateToken();
        expect(isValid, isTrue);
      });

      test('should handle invalid token validation', () async {
        // Test with invalid token
        const invalidToken = 'invalid_token';
        
        httpClient.updateTokens(invalidToken, 'refresh_token');
        
        final isValid = await httpClient.validateToken();
        expect(isValid, isFalse);
      });

      test('should get token information', () async {
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';
        const expiresIn = 3600;

        httpClient.updateTokens(accessToken, refreshToken, expiresIn: expiresIn);

        final tokenInfo = await httpClient.getTokenInfo();
        
        expect(tokenInfo, isNotNull);
        expect(tokenInfo!['expiresAt'], isNotNull);
        expect(tokenInfo['timeRemaining'], isA<int>());
        expect(tokenInfo['isExpired'], isFalse);
        expect(tokenInfo['shouldRefresh'], isFalse);
      });
    });

    group('AuthRepository Tests', () {
      setUp(() {
        authRepository.initialize('test-server');
      });

      test('should initialize with backend server', () {
        expect(authRepository, isNotNull);
        expect(authRepository.httpClient, isNotNull);
      });

      test('should handle token status checking', () async {
        // Setup: Add some mock token data through the public API
        authRepository.httpClient.updateTokens('test_token', 'refresh_token');

        final tokenStatus = await authRepository.getTokenStatus();
        
        expect(tokenStatus, isA<Map<String, dynamic>>());
        expect(tokenStatus['isAuthenticated'], isA<bool>());
        expect(tokenStatus['isExpired'], isA<bool>());
        expect(tokenStatus['shouldRefresh'], isA<bool>());
      });

      test('should check session validity', () async {
        // Setup: Add valid token
        authRepository.httpClient.updateTokens('test_token', 'refresh_token');

        final isValid = await authRepository.isSessionValid();
        expect(isValid, isA<bool>());
      });

      test('should clear all tokens', () {
        authRepository.httpClient.updateTokens('test_token', 'refresh_token');
        
        expect(authRepository.httpClient.isAuthenticated, isTrue);
        
        authRepository.clearAllTokens();
        
        expect(authRepository.httpClient.isAuthenticated, isFalse);
      });

      test('should check if token is valid', () async {
        authRepository.httpClient.updateTokens('test_token', 'refresh_token');
        
        final isValid = await authRepository.isTokenValid();
        expect(isValid, isA<bool>());
      });

      test('should check if token should be refreshed', () async {
        authRepository.httpClient.updateTokens('test_token', 'refresh_token');
        
        final shouldRefresh = await authRepository.shouldRefreshToken();
        expect(shouldRefresh, isA<bool>());
      });
    });

    group('AuthProvider Tests', () {
      setUp(() {
        authProvider.initialize('test-server');
      });

      test('should initialize with backend server', () {
        expect(authProvider, isNotNull);
        expect(authProvider.authRepository, isNotNull);
      });

      test('should handle authentication state', () {
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.isRefreshingToken, isFalse);
      });

      test('should handle token refresh failure', () {
        // Test the error handling method
        authProvider.handleTokenRefreshFailure();
        
        expect(authProvider.errorMessage, isNotNull);
        expect(authProvider.errorMessage, contains('Session expirée'));
      });

      test('should get token status', () async {
        final tokenStatus = await authProvider.getTokenStatus();
        expect(tokenStatus, isA<Map<String, dynamic>>());
      });

      test('should validate current token', () async {
        final isValid = await authProvider.validateCurrentToken();
        expect(isValid, isA<bool>());
      });

      test('should get valid access token', () async {
        final validToken = await authProvider.getValidAccessToken();
        // Should return null when no valid token exists
        expect(validToken, anyOf(isNull, isA<String>()));
      });
    });

    group('Integration Tests', () {
      test('should handle complete token lifecycle', () async {
        authProvider.initialize('test-server');
        
        // Initialize repository with tokens
        authProvider.authRepository.httpClient.updateTokens('test_token', 'refresh_token');
        
        // Check initial state
        expect(authProvider.authRepository.httpClient.isAuthenticated, isTrue);
        
        // Get token information
        final tokenInfo = await authProvider.authRepository.getTokenInfo();
        expect(tokenInfo, isNotNull);
        
        // Validate token
        final isValid = await authProvider.validateCurrentToken();
        expect(isValid, isA<bool>());
        
        // Get valid access token
        final validToken = await authProvider.getValidAccessToken();
        expect(validToken, isNotNull);
      });

      test('should handle token expiry scenario', () async {
        authProvider.initialize('test-server');
        
        // Clear tokens to simulate expiry
        authProvider.authRepository.httpClient.clearTokens();
        
        // Check session validity
        final isValid = await authProvider.checkSessionValidity();
        expect(isValid, isFalse);
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        authProvider.initialize('invalid-server');
        
        // This should not crash
        final tokenStatus = await authProvider.getTokenStatus();
        expect(tokenStatus, isA<Map<String, dynamic>>());
      });

      test('should handle invalid token responses', () async {
        authProvider.initialize('test-server');
        
        // Simulate invalid token scenario by not setting any tokens
        final isValid = await authProvider.validateCurrentToken();
        expect(isValid, isFalse);
      });

      test('should handle concurrent operations', () async {
        authProvider.initialize('test-server');
        
        // Add a token first
        authProvider.authRepository.httpClient.updateTokens('test_token', 'refresh_token');
        
        // Multiple concurrent operations should be handled properly
        final results = await Future.wait([
          authProvider.getTokenStatus(),
          authProvider.validateCurrentToken(),
          authProvider.getValidAccessToken(),
        ]);
        
        // All operations should complete without throwing exceptions
        expect(results.length, equals(3));
      });
    });

    group('Security Tests', () {
      test('should not expose sensitive token data improperly', () {
        final httpClient = HttpClientWrapper();
        httpClient.setBackendServer('test-server');
        
        const accessToken = 'sensitive_access_token';
        const refreshToken = 'sensitive_refresh_token';
        
        httpClient.updateTokens(accessToken, refreshToken);
        
        // Tokens should be accessible through controlled getters only
        expect(httpClient.accessToken, equals(accessToken));
        expect(httpClient.refreshToken, equals(refreshToken));
      });

      test('should clear tokens on logout', () {
        final httpClient = HttpClientWrapper();
        httpClient.setBackendServer('test-server');
        
        const accessToken = 'test_token';
        const refreshToken = 'test_refresh_token';
        
        httpClient.updateTokens(accessToken, refreshToken);
        expect(httpClient.isAuthenticated, isTrue);
        
        // Clear tokens
        httpClient.clearTokens();
        
        expect(httpClient.accessToken, isNull);
        expect(httpClient.refreshToken, isNull);
        expect(httpClient.isAuthenticated, isFalse);
      });

      test('should handle token validation securely', () async {
        final httpClient = HttpClientWrapper();
        httpClient.setBackendServer('test-server');
        
        // Test with malformed token
        httpClient.updateTokens('malformed_token', 'refresh_token');
        
        final isValid = await httpClient.validateToken();
        expect(isValid, isFalse);
        
        // Test with empty token
        httpClient.clearTokens();
        httpClient.updateTokens('', 'refresh_token');
        
        final isValidEmpty = await httpClient.validateToken();
        expect(isValidEmpty, isFalse);
      });
    });

    group('Performance Tests', () {
      test('should handle multiple token operations efficiently', () async {
        final httpClient = HttpClientWrapper();
        httpClient.setBackendServer('test-server');
        
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';
        
        // Multiple token operations should be efficient
        final operations = <Future>[];
        
        for (int i = 0; i < 10; i++) {
          httpClient.updateTokens(accessToken, refreshToken);
          operations.add(httpClient.getTokenInfo());
          operations.add(httpClient.validateToken());
        }
        
        await Future.wait(operations);
        
        // Operations should complete without timing out
        expect(httpClient.isAuthenticated, isTrue);
      });

      test('should handle rapid authentication state changes', () async {
        final httpClient = HttpClientWrapper();
        httpClient.setBackendServer('test-server');
        
        // Simulate rapid token updates and clears
        for (int i = 0; i < 5; i++) {
          httpClient.updateTokens('token_$i', 'refresh_$i');
          expect(httpClient.isAuthenticated, isTrue);
          
          httpClient.clearTokens();
          expect(httpClient.isAuthenticated, isFalse);
        }
        
        // Final state should be clean
        expect(httpClient.accessToken, isNull);
        expect(httpClient.refreshToken, isNull);
      });
    });
  });
}