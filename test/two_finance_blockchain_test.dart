import 'package:flutter_test/flutter_test.dart';
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
    TwoFinanceBlockchain twoFinanceBlockchainPlugin = TwoFinanceBlockchain();
    MockTwoFinanceBlockchainPlatform fakePlatform = MockTwoFinanceBlockchainPlatform();
    TwoFinanceBlockchainPlatform.instance = fakePlatform;

    expect(await twoFinanceBlockchainPlugin.getPlatformVersion(), '42');
  });
}
