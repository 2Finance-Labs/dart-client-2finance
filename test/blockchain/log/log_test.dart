import 'package:test/test.dart';

// Adjust the import path if needed
import 'package:two_finance_blockchain/blockchain/log/log.dart';

void main() {
    final validTxHash = 'a' * 64;
    const validContractAddress = '0xcontract';
    const validContractVersion = 'v1';

  group('Log constructor & getters', () {
    test('creates log and exposes getters correctly', () {
      final createdAt = DateTime.utc(2026, 1, 1);

      final log = Log(
        logType: 'event',
        logIndex: 1,
        transactionHash: validTxHash,
        event: {'key': 'value'},
        contractVersion: validContractVersion,
        contractAddress: validContractAddress,
        createdAt: createdAt,
      );

      expect(log.getLogType(), 'event');
      expect(log.getLogIndex(), 1);
      expect(log.getTransactionHash(), validTxHash);
      expect(log.getEvent(), {'key': 'value'});
      expect(log.getContractVersion(), validContractVersion);
      expect(log.getContractAddress(), validContractAddress);
      expect(log.createdAt, createdAt);
    });
  });

  group('Log.fromJson / toJson', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'log_type': 'event',
        'log_index': 2,
        'transaction_hash': validTxHash,
        'event': {'amount': 10},
        'contract_version': validContractVersion,
        'contract_address': validContractAddress,
        'created_at': '2026-01-01T00:00:00.000Z',
      };

      final log = Log.fromJson(json);

      expect(log.logType, 'event');
      expect(log.logIndex, 2);
      expect(log.transactionHash, validTxHash);
      expect(log.event, {'amount': 10});
      expect(log.contractVersion, validContractVersion);
      expect(log.contractAddress, validContractAddress);
      expect(log.createdAt.toUtc().toIso8601String(), json['created_at']);
    });

    test('toJson serializes all fields correctly', () {
      final createdAt = DateTime.utc(2026, 1, 1);

      final log = Log(
        logType: 'event',
        logIndex: 3,
        transactionHash: validTxHash,
        event: {'x': 1},
        contractVersion: validContractVersion,
        contractAddress: validContractAddress,
        createdAt: createdAt,
      );

      final json = log.toJson();

      expect(json, {
        'log_type': 'event',
        'log_index': 3,
        'transaction_hash': validTxHash,
        'event': {'x': 1},
        'contract_version': validContractVersion,
        'contract_address': validContractAddress,
        'created_at': createdAt.toIso8601String(),
      });
    });

    test('roundtrip toJson -> fromJson -> toJson', () {
      final original = Log(
        logType: 'event',
        logIndex: 4,
        transactionHash: validTxHash,
        event: {'foo': 'bar'},
        contractVersion: validContractVersion,
        contractAddress: validContractAddress,
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final json = original.toJson();
      final parsed = Log.fromJson(json);

      expect(parsed.toJson(), json);
    });
  });

  group('Log.validateLog', () {
    Log validLog() => Log(
          logType: 'event',
          logIndex: 1,
          transactionHash: validTxHash,
          event: {'ok': true},
          contractVersion: validContractVersion,
          contractAddress: validContractAddress,
          createdAt: DateTime.now().toUtc(),
        );

    test('does not throw for valid log', () {
      final log = validLog();
      expect(log.validateLog, returnsNormally);
    });

    test('throws if logType is empty', () {
      final log = validLog().copyWith(logType: '');
      expect(() => log.validateLog(), throwsException);
    });

    test('throws if logIndex is zero', () {
      final log = validLog().copyWith(logIndex: 0);
      expect(() => log.validateLog(), throwsException);
    });

    test('throws if transactionHash length is invalid', () {
      final log = validLog().copyWith(transactionHash: 'abc');
      expect(() => log.validateLog(), throwsException);
    });

    test('throws if event is empty', () {
      final log = validLog().copyWith(event: {});
      expect(() => log.validateLog(), throwsException);
    });

    test('throws if contractAddress is empty', () {
      final log = validLog().copyWith(contractAddress: '');
      expect(() => log.validateLog(), throwsException);
    });

    test('throws if contractVersion is empty', () {
      final log = validLog().copyWith(contractVersion: '');
      expect(() => log.validateLog(), throwsException);
    });
  });

  group('newLog factory', () {
    test('creates a valid log with createdAt set', () {
      final log = newLog(
        logType: 'event',
        logIndex: 10,
        transactionHash: validTxHash,
        event: {'hello': 'world'},
        contractVersion: validContractVersion,
        contractAddress: validContractAddress,
      );

      expect(log.logType, 'event');
      expect(log.logIndex, 10);
      expect(log.transactionHash, validTxHash);
      expect(log.event, {'hello': 'world'});
      expect(log.contractVersion, validContractVersion);
      expect(log.contractAddress, validContractAddress);
      expect(log.createdAt, isNotNull);

      // sanity check
      expect(log.validateLog, returnsNormally);
    });
  });
}

/// Small helper extension for tests only
extension _LogCopy on Log {
  Log copyWith({
    String? logType,
    int? logIndex,
    String? transactionHash,
    Map<String, dynamic>? event,
    String? contractVersion,
    String? contractAddress,
  }) {
    return Log(
      logType: logType ?? this.logType,
      logIndex: logIndex ?? this.logIndex,
      transactionHash: transactionHash ?? this.transactionHash,
      event: event ?? this.event,
      contractVersion: contractVersion ?? this.contractVersion,
      contractAddress: contractAddress ?? this.contractAddress,
      createdAt: createdAt,
    );
  }
}
