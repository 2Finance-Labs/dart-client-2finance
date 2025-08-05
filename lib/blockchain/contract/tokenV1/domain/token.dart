import 'package:two_finance_blockchain/blockchain/keys/keys.dart';

void validateUserMap(Map<String, bool> users, String label) {
for (final entry in users.entries) {
    final addr = entry.key.trim();
    try {
    KeyManager.validateEdDSAPublicKey(addr);
    } catch (e) {
    throw ArgumentError("invalid $label address '$addr': $e");
    }
}
}
