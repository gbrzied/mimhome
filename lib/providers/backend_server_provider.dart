import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Environment types for backend server configuration
enum BackendEnvironment {
  development1,
  development2,
  staging,
  production,
}

/// Backend server configuration model
class BackendServerConfig {
  final String url;
  final int port;
  final BackendEnvironment environment;
  final bool useHttps;
  final String apiVersion;

  const BackendServerConfig({
    required this.url,
    required this.port,
    required this.environment,
    this.useHttps = false,
    this.apiVersion = 'v1',
  });

  /// Get the full backend server address
  String get fullUrl {
    final protocol = useHttps ? 'https' : 'http';
    return '$protocol://$url:$port/$apiVersion';
  }

  /// Default configurations for each environment
  static const Map<BackendEnvironment, BackendServerConfig> defaults = {
    BackendEnvironment.development1: BackendServerConfig(
      url: '192.168.1.13',
      port: 8080,
      environment: BackendEnvironment.development1,
      useHttps: false,
      apiVersion: 'v1',
    ),
      BackendEnvironment.development2: BackendServerConfig(
      url: '10.13.215.190',
      port: 8080,
      environment: BackendEnvironment.development2,
      useHttps: false,
      apiVersion: 'v1',
    ),
    BackendEnvironment.staging: BackendServerConfig(
      url: 'staging.millime.example.com',
      port: 443,
      environment: BackendEnvironment.staging,
      useHttps: true,
      apiVersion: 'v1',
    ),
    BackendEnvironment.production: BackendServerConfig(
      url: 'api.millime.example.com',
      port: 443,
      environment: BackendEnvironment.production,
      useHttps: true,
      apiVersion: 'v1',
    ),
  };

  /// Create a copy with modified values
  BackendServerConfig copyWith({
    String? url,
    int? port,
    BackendEnvironment? environment,
    bool? useHttps,
    String? apiVersion,
  }) {
    return BackendServerConfig(
      url: url ?? this.url,
      port: port ?? this.port,
      environment: environment ?? this.environment,
      useHttps: useHttps ?? this.useHttps,
      apiVersion: apiVersion ?? this.apiVersion,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'port': port,
      'environment': environment.name,
      'useHttps': useHttps,
      'apiVersion': apiVersion,
    };
  }

  /// Create from JSON
  factory BackendServerConfig.fromJson(Map<String, dynamic> json) {
    return BackendServerConfig(
      url: json['url'] as String,
      port: json['port'] as int,
      environment: BackendEnvironment.values.firstWhere(
        (e) => e.name == json['environment'],
        orElse: () => BackendEnvironment.development1,
      ),
      useHttps: json['useHttps'] as bool? ?? false,
      apiVersion: json['apiVersion'] as String? ?? 'v1',
    );
  }
}

/// Global backend server provider for reactive configuration management
/// Manages the backend server URL and allows runtime configuration changes
class BackendServerProvider extends ChangeNotifier {
  BackendServerProvider() {
    _initialize();
  }

  static const String _kBackendServerKey = 'backend_server_config';
  static const String _kBackendUrlKey = 'backend_server_url';
  static const String _kBackendPortKey = 'backend_server_port';
  static const String _kBackendEnvKey = 'backend_environment';
  static const String _kBackendUseHttpsKey = 'backend_use_https';
  static const String _kBackendApiVersionKey = 'backend_api_version';

  BackendEnvironment _currentEnvironment = BackendEnvironment.development1;
  String _backendUrl = BackendServerConfig.defaults[BackendEnvironment.development1]!.url;
  int _backendPort = BackendServerConfig.defaults[BackendEnvironment.development1]!.port;
  bool _useHttps = BackendServerConfig.defaults[BackendEnvironment.development1]!.useHttps;
  String _apiVersion = BackendServerConfig.defaults[BackendEnvironment.development1]!.apiVersion;

  /// Get the current backend URL
  String get backendUrl => _backendUrl;

  /// Get the current backend port
  int get backendPort => _backendPort;

  /// Get the current environment
  BackendEnvironment get currentEnvironment => _currentEnvironment;

  /// Get whether HTTPS is enabled
  bool get useHttps => _useHttps;

  /// Get the API version
  String get apiVersion => _apiVersion;

  /// Get the full backend server URL
  String get fullBackendUrl {
    final protocol = _useHttps ? 'https' : 'http';
    return '$protocol://$_backendUrl:$_backendPort/$_apiVersion';
  }

  /// Get the current configuration
  BackendServerConfig get currentConfig {
    return BackendServerConfig(
      url: _backendUrl,
      port: _backendPort,
      environment: _currentEnvironment,
      useHttps: _useHttps,
      apiVersion: _apiVersion,
    );
  }

  /// Initialize the provider by loading saved configuration
  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try new config format first
      final configJson = prefs.getString(_kBackendServerKey);
      if (configJson != null) {
        // Old format - backward compatibility
        final url = prefs.getString(_kBackendUrlKey) ??
            BackendServerConfig.defaults[BackendEnvironment.development1]!.url;
        final port = prefs.getInt(_kBackendPortKey) ??
            BackendServerConfig.defaults[BackendEnvironment.development1]!.port;
        final envName = prefs.getString(_kBackendEnvKey) ?? 'development1';
        final https = prefs.getBool(_kBackendUseHttpsKey) ?? false;
        final apiVersion = prefs.getString(_kBackendApiVersionKey) ?? 'v1';

        _currentEnvironment = BackendEnvironment.values.firstWhere(
          (e) => e.name == envName,
          orElse: () => BackendEnvironment.development1,
        );
        _backendUrl = url;
        _backendPort = port;
        _useHttps = https;
        _apiVersion = apiVersion;
      } else {
        // No saved config, use default
        await _setConfig(BackendServerConfig.defaults[BackendEnvironment.development1]!);
      }
    } catch (e) {
      debugPrint('Error loading backend server config: $e');
      _loadDefaults();
    }
  }

  /// Load default configuration
  void _loadDefaults() {
    final defaults = BackendServerConfig.defaults[_currentEnvironment]!;
    _backendUrl = defaults.url;
    _backendPort = defaults.port;
    _useHttps = defaults.useHttps;
    _apiVersion = defaults.apiVersion;
    notifyListeners();
  }

  /// Set the backend server configuration
  Future<void> setBackendServer(String url, {int? port}) async {
    _backendUrl = url;
    if (port != null) {
      _backendPort = port;
    }
    await _saveConfig();
    notifyListeners();
    debugPrint('Backend server URL changed to: $fullBackendUrl');
  }

  /// Set the environment and update default configuration
  Future<void> setEnvironment(BackendEnvironment environment) async {
    _currentEnvironment = environment;
    final defaults = BackendServerConfig.defaults[environment]!;
    _backendUrl = defaults.url;
    _backendPort = defaults.port;
    _useHttps = defaults.useHttps;
    _apiVersion = defaults.apiVersion;
    await _saveConfig();
    notifyListeners();
    debugPrint('Backend environment changed to: ${environment.name}');
  }

  /// Set the full configuration at once
  Future<void> setConfig(BackendServerConfig config) async {
    await _setConfig(config);
    notifyListeners();
    debugPrint('Backend server config changed to: $fullBackendUrl');
  }

  /// Internal method to set configuration
  Future<void> _setConfig(BackendServerConfig config) async {
    _backendUrl = config.url;
    _backendPort = config.port;
    _currentEnvironment = config.environment;
    _useHttps = config.useHttps;
    _apiVersion = config.apiVersion;
    await _saveConfig();
  }

  /// Save current configuration to shared preferences
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBackendUrlKey, _backendUrl);
      await prefs.setInt(_kBackendPortKey, _backendPort);
      await prefs.setString(_kBackendEnvKey, _currentEnvironment.name);
      await prefs.setBool(_kBackendUseHttpsKey, _useHttps);
      await prefs.setString(_kBackendApiVersionKey, _apiVersion);
    } catch (e) {
      debugPrint('Error saving backend server config: $e');
    }
  }

  /// Get environment display name
  String getEnvironmentDisplayName() {
    switch (_currentEnvironment) {
      case BackendEnvironment.development1:
        return 'Développement1';
      case BackendEnvironment.development2:
        return 'Développement2';
      case BackendEnvironment.staging:
        return 'Staging';
      case BackendEnvironment.production:
        return 'Production';
    }
  }

  /// Get all environment options
  static List<String> getEnvironmentOptions() {
    return ['Développement', 'Staging', 'Production'];
  }

  /// Reset to default configuration
  Future<void> resetToDefault() async {
    await setEnvironment(BackendEnvironment.development1);
  }

  /// Get the compile-time default backend URL (from build_info.dart)
  static String get compileTimeDefaultBackendUrl {
    return  '192.168.1.13'; //'10.13.215.190';
  }

  @override
  void dispose() {
    super.dispose();
  }
}
