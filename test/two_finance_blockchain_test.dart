import 'package:flutter_test/flutter_test.dart';
import 'package:two_finance_blockchain/blockchain/keys/keys.dart';
import 'package:two_finance_blockchain/infra/mqtt/mqtt.dart';
import 'package:two_finance_blockchain/two_finance_blockchain.dart';
import 'package:two_finance_blockchain/two_finance_blockchain_platform_interface.dart';
import 'package:two_finance_blockchain/two_finance_blockchain_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTwoFinanceBlockchainPlatform
    with MockPlatformInterfaceMixin
    implements TwoFinanceBlockchainPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TwoFinanceBlockchainPlatform initialPlatform = TwoFinanceBlockchainPlatform.instance;

  test('$MethodChannelTwoFinanceBlockchain is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTwoFinanceBlockchain>());
  });

  test('getPlatformVersion', () async {
    final KeyManager keyManager = KeyManager(); // Provide a valid KeyManager instance
    final MqttClientWrapper mqttClient = MqttClientWrapper(host: '', port: '', clientId: ''); // Provide a valid MqttClientWrapper instance
    TwoFinanceBlockchain twoFinanceBlockchainPlugin = TwoFinanceBlockchain(keyManager: keyManager, mqttClient: mqttClient);
    MockTwoFinanceBlockchainPlatform fakePlatform = MockTwoFinanceBlockchainPlatform();
    TwoFinanceBlockchainPlatform.instance = fakePlatform;

    expect(await twoFinanceBlockchainPlugin.getPlatformVersion(), '42');
  });
}
