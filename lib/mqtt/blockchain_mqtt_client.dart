// lib/mqtt/blockchain_mqtt_client.dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class BlockchainMqttClient {
  final String host;
  final String clientId;
  final bool useSSL;
  MqttServerClient? _client;

  BlockchainMqttClient({
    required this.host,
    required this.clientId,
    this.useSSL = false,
  });

  Future<void> connect() async {
    _client = MqttServerClient(host, clientId);

    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;
    _client!.pongCallback = pong;

    if (useSSL) {
      _client!.secure = true;
      // Adicione configurações de certificados aqui se necessário
    }

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      print('MQTT client exception - $e');
      _client!.disconnect();
      rethrow;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected to $host');
    } else {
      print('MQTT client connection failed - status: ${_client!.connectionStatus!.state}');
      throw Exception('MQTT connection failed');
    }
  }

  void disconnect() {
    _client?.disconnect();
    print('MQTT client disconnected');
  }

  // Callbacks de status do MQTT
  void onDisconnected() {
    print('MQTT client disconnected');

    if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
      print('MQTT client disconnected normally (no specific error code)');
    } else {
      print('MQTT client disconnected due to error: ${_client!.connectionStatus!.returnCode}');
    }
  }

  void onConnected() {
    print('MQTT client connected');
  }

  void onSubscribed(String topic) {
    print('MQTT client subscribed to $topic');
  }

  void pong() {
    print('MQTT client pong received');
  }
}