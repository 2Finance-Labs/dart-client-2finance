// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
  amount: json['amount'] as String,
  fromAddress: json['from'] as String,
  toAddress: json['to'] as String,
);

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
  'amount': instance.amount,
  'from': instance.fromAddress,
  'to': instance.toAddress,
};

TransferOutput _$TransferOutputFromJson(Map<String, dynamic> json) =>
    TransferOutput(
      transfer: json['transfer'] == null
          ? null
          : Transfer.fromJson(json['transfer'] as Map<String, dynamic>),
      walletSender: json['wallet_sender'] == null
          ? null
          : Wallet.fromJson(json['wallet_sender'] as Map<String, dynamic>),
      walletReceiver: json['wallet_receiver'] == null
          ? null
          : Wallet.fromJson(json['wallet_receiver'] as Map<String, dynamic>),
      eventTransfer: json['event_transfer'] as Map<String, dynamic>?,
      eventSender: json['event_sender'] as Map<String, dynamic>?,
      eventReceiver: json['event_receiver'] as Map<String, dynamic>?,
      logTypeTransfer: json['log_type_transfer'] as String?,
      logTypeSender: json['log_type_sender'] as String?,
      logTypeReceiver: json['log_type_receiver'] as String?,
    );

Map<String, dynamic> _$TransferOutputToJson(TransferOutput instance) =>
    <String, dynamic>{
      'transfer': instance.transfer,
      'wallet_sender': instance.walletSender,
      'wallet_receiver': instance.walletReceiver,
      'event_transfer': instance.eventTransfer,
      'event_sender': instance.eventSender,
      'event_receiver': instance.eventReceiver,
      'log_type_transfer': instance.logTypeTransfer,
      'log_type_sender': instance.logTypeSender,
      'log_type_receiver': instance.logTypeReceiver,
    };
