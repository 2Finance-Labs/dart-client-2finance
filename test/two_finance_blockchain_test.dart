import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';
import 'package:test/test.dart';

import 'e2e_test.dart';



class FakeMqttClient implements MqttClientInterface {
  bool connected = false;

  @override
  MqttClient? get client => null;

  @override
  Future<void> connect() async {
    connected = true;
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }

  @override
  Future<void> publish(String topic, String payload) async {}

  @override
  Future<void> subscribe(String topic, {MessageHandler? handler}) async {}

  @override
  Future<void> unsubscribe(String topic) async {}
}



void main() {
  test('initialize marks SDK as initialized', () async {
    final keyManager = KeyManager();
    final mqttClient = FakeMqttClient();
    const chainID = 1;

    final sdk = TwoFinanceBlockchain(
      keyManager: keyManager,
      mqttClient: mqttClient,
      chainID: chainID,
    );

    expect(sdk.isInitialized, isFalse);

    await sdk.initialize();

    expect(sdk.isInitialized, isTrue);
  });
}