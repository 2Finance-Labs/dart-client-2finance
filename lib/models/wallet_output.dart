import 'package:json_annotation/json_annotation.dart';
import 'package:two_finance_blockchain/models/wallet.dart';

part 'wallet_output.g.dart';

typedef JSONB = Map<String, dynamic>;

@JsonSerializable()
class WalletOutput {
  final Wallet? wallet;

  // Assumindo que Event é um Map<String, dynamic> para JSONB
  final JSONB? event;

  @JsonKey(name: 'log_type')
  final String? logType;

  WalletOutput({
    this.wallet,
    this.event,
    this.logType,
  });

  factory WalletOutput.fromJson(Map<String, dynamic> json) => _$WalletOutputFromJson(json);
  Map<String, dynamic> toJson() => _$WalletOutputToJson(this);

  @override
  String toString() {
    return 'WalletOutput(wallet: $wallet, event: $event, logType: $logType)';
  }
}