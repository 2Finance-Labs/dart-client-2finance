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