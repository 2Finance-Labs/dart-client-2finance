import 'package:test/test.dart';
import 'package:two_finance_blockchain/blockchain/types/types.dart';

void main() {
  group('StateType', () {
    test('toJson omits null fields', () {
      final s = StateType();
      final json = s.toJson();

      expect(json.containsKey('type'), isFalse);
      expect(json.containsKey('object'), isFalse);
      expect(json, isEmpty);
    });

    test('toJson includes non-null fields', () {
      final s = StateType(
        type: 'balance_v1',
        object: {'address': 'abc', 'amount': '10'},
      );

      final json = s.toJson();
      expect(json['type'], 'balance_v1');
      expect(json['object'], {'address': 'abc', 'amount': '10'});
    });

    test('fromJson parses fields (including nulls)', () {
      final s1 = StateType.fromJson({'type': 'x', 'object': {'a': 1}});
      expect(s1.type, 'x');
      expect(s1.object, {'a': 1});

      final s2 = StateType.fromJson({'type': null, 'object': null});
      expect(s2.type, isNull);
      expect(s2.object, isNull);
    });

    test('roundtrip fromJson -> toJson', () {
      final input = {
        'type': 'token_v1',
        'object': {'symbol': 'ADI', 'decimals': 18}
      };

      final s = StateType.fromJson(input);
      expect(s.toJson(), input);
    });
  });

  group('ContractOutput', () {
    test('toJson omits null fields', () {
      final out = ContractOutput();
      final json = out.toJson();

      expect(json.containsKey('states'), isFalse);
      expect(json.containsKey('logs'), isFalse);
      expect(json.containsKey('delegated_call'), isFalse);
      expect(json, isEmpty);
    });

    test('fromJson handles missing keys and null lists', () {
      final out1 = ContractOutput.fromJson({});
      expect(out1.states, isNull);
      expect(out1.logs, isNull);
      expect(out1.delegatedCall, isNull);

      final out2 = ContractOutput.fromJson({
        'states': null,
        'logs': null,
        'delegated_call': null,
      });
      expect(out2.states, isNull);
      expect(out2.logs, isNull);
      expect(out2.delegatedCall, isNull);
    });

    test('parses states list', () {
      final out = ContractOutput.fromJson({
        'states': [
          {'type': 'balance_v1', 'object': {'address': 'a', 'amount': '1'}},
          {'type': 'mint_v1', 'object': {'token': 'ADI', 'supply': '100'}},
        ],
      });

      expect(out.states, isNotNull);
      expect(out.states!.length, 2);
      expect(out.states![0].type, 'balance_v1');
      expect(out.states![0].object, {'address': 'a', 'amount': '1'});
      expect(out.states![1].type, 'mint_v1');
      expect(out.states![1].object, {'token': 'ADI', 'supply': '100'});
    });

    test('parses delegated_call recursively', () {
      final out = ContractOutput.fromJson({
        'delegated_call': [
          {
            'states': [
              {'type': 'x', 'object': {'k': 'v'}}
            ],
          },
          {
            'delegated_call': [
              {
                'states': [
                  {'type': 'y', 'object': {'n': 1}}
                ]
              }
            ]
          }
        ]
      });

      expect(out.delegatedCall, isNotNull);
      expect(out.delegatedCall!.length, 2);

      // first delegated call has states
      final c1 = out.delegatedCall![0];
      expect(c1.states, isNotNull);
      expect(c1.states!.length, 1);
      expect(c1.states![0].type, 'x');
      expect(c1.states![0].object, {'k': 'v'});

      // second delegated call has nested delegated_call
      final c2 = out.delegatedCall![1];
      expect(c2.delegatedCall, isNotNull);
      expect(c2.delegatedCall!.length, 1);
      expect(c2.delegatedCall![0].states, isNotNull);
      expect(c2.delegatedCall![0].states![0].type, 'y');
      expect(c2.delegatedCall![0].states![0].object, {'n': 1});
    });

    test('toJson serializes states and delegated_call', () {
      final out = ContractOutput(
        states: [
          StateType(type: 'a', object: {'x': 1}),
        ],
        delegatedCall: [
          ContractOutput(
            states: [StateType(type: 'b', object: {'y': 2})],
          ),
        ],
      );

      final json = out.toJson();
      expect(json, {
        'states': [
          {'type': 'a', 'object': {'x': 1}}
        ],
        'delegated_call': [
          {
            'states': [
              {'type': 'b', 'object': {'y': 2}}
            ]
          }
        ]
      });
    });

    test('roundtrip toJson -> fromJson -> toJson (without logs)', () {
      final input = {
        'states': [
          {'type': 'token', 'object': {'symbol': 'ADI'}},
        ],
        'delegated_call': [
          {
            'states': [
              {'type': 'balance', 'object': {'address': 'a', 'amount': '10'}}
            ]
          }
        ]
      };

      final out = ContractOutput.fromJson(input);
      expect(out.toJson(), input);
    });

    test('logs: parses and serializes minimal log objects', () {
        final input = {
            'logs': [
            {
                'log_type': 'event',
                'log_index': 1,
                'transaction_hash': 'a' * 64,
                'event': {'name': 'TestEvent', 'value': 123},
                'contract_version': 'v1',
                'contract_address': DEPLOY_CONTRACT_ADDRESS,
                'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
            }
            ]
        };

        final out = ContractOutput.fromJson(input);

        expect(out.logs, isNotNull);
        expect(out.logs!.length, 1);

        // garante que Log foi parseado corretamente
        final log = out.logs!.first;
        expect(log.logType, 'event');
        expect(log.logIndex, 1);
        expect(log.transactionHash, 'a' * 64);
        expect(log.contractVersion, 'v1');
        expect(log.contractAddress, DEPLOY_CONTRACT_ADDRESS);
        expect(log.event, {'name': 'TestEvent', 'value': 123});

        // roundtrip
        final json = out.toJson();
        expect(json, input);
        });

  });
}
