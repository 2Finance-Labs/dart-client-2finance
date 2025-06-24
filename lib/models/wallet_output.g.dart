// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletOutput _$WalletOutputFromJson(Map<String, dynamic> json) => WalletOutput(
  wallet: json['wallet'] == null
      ? null
      : Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
  event: json['event'] as Map<String, dynamic>?,
  logType: json['log_type'] as String?,
);

Map<String, dynamic> _$WalletOutputToJson(WalletOutput instance) =>
    <String, dynamic>{
      'wallet': instance.wallet,
      'event': instance.event,
      'log_type': instance.logType,
    };
