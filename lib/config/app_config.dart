// lib/config/app_config.dart

class AppConfig {
  // Tornamos os campos privados e estáticos para serem acessados via getters
  static String? _emqxScheme;
  static String? _emqxHost;
  static String? _emqxPort;
  static String? _emqxClientId;

  // Getters públicos para acessar as configurações.
  // Usamos '!' (null assertion operator) aqui assumindo que a configuração será feita antes do uso.
  static String get emqxScheme => _emqxScheme!;
  static String get emqxHost => _emqxHost!;
  static String get emqxPort => _emqxPort!;
  static String get emqxClientId => _emqxClientId!;

  // Método para inicializar a configuração do pacote.
  // Ele deve ser chamado uma única vez no início do uso do pacote.
  static void initialize({
    required String scheme,
    required String host,
    required String port,
    required String clientId,
  }) {
    if (_emqxScheme != null || _emqxHost != null || _emqxPort != null || _emqxClientId != null) {
      // Opcional: Lançar um erro se tentar configurar mais de uma vez
      throw StateError('AppConfig already initialized. Call initialize() only once.');
    }
    _emqxScheme = scheme;
    _emqxHost = host;
    _emqxPort = port;
    _emqxClientId = clientId;

    print('AppConfig initialized: EMQX Host: $emqxHost:$emqxPort, Client ID: $emqxClientId');
  }

  // Opcional: Um método para verificar se a configuração foi inicializada
  static bool get isInitialized => _emqxScheme != null;
}