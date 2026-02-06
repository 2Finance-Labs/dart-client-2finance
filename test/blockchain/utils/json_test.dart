// test/blockchain/utils/json_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';

// Adjust import to your real file path.
import 'package:two_finance_blockchain/blockchain/utils/json.dart';

void main() {
  group('toJsonRawMessage / mapToJsonRawMessage', () {
    test('toJsonRawMessage encodes map into UTF-8 JSON bytes', () {
      final obj = {'a': 1, 'b': 'x', 'c': true};

      final bytes = toJsonRawMessage(obj);

      expect(bytes, isA<Uint8List>());
      final s = utf8.decode(bytes);
      expect(jsonDecode(s), obj);
    });

    test('mapToJsonRawMessage encodes map into UTF-8 JSON bytes', () {
      final map = {'k': 'v', 'n': 10};

      final bytes = mapToJsonRawMessage(map);

      expect(bytes, isA<Uint8List>());
      final s = utf8.decode(bytes);
      expect(jsonDecode(s), map);
    });

    test('toJsonRawMessage and mapToJsonRawMessage produce identical output', () {
      final m = {'a': 1, 'b': 2};

      final b1 = toJsonRawMessage(m);
      final b2 = mapToJsonRawMessage(m);

      expect(utf8.decode(b1), utf8.decode(b2));
    });

    test('encoded bytes are deterministic for same input map', () {
      final m = {'a': 1, 'b': {'c': 3}, 'd': [1, 2, 3]};

      final s1 = utf8.decode(toJsonRawMessage(m));
      final s2 = utf8.decode(toJsonRawMessage(m));

      expect(s1, s2);
      expect(jsonDecode(s1), m);
    });
  });

  group('canonicalJsonEncode', () {
    test('sorts object keys lexicographically (top-level)', () {
      final m = {'b': 2, 'a': 1, 'c': 3};
      expect(canonicalJsonEncode(m), '{"a":1,"b":2,"c":3}');
    });

    test('sorts nested object keys lexicographically (recursive)', () {
      final m = {
        'z': {'b': 2, 'a': 1},
        'a': 0,
      };
      expect(canonicalJsonEncode(m), '{"a":0,"z":{"a":1,"b":2}}');
    });

    test('keeps list order stable', () {
      final v = [3, 2, 1];
      expect(canonicalJsonEncode(v), '[3,2,1]');
    });

    test('encodes list of objects with canonical objects inside', () {
      final v = [
        {'b': 2, 'a': 1},
        {'d': 4, 'c': 3},
      ];
      expect(canonicalJsonEncode(v), '[{"a":1,"b":2},{"c":3,"d":4}]');
    });

    test('encodes primitives via jsonEncode (string/number/bool/null)', () {
      expect(canonicalJsonEncode('x'), jsonEncode('x'));
      expect(canonicalJsonEncode(10), '10');
      expect(canonicalJsonEncode(true), 'true');
      expect(canonicalJsonEncode(null), 'null');
    });

    test('produces stable output regardless of insertion order', () {
      final m1 = {'b': 2, 'a': 1, 'c': {'y': 2, 'x': 1}};
      final m2 = {'c': {'x': 1, 'y': 2}, 'a': 1, 'b': 2};

      expect(canonicalJsonEncode(m1), canonicalJsonEncode(m2));
      expect(canonicalJsonEncode(m1), '{"a":1,"b":2,"c":{"x":1,"y":2}}');
    });

    test('no whitespace in canonical output', () {
      final m = {'b': 2, 'a': 1};
      final s = canonicalJsonEncode(m);

      expect(s.contains(' '), isFalse);
      expect(s.contains('\n'), isFalse);
      expect(s.contains('\t'), isFalse);
    });
  });
}
