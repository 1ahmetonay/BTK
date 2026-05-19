import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chat/presentation/chat_mock_data.dart';

/// Chat mesajlarini ve conversation ID'yi SharedPreferences'a kaydeder.
class ChatStorage {
  ChatStorage._();

  static const _messagesKey = 'chat_messages';
  static const _conversationIdKey = 'chat_conversation_id';

  // ── Mesajlar ──────────────────────────────────────────────────────

  static Future<void> saveMessages(List<ChatMessageMock> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final list = messages.map((m) => _messageToJson(m)).toList();
    await prefs.setString(_messagesKey, jsonEncode(list));
  }

  static Future<List<ChatMessageMock>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_messagesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((j) => _messageFromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey);
  }

  // ── Conversation ID ───────────────────────────────────────────────

  static Future<void> saveConversationId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await prefs.remove(_conversationIdKey);
    } else {
      await prefs.setString(_conversationIdKey, id);
    }
  }

  static Future<String?> loadConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_conversationIdKey);
  }

  // ── Serialization ─────────────────────────────────────────────────

  static Map<String, dynamic> _messageToJson(ChatMessageMock m) {
    return {
      'id': m.id,
      'role': m.role == ChatRole.user ? 'user' : 'assistant',
      'message': m.message,
      'timestamp': m.timestamp.toIso8601String(),
      'tools': m.tools.map((t) => t.name).toList(),
      'steps': m.steps,
    };
  }

  static ChatMessageMock _messageFromJson(Map<String, dynamic> j) {
    return ChatMessageMock(
      id: j['id'] as String? ?? '',
      role: j['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
      message: j['message'] as String? ?? '',
      timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
      tools: (j['tools'] as List<dynamic>?)
              ?.map((t) => ToolUsageMock(t as String))
              .toList() ??
          const [],
      steps: (j['steps'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          const [],
    );
  }
}
