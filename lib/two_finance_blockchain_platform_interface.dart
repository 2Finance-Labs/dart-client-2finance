import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'two_finance_blockchain_method_channel.dart';

abstract class TwoFinanceBlockchainPlatform extends PlatformInterface {
  /// Constructs a TwoFinanceBlockchainPlatform.
  TwoFinanceBlockchainPlatform() : super(token: _token);

  static final Object _token = Object();

  static TwoFinanceBlockchainPlatform _instance = MethodChannelTwoFinanceBlockchain();

  /// The default instance of [TwoFinanceBlockchainPlatform] to use.
  ///
  /// Defaults to [MethodChannelTwoFinanceBlockchain].
  static TwoFinanceBlockchainPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TwoFinanceBlockchainPlatform] when
  /// they register themselves.
  static set instance(TwoFinanceBlockchainPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
