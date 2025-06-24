
import 'two_finance_blockchain_platform_interface.dart';

class TwoFinanceBlockchain {
  Future<String?> getPlatformVersion() {
    return TwoFinanceBlockchainPlatform.instance.getPlatformVersion();
  }
}
