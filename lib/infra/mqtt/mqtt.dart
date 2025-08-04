// lib/mqtt/mqtt_client_wrapper.dart
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:two_finance_blockchain/infra/utils/tls_utils.dart';

typedef MessageHandler = void Function(MqttClient client, MqttReceivedMessage<MqttMessage> message);

abstract class MqttClientInterface {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> publish(String topic, String payload);
  Future<void> subscribe(String topic, {MessageHandler? handler});
  Future<void> unsubscribe(String topic);
  MqttClient? get client;
}

class MqttClientWrapper implements MqttClientInterface {
  final String host;
  final String port;
  final String clientId;
  final bool useSSL;
  final String? username;
  final String? password;
  final String? caCertPath;
  MqttServerClient? _client;

  MqttClientWrapper({
    required this.host,
    required this.port,
    required this.clientId,
    this.useSSL = false,
    this.username,
    this.password,
    this.caCertPath,
  });

  @override
  MqttClient? get client => _client;

  @override
  Future<void> connect() async {
    _client = MqttServerClient(host, clientId);
    _client!
      ..logging(on: false)
      ..keepAlivePeriod = 60
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed
      ..pongCallback = _onPong
      ..autoReconnect = true
      ..resubscribeOnAutoReconnect = true;
      
      final parsedPort = int.tryParse(port);
      if (parsedPort == null) {
        print('⚠️ Warning: Invalid MQTT port "$port", using default ${useSSL ? 8883 : 1883}');
      }
      _client!.port = parsedPort ?? (useSSL ? 8883 : 1883);

      if (useSSL) {
        _client!.secure = true;

        if (caCertPath != null && caCertPath!.isNotEmpty) {
          print('caCertPath: $caCertPath');
          final realPath = await extractCaCertAsset(caCertPath!);
          print(' Extracted CA Cert Path: $realPath');
          _client!.securityContext = createSecurityContext(realPath);
        } else {
          _client!.securityContext = SecurityContext.defaultContext;
          print('⚠️ TLS: No CA cert path provided, using default trust store');
        }
      }

    final connMess = MqttConnectMessage()
        .authenticateAs(username ?? '', password ?? '')
        .withClientIdentifier(clientId)
        .withWillTopic('will/topic')
        .withWillMessage('client disconnected unexpectedly')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      print('Connection error: $e');
      _client!.disconnect();
      rethrow;
    }

    if (_client!.connectionStatus?.state != MqttConnectionState.connected) {
      throw Exception('Failed to connect to MQTT broker');
    }

    print('Connected to MQTT broker at $host');
  }

  @override
  Future<void> disconnect() async {
    _client?.disconnect();
    print('Disconnected from MQTT broker');
  }

  @override
  Future<void> publish(String topic, String payload) async {
    print('Publishing to $topic: $payload');
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  Future<void> subscribe(String topic, {MessageHandler? handler}) async {
    print('Subscribing to $topic');
    _client?.subscribe(topic, MqttQos.atLeastOnce);

    if (handler != null) {
      _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        for (var message in c) {
          handler(_client!, message);
        }
      });
    }
  }

  @override
  Future<void> unsubscribe(String topic) async {
    _client?.unsubscribe(topic);
  }

  void _onConnected() => print('MQTT connected');
  void _onDisconnected() => print('MQTT disconnected');
  void _onSubscribed(String topic) => print('Subscribed to $topic');
  void _onPong() => print('Pong received from broker');
}
