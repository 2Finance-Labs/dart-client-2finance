// lib/config/config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static late final String emqxScheme;
  static late final String emqxHost;
  static late final String emqxPort;
  static late final String emqxUsername;
  static late final String emqxPassword;
  static late final bool emqxSSL;
  static late final String emqxClientId;
  static late final String emqxCaCertPath;

  static late final String keycloakClientId;
  static late final String keycloakClientSecret;
  static late final String keycloakState;
  static late final String keycloakHostname;
  static late final String keycloakRealm;
  static late final String keycloakRedirectUrl;

  static bool _isInitialized = false;


  static Future<void> loadConfig({required String env, String path = '.env'}) async {
    print('[Config] Initializing config for ENV: $env');

    if (env == 'prod') {
      try {
        await dotenv.load(fileName: path);
      } catch (e) {
        print('[Config] Failed to load .env file at $path: $e');
        throw Exception('Missing or invalid .env file');
      }

      emqxScheme = dotenv.env['EMQX_SCHEME'] ?? 'tcp';
      emqxHost = dotenv.env['EMQX_HOST'] ?? 'localhost';
      emqxPort = dotenv.env['EMQX_PORT'] ?? '1883';
      emqxSSL = (dotenv.env['EMQX_SSL']?.toLowerCase() ?? 'false') == 'true';
      emqxUsername = dotenv.env['EMQX_USERNAME'] ?? '';
      emqxPassword = dotenv.env['EMQX_PASSWORD'] ?? '';
      emqxClientId = dotenv.env['EMQX_CLIENT_ID'] ?? 'flutter_plugin_client';
      emqxCaCertPath = dotenv.env['EMQX_CA_CERT_PATH'] ?? '';

      keycloakClientId = dotenv.env['KEYCLOAK_CLIENT_ID'] ?? '';
      keycloakClientSecret = dotenv.env['KEYCLOAK_CLIENT_SECRET'] ?? '';
      keycloakState = dotenv.env['KEYCLOAK_STATE'] ?? '';
      keycloakRealm = dotenv.env['KEYCLOAK_REALM'] ?? '';
      keycloakHostname = dotenv.env['KEYCLOAK_HOSTNAME'] ?? '';
      keycloakRedirectUrl = dotenv.env['KEYCLOAK_REDIRECT_URL'] ?? '';
      _isInitialized = true;

      return;
    }

    emqxScheme = 'tcp';
    emqxHost = 'localhost';
    emqxPort = '1883';
    emqxSSL = false;
    emqxUsername = '';
    emqxPassword = '';
    emqxClientId = 'flutter_plugin_client';
    emqxCaCertPath = '';

    keycloakClientId = '';
    keycloakClientSecret = '';
    keycloakState = '';
    keycloakRealm = '';
    keycloakHostname = '';
    keycloakRedirectUrl = '';
    _isInitialized = true;

  }

}
