import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'two_finance_blockchain_platform_interface.dart';

/// An implementation of [TwoFinanceBlockchainPlatform] that uses method channels.
class MethodChannelTwoFinanceBlockchain extends TwoFinanceBlockchainPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('two_finance_blockchain');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
