# Token Refresh Implementation Documentation

## Overview

This document describes the comprehensive token refresh logic implemented for the Millime Flutter banking application. The implementation provides robust token management with automatic refresh, error handling, and security considerations.

## Architecture

### Components

1. **HttpClientWrapper** (`lib/core/utils/http_client_wrapper.dart`)
   - Handles HTTP requests with automatic token refresh
   - Manages token storage and retrieval
   - Implements concurrent refresh token handling
   - Provides token validation and expiry checking

2. **AuthRepository** (`lib/core/repository/auth_repository.dart`)
   - Repository pattern for authentication operations
   - Provides token refresh methods
   - Manages token validation and status checking
   - Handles token storage operations

3. **AuthProvider** (`lib/core/provider/auth_provider.dart`)
   - Provider pattern for authentication state management
   - Implements automatic token refresh scheduling
   - Manages user session lifecycle
   - Handles token refresh failures and user feedback

## Features Implemented

### 1. Token Refresh Logic

#### Automatic Token Refresh
- **Preemptive Refresh**: Tokens are refreshed 5 minutes before expiry
- **Request Interception**: 401 responses automatically trigger token refresh
- **Request Retry**: Failed requests are retried with new tokens after refresh

#### Token Validation
- **JWT Structure Validation**: Basic token format validation
- **Expiry Checking**: Proper handling of token expiration times
- **Buffer Time**: Refresh tokens before actual expiry to prevent interruptions

### 2. Concurrent Request Handling

#### Refresh Queue Management
- **Single Refresh**: Prevents multiple simultaneous refresh attempts
- **Request Queuing**: Queues pending requests during refresh
- **Completer Pattern**: Uses Dart Completer for proper async handling

```dart
// Example of concurrent refresh handling
if (_isRefreshing) {
  final completer = Completer<bool>();
  _refreshCompleters.add(completer);
  return completer.future;
}
```

### 3. Token Storage and Management

#### Secure Storage
- **SharedPreferences**: Tokens stored in device secure storage
- **Token Rotation**: Refresh tokens are rotated on successful refresh
- **Automatic Cleanup**: Invalid tokens are automatically cleared

#### Token Information
- **Expiry Tracking**: Tracks token expiry times
- **Status Monitoring**: Provides token status information
- **Debug Support**: Methods for debugging token state

### 4. User Session Management

#### Session Lifecycle
- **Automatic Login**: Sessions persist across app restarts
- **Session Validation**: Periodic validation of session validity
- **Automatic Logout**: Sessions expire gracefully with user notification

#### Error Handling
- **Network Errors**: Proper handling of network connectivity issues
- **Token Failures**: Graceful handling of invalid/expired tokens
- **User Feedback**: French localization for all error messages

### 5. Integration Points

#### App Lifecycle Integration
- **App Resume**: Token check on app resume
- **Periodic Refresh**: Automatic token refresh every 5 minutes
- **Memory Management**: Proper cleanup of timers and resources

#### Authentication Flow Integration
- **Login Success**: Token refresh timer starts after successful login
- **Logout**: Complete token cleanup and timer cancellation
- **Error Recovery**: Automatic logout on critical token failures

## API Reference

### HttpClientWrapper Methods

#### Core Methods
```dart
// Initialize with backend server
void setBackendServer(String backendServer, {String realm = 'millime'});

// Update tokens after login
void updateTokens(String accessToken, String refreshToken, {int expiresIn = 3600});

// Clear all tokens
void clearTokens();

// Get current access token
String? get accessToken;

// Check authentication status
bool get isAuthenticated;
```

#### HTTP Request Methods
```dart
// GET request with auto-refresh
Future<http.Response> getUrl(String url, {Map<String, String>? headers, bool requiresAuth = true});

// POST request with auto-refresh
Future<http.Response> postUrl(String url, {Map<String, String>? headers, Map<String, dynamic>? body, bool requiresAuth = true});

// PUT request with auto-refresh
Future<http.Response> putUrl(String url, {Map<String, String>? headers, Map<String, dynamic>? body, bool requiresAuth = true});

// DELETE request with auto-refresh
Future<http.Response> deleteUrl(String url, {Map<String, String>? headers, bool requiresAuth = true});
```

#### Token Management
```dart
// Get valid access token (auto-refresh if needed)
Future<String?> get validAccessToken;

// Manually refresh tokens
Future<bool> refreshTokens();

// Validate current token
Future<bool> validateToken();

// Get token information
Future<Map<String, dynamic>?> getTokenInfo();
```

### AuthRepository Methods

#### Token Operations
```dart
// Check if token is valid
Future<bool> isTokenValid();

// Check if token should be refreshed
Future<bool> shouldRefreshToken();

// Get token expiry information
Future<Map<String, dynamic>?> getTokenInfo();

// Manually refresh access token
Future<bool> refreshAccessToken();

// Get token status
Future<Map<String, dynamic>> getTokenStatus();

// Get valid access token
Future<String?> getValidAccessToken();

// Check session validity
Future<bool> isSessionValid();

// Handle token refresh failure
void handleTokenRefreshFailure();

// Preemptively refresh token
Future<bool> preemptiveTokenRefresh();

// Clear all tokens
void clearAllTokens();
```

### AuthProvider Methods

#### Token Management
```dart
// Manually refresh token
Future<bool> refreshToken();

// Check token status
Future<Map<String, dynamic>> getTokenStatus();

// Check session validity
Future<bool> checkSessionValidity();

// Handle app resume
Future<void> onAppResume();

// Handle token refresh failure
void handleTokenRefreshFailure();

// Get token information for debugging
Future<Map<String, dynamic>?> getTokenInfo();

// Validate current token
Future<bool> validateCurrentToken();

// Get valid access token
Future<String?> getValidAccessToken();
```

## Error Handling

### Error Types

1. **Network Errors**
   - Connection timeouts
   - Server unavailability
   - DNS resolution failures

2. **Authentication Errors**
   - Invalid credentials
   - Account locked/disabled
   - Required email verification

3. **Token Errors**
   - Expired access token
   - Invalid refresh token
   - Malformed JWT tokens

4. **Session Errors**
   - Session timeout
   - Concurrent session limits
   - Device registration issues

### Error Messages (French Localization)

```dart
// Authentication errors
"Numéro de téléphone ou mot de passe incorrect"
"Veuillez vérifier votre adresse email"
"Erreur du serveur"
"Erreur de connexion"

// Token errors
"Session expirée, veuillez vous reconnecter"
"Erreur de rafraîchissement de session"

// Network errors
"Erreur de connexion"
"Erreur de connexion lors de la mise à jour"
```

## Security Considerations

### Token Storage
- **Secure Storage**: Tokens stored in SharedPreferences (consider Flutter Secure Storage for production)
- **Minimal Exposure**: Tokens only exposed through controlled getters
- **Automatic Cleanup**: Tokens cleared on logout or refresh failure

### Token Validation
- **JWT Structure**: Basic validation of JWT format
- **Expiry Validation**: Proper handling of token expiration
- **Buffer Time**: Refresh tokens before expiry to prevent interruptions

### Request Security
- **HTTPS Only**: All requests use HTTPS
- **Authorization Headers**: Proper Bearer token authentication
- **Request Interception**: Automatic handling of 401 responses

### Session Management
- **Session Timeout**: Proper handling of session expiration
- **Concurrent Requests**: Prevention of multiple simultaneous refresh attempts
- **Memory Management**: Proper cleanup of resources

## Usage Examples

### Basic Usage

```dart
// Initialize authentication
final authProvider = AuthProvider();
authProvider.initialize('192.168.1.13');

// Login with password
final success = await authProvider.loginWithPassword(
  context, 
  '+21612345678', 
  'password123'
);

// Check authentication status
if (authProvider.isAuthenticated) {
  // User is logged in
}

// Manually refresh token
final refreshSuccess = await authProvider.refreshToken();

// Logout
authProvider.logout();
```

### HTTP Client Usage

```dart
// Initialize HTTP client
final httpClient = HttpClientWrapper();
httpClient.setBackendServer('192.168.1.13');

// Make authenticated requests
final response = await httpClient.getUrl('/api/user/profile');
final userData = jsonDecode(response.body);

// Make POST request with auto-refresh
final response = await httpClient.postUrl(
  '/api/transaction',
  body: {
    'amount': 100.0,
    'description': 'Payment',
  },
);
```

### Token Information

```dart
// Get token status
final tokenStatus = await authProvider.getTokenStatus();
print('Token expires at: ${tokenStatus['expiresAt']}');
print('Time remaining: ${tokenStatus['timeRemaining']} seconds');

// Check if session is valid
final isValid = await authProvider.checkSessionValidity();
if (!isValid) {
  // Session expired, handle accordingly
}
```

## Testing

### Unit Tests

Token refresh functionality includes comprehensive unit tests covering:

- Token validation logic
- Refresh token handling
- Concurrent request management
- Error scenarios
- Token storage and retrieval

### Integration Tests

- End-to-end authentication flows
- Token refresh during active sessions
- Network error handling
- App lifecycle integration

## Performance Considerations

### Memory Usage
- **Caching**: Token values cached for synchronous access
- **Cleanup**: Automatic cleanup of expired tokens
- **Timer Management**: Proper disposal of refresh timers

### Network Efficiency
- **Request Batching**: Multiple requests can share refresh operations
- **Retry Logic**: Intelligent retry with exponential backoff
- **Buffer Management**: Optimal refresh timing to minimize network calls

### Battery Impact
- **Periodic Checks**: Token checks occur every 5 minutes when active
- **Smart Refresh**: Only refresh when necessary
- **Background Handling**: Proper handling of app backgrounding

## Monitoring and Debugging

### Logging
- Comprehensive logging for token operations
- Error tracking for token refresh failures
- Performance monitoring for refresh operations

### Debug Tools
- Token information retrieval for debugging
- Session status checking
- Manual refresh capabilities

## Future Enhancements

### Potential Improvements

1. **Enhanced Security**
   - Integration with Flutter Secure Storage
   - Certificate pinning for API calls
   - Biometric authentication integration

2. **Advanced Features**
   - Refresh token rotation
   - Multi-device session management
   - Progressive token refresh

3. **Performance Optimizations**
   - Token pre-refresh strategies
   - Background sync optimizations
   - Caching improvements

4. **User Experience**
   - Silent authentication
   - Progressive loading states
   - Enhanced error recovery

## Conclusion

The implemented token refresh system provides a robust, secure, and user-friendly solution for managing authentication tokens in the Millime Flutter banking application. The architecture follows best practices for token management while providing comprehensive error handling and security considerations.

The system is designed to be maintainable, testable, and scalable, with clear separation of concerns between different components and comprehensive documentation for future development.