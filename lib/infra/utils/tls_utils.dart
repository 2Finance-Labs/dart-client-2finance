import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Loads a CA certificate into a [SecurityContext].
/// Throws if the file is not accessible or invalid.
SecurityContext createSecurityContext(String? caCertPath) {
    final context = SecurityContext();
    if (caCertPath == null || caCertPath.isEmpty) {
        throw Exception('❌ TLS Error: CA certificate path must not be null or empty');
    }
    try {
        context.setTrustedCertificates(caCertPath);
    } on TlsException catch (e) {
        throw Exception('❌ TLS Error: Failed to load CA certificate from $caCertPath: ${e.message}');
    } catch (e) {
        throw Exception('❌ TLS Error: Unexpected error loading CA cert: $e');
    }

    return context;
}

Future<String> extractCaCertAsset(String assetPath) async {
  print('📥 Requested asset extraction for: $assetPath');

  try {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/emqx-ca.crt';
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return filePath;
  } catch (e) {
    print('❌ Error extracting CA cert asset: $e');
    rethrow;
  }
}
