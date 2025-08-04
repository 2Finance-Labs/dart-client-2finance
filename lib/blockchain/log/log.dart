import 'dart:convert';

/// Interface-like abstract class
abstract class ILog {
  String getLogType();
  int getLogIndex();
  String getTransactionHash();
  Map<String, dynamic> getEvent();
  String getContractVersion();
  String getContractAddress();
  void validateLog();
}

/// Concrete implementation
class Log implements ILog {
  final String logType;
  final int logIndex;
  final String transactionHash;
  final Map<String, dynamic> event;
  final String contractVersion;
  final String contractAddress;
  final DateTime createdAt;

  Log({
    required this.logType,
    required this.logIndex,
    required this.transactionHash,
    required this.event,
    required this.contractVersion,
    required this.contractAddress,
    required this.createdAt,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      logType: json['log_type'],
      logIndex: json['log_index'],
      transactionHash: json['transaction_hash'],
      event: json['event'] ?? <String, dynamic>{},
      contractVersion: json['contract_version'],
      contractAddress: json['contract_address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_type': logType,
      'log_index': logIndex,
      'transaction_hash': transactionHash,
      'event': event,
      'contract_version': contractVersion,
      'contract_address': contractAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String getLogType() => logType;

  @override
  int getLogIndex() => logIndex;

  @override
  String getTransactionHash() => transactionHash;

  @override
  Map<String, dynamic> getEvent() => event;

  @override
  String getContractVersion() => contractVersion;

  @override
  String getContractAddress() => contractAddress;

  @override
  void validateLog() {
    if (logType.isEmpty) {
      throw Exception('log_type cannot be empty');
    }
    if (logIndex == 0) {
      throw Exception('log_index cannot be zero');
    }
    if (transactionHash.length != 64) {
      throw Exception('transaction_hash must be 64 characters');
    }
    if (event.isEmpty) {
      throw Exception('event (state_data) cannot be empty');
    }
    if (contractAddress.isEmpty) {
      throw Exception('contract_address cannot be empty');
    }
    if (contractVersion.isEmpty) {
      throw Exception('contract_version cannot be empty');
    }
  }
}

/// Factory function equivalent to `NewLog(...)`
Log newLog({
  required String logType,
  required int logIndex,
  required String transactionHash,
  required Map<String, dynamic> event,
  required String contractVersion,
  required String contractAddress,
}) {
  return Log(
    logType: logType,
    logIndex: logIndex,
    transactionHash: transactionHash,
    event: event,
    contractVersion: contractVersion,
    contractAddress: contractAddress,
    createdAt: DateTime.now().toUtc(),
  );
}
