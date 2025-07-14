
// lib/main_blockchain.dart
import 'package:two_finance_blockchain/config/app_config.dart' show AppConfig;
import 'package:two_finance_blockchain/mqtt/blockchain_mqtt_client.dart' show BlockchainMqttClient;
import 'dart:async';

class TwoFinanceBlockchain {
  // Construtor privado para impedir a instanciação direta.
  // A ideia é usar apenas métodos estáticos para gerenciar o estado global.
  TwoFinanceBlockchain._();

  /// Inicializa as configurações do pacote e executa as operações MQTT.
  ///
  /// Este método configura os parâmetros de conexão do EMQX e, em seguida,
  /// conecta-se ao broker e executa 15 operações simuladas de forma concorrente.
  ///
  /// Parâmetros:
  /// - [scheme]: O esquema de conexão para o broker EMQX (ex: 'tcp', 'ws', 'wss').
  /// - [host]: O endereço do host do broker EMQX (ex: 'broker.emqx.io').
  /// - [port]: A porta de conexão do broker EMQX (ex: '1883', '8083', '8084').
  /// - [clientId]: Um ID único para o cliente MQTT.
  ///
  /// Throws [StateError] se as configurações já tiverem sido inicializadas.
  /// Throws [Exception] se a conexão MQTT falhar ou ocorrerem outros erros.
  static Future<void> initializeAndRunOperations({
    required String scheme,
    required String host,
    required String port,
    required String clientId,
  }) async {
    // 1. Inicializar a configuração do pacote.
    // Isso define as configurações internamente e evita re-inicialização.
    try {
      AppConfig.initialize(
        scheme: scheme,
        host: host,
        port: port,
        clientId: clientId,
      );
    } on StateError catch (e) {
      print('AppConfig already initialized: $e');
      // Se já estiver inicializado, apenas continue usando a configuração existente.
      // Você pode adaptar este comportamento conforme sua necessidade.
      if (!AppConfig.isInitialized) { // Apenas relance se a inicialização realmente falhou
        rethrow;
      }
    } catch (e) {
      print('Error initializing AppConfig: $e');
      rethrow;
    }

    // 2. Construir o host EMQX usando as configurações já definidas.
    final emqxHost = '${AppConfig.emqxScheme}://${AppConfig.emqxHost}:${AppConfig.emqxPort}';
    print('Constructed EMQX Host: $emqxHost');

    // 3. Instanciar o cliente MQTT.
    final client = BlockchainMqttClient(
      host: emqxHost,
      clientId: AppConfig.emqxClientId,
      useSSL: false, // Pode ser configurado dinamicamente com base no esquema (e.g., 'wss' -> true)
    );

    // Conecte-se ao broker MQTT
    print('Attempting to connect to MQTT broker...');
    await client.connect();

    // 4. Lógica de concorrência: Executar 15 operações simuladas.
    // Isso emula o loop com goroutines e WaitGroup do código Go.
    List<Future<void>> operations = [];
    for (int i = 0; i < 15; i++) {
      operations.add(_simulateExecute(client, i)); // Adiciona um Future para cada operação
    }

    print('Waiting for all 15 operations to complete...');
    await Future.wait(operations); // Espera que todos os Futures sejam concluídos
    print('All 15 simulated operations completed successfully!');

    // Desconectar o cliente MQTT após todas as operações
    client.disconnect();
  }

  /// Função auxiliar privada para simular uma operação 'execute'.
  ///
  /// Esta função representa a lógica que seria executada por cada goroutine no Go.
  /// No futuro, esta será a lógica real de interação com o blockchain/MQTT.
  static Future<void> _simulateExecute(BlockchainMqttClient client, int index) async {
    print('[Operation $index] Starting...');
    // Simule alguma operação assíncrona, como publicar/assinar no MQTT
    await Future.delayed(const Duration(milliseconds: 500)); // Simula um tempo de processamento
    print('[Operation $index] Finished.');
    // No futuro, aqui você chamaria a lógica real da sua função execute,
    // usando 'client' para interagir com o MQTT.
  }
}