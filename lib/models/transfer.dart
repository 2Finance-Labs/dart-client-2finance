import 'package:json_annotation/json_annotation.dart';
import 'package:two_finance_blockchain/models/wallet.dart';

// **ADICIONE ESTA LINHA:**
part 'transfer.g.dart';

// Definimos o tipo JSONB como um Map<String, dynamic> para flexibilidade
typedef JSONB = Map<String, dynamic>;

@JsonSerializable()
class Transfer {
  @JsonKey(name: 'amount')
  final String amount;

  @JsonKey(name: 'from')
  final String fromAddress;

  @JsonKey(name: 'to')
  final String toAddress;

  Transfer({
    required this.amount,
    required this.fromAddress,
    required this.toAddress,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) => _$TransferFromJson(json);
  Map<String, dynamic> toJson() => _$TransferToJson(this);

  @override
  String toString() {
    return 'Transfer(amount: $amount, fromAddress: $fromAddress, toAddress: $toAddress)';
  }
}

@JsonSerializable()
class TransferOutput {
  @JsonKey(name: 'transfer')
  final Transfer? transfer;

  @JsonKey(name: 'wallet_sender')
  final Wallet? walletSender;

  @JsonKey(name: 'wallet_receiver')
  final Wallet? walletReceiver;

  @JsonKey(name: 'event_transfer')
  final JSONB? eventTransfer;

  @JsonKey(name: 'event_sender')
  final JSONB? eventSender;

  @JsonKey(name: 'event_receiver')
  final JSONB? eventReceiver;

  @JsonKey(name: 'log_type_transfer')
  final String? logTypeTransfer;

  @JsonKey(name: 'log_type_sender')
  final String? logTypeSender;

  @JsonKey(name: 'log_type_receiver')
  final String? logTypeReceiver;

  TransferOutput({
    this.transfer,
    this.walletSender,
    this.walletReceiver,
    this.eventTransfer,
    this.eventSender,
    this.eventReceiver,
    this.logTypeTransfer,
    this.logTypeSender,
    this.logTypeReceiver,
  });

  factory TransferOutput.fromJson(Map<String, dynamic> json) => _$TransferOutputFromJson(json);
  Map<String, dynamic> toJson() => _$TransferOutputToJson(this);

  @override
  String toString() {
    return 'TransferOutput(\n'
        '  transfer: $transfer,\n'
        '  walletSender: $walletSender,\n'
        '  walletReceiver: $walletReceiver,\n'
        '  eventTransfer: $eventTransfer,\n'
        '  eventSender: $eventSender,\n'
        '  eventReceiver: $eventReceiver,\n'
        '  logTypeTransfer: $logTypeTransfer,\n'
        '  logTypeSender: $logTypeSender,\n'
        '  logTypeReceiver: $logTypeReceiver,\n'
        ')';
  }
}