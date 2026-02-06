import 'dart:convert'; // jsonEncode, jsonDecode, utf8
import 'dart:typed_data'; // Uint8List

typedef JSONB = Map<String, dynamic>;
typedef JsonRawMessage = Uint8List;


Uint8List toJsonRawMessage(Map<String, dynamic> obj) {
    final bytes = utf8.encode(jsonEncode(obj));
    return Uint8List.fromList(bytes);
}
Uint8List mapToJsonRawMessage(Map<String, dynamic> map) {
  return Uint8List.fromList(utf8.encode(jsonEncode(map)));
}

/// Canonical JSON (JCS-like) encoder:
/// - sorts object keys lexicographically
/// - no whitespace
/// - stable output
String canonicalJsonEncode(dynamic value) {
  if (value is Map) {
    final keys = value.keys.map((k) => k.toString()).toList()..sort();
    final entries = <String>[];

    for (final k in keys) {
      entries.add(
        '${jsonEncode(k)}:${canonicalJsonEncode(value[k])}',
      );
    }
    return '{${entries.join(',')}}';
  }

  if (value is List) {
    final items = value.map(canonicalJsonEncode).join(',');
    return '[$items]';
  }

  // primitives (string, number, bool, null)
  return jsonEncode(value);
}