import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'two_finance_blockchain_method_channel.dart';

abstract class TwoFinanceBlockchainPlatform {
  static TwoFinanceBlockchainPlatform _instance =
      MethodChannelTwoFinanceBlockchain();

  static TwoFinanceBlockchainPlatform get instance => _instance;

  static set instance(TwoFinanceBlockchainPlatform instance) {
    _instance = instance;
  }

  Future<String?> getPlatformVersion();
}

