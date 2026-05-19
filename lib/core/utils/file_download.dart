import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

Future<bool> downloadBytes({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) async {
  if (kIsWeb) {
    return _downloadWeb(bytes, fileName, mimeType);
  }
  return false;
}

Future<bool> _downloadWeb(Uint8List bytes, String fileName, String mimeType) async {
  try {
    // ignore: avoid_web_libraries_in_flutter
    // Web'de dart:html kullanarak indirme — ancak conditional import gerekir
    // Basit yaklaşım: universal_html paketi yoksa false dön
    return false;
  } catch (_) {
    return false;
  }
}
