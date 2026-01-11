// lib/core/build_info.dart
// This file contains build-time configuration values for the Millime app
// The backendServer variable is now dynamically configured via BackendServerProvider
// for environment-specific URLs and runtime configuration changes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/backend_server_provider.dart';

// Compile-time constants (these are set at build time and cannot be changed at runtime)
const String compilationDate = '2025-11-03';

const String version = '1.0.10';

// Environment-specific backend server URLs (compile-time defaults)
// These values are used as fallback when no runtime configuration is available
const String _kDefaultDevelopmentUrl = '192.168.1.13'; ///'10.13.215.190';
const String _kDefaultStagingUrl = 'staging.millime.example.com';
const String _kDefaultProductionUrl = 'api.millime.example.com';

// Default port for backend server
const int _kDefaultBackendPort = 8080;

/// Get the backend server URL
/// This function resolves the backend URL at runtime from the BackendServerProvider
/// Falls back to compile-time default if provider is not available
String getBackendServerUrl(BuildContext context) {
  try {
    final provider = Provider.of<BackendServerProvider>(context, listen: false);
    return provider.backendUrl;
  } catch (e) {
    // Provider not available, return compile-time default
    return _kDefaultDevelopmentUrl;
  }
}

/// Get the full backend server URL with protocol and port
String getFullBackendUrl(BuildContext context) {
  try {
    final provider = Provider.of<BackendServerProvider>(context, listen: false);
    return provider.fullBackendUrl;
  } catch (e) {
    // Provider not available, return compile-time default
    return 'http://$_kDefaultDevelopmentUrl:$_kDefaultBackendPort/v1';
  }
}

/// Get the current backend server URL (synchronous version)
/// This uses the compile-time default if the provider is not initialized
/// Use this for non-UI contexts where provider access is not available
String getBackendServerUrlSync() {
  // Return compile-time default for synchronous access
  // The actual runtime value should be accessed via BackendServerProvider
  return _kDefaultDevelopmentUrl;
}

/// Backend server configuration helper class
class BackendServerConfig {
  /// Development environment configuration
  static const String developmentUrl = _kDefaultDevelopmentUrl;
  static const int developmentPort = 8080;
  static const bool developmentUseHttps = false;

  /// Staging environment configuration
  static const String stagingUrl = _kDefaultStagingUrl;
  static const int stagingPort = 443;
  static const bool stagingUseHttps = true;

  /// Production environment configuration
  static const String productionUrl = _kDefaultProductionUrl;
  static const int productionPort = 443;
  static const bool productionUseHttps = true;

  /// Get the default URL for a given environment
  static String getDefaultUrlForEnvironment(BackendEnvironment environment) {
    switch (environment) {
      case BackendEnvironment.development1:
        return developmentUrl;
      case BackendEnvironment.development2:
        return developmentUrl;
      case BackendEnvironment.staging:
        return stagingUrl;
      case BackendEnvironment.production:
        return productionUrl;
    }
  }
}

/// Global backend server URL variable for backward compatibility
/// This is initialized with the compile-time default value
/// To use the runtime-configured value, access via BackendServerProvider
String backendServer = _kDefaultDevelopmentUrl;

/// Update the global backendServer variable (for backward compatibility)
/// Prefer using BackendServerProvider.setBackendServer() for new code
void updateBackendServer(String newUrl) {
  backendServer = newUrl;
  debugPrint('Backend server URL updated to: $newUrl');
}
