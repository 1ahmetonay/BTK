import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aktif sohbetin conversation_id'sini tutar.
/// In-memory: uygulama restart'ında null'a döner (backend de 6 saat sonra
/// session'ı zaten siler, kalıcı tutmanın anlamı yok).
class ConversationNotifier extends StateNotifier<String?> {
  ConversationNotifier() : super(null);

  /// Backend'den dönen ID'yi kaydet.
  void set(String id) => state = id;

  /// "Yeni sohbet" — bir sonraki mesaj null gönderir, backend yeni UUID üretir.
  void reset() => state = null;
}

final conversationIdProvider =
    StateNotifierProvider<ConversationNotifier, String?>(
  (ref) => ConversationNotifier(),
);