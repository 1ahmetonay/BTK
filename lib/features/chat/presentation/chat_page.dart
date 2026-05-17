import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/api_service.dart';
import 'chat_mock_data.dart';
import 'widgets/chat_conversation_card.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageMock> _messages = [
    ChatMessageMock(
      id: 'assistant-initial',
      role: ChatRole.assistant,
      message:
          'Merhaba, ben KOBİ AI Asistan. Stok, finans, KDV, tedarik ve puantaj verilerinizi analiz edebilirim.',
      timestamp: DateTime(2026, 5, 13, 9),
    ),
    ChatMessageMock(
      id: 'user-seed',
      role: ChatRole.user,
      message: 'Önümüzdeki ay nakit sıkışması yaşar mıyım?',
      timestamp: DateTime(2026, 5, 13, 9, 2),
    ),
    ChatMessageMock(
      id: 'assistant-seed',
      role: ChatRole.assistant,
      message:
          '30 günlük projeksiyona göre 14 gün sonra 42.000 TL nakit açığı riski görünüyor. Ana neden Aksoy Tedarik ödemesi ve gecikmiş 3 tahsilat.',
      timestamp: DateTime(2026, 5, 13, 9, 3),
      tools: const [
        ToolUsageMock('get_cash_forecast'),
        ToolUsageMock('get_overdue_payments'),
        ToolUsageMock('get_finance_summary'),
      ],
      steps: const [
        'Soru yorumlandı',
        'Nakit akışı verisi incelendi',
        'Gecikmiş tahsilatlar kontrol edildi',
        'Risk ve öneri üretildi',
      ],
    ),
  ];

  bool _isTyping = false;
  int _messageCounter = 0;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AssistantIntroCard(),
        const SizedBox(height: 16),
        ChatConversationCard(
          messages: _messages,
          isTyping: _isTyping,
          controller: _scrollController,
          inputController: _inputController,
          onSubmit: _sendQuestion,
          suggestedQuestions: const [
            SuggestedQuestionMock(question: 'Nakit akışım nasıl görünüyor?', icon: Icons.account_balance_wallet_outlined),
            SuggestedQuestionMock(question: 'Kritik stok durumu nedir?', icon: Icons.inventory_2_outlined),
            SuggestedQuestionMock(question: 'Bu ay KDV borcum ne kadar?', icon: Icons.receipt_long_outlined),
            SuggestedQuestionMock(question: 'Gecikmiş ödemelerim var mı?', icon: Icons.warning_amber_outlined),
          ],
          onQuestionSelected: _sendQuestion,
          onFileAttached: (name) {
            _showMessage('$name eklendi.');
          },
          onFileBytesAttached: (name, bytes) => _handleFileAttached(name, bytes),
        ),
      ],
    );
  }

  Future<void> _sendQuestion(String rawQuestion) async {
    final question = rawQuestion.trim();
    if (question.isEmpty || _isTyping) {
      return;
    }

    _inputController.clear();

    setState(() {
      _messages.add(
        ChatMessageMock(
          id: 'user-${_messageCounter++}',
          role: ChatRole.user,
          message: question,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    // ─── EK-4 DÜZELTMESİ: Gerçek Backend API Çağrısı ────────────────
    String responseText;
    List<ToolUsageMock> tools = [];
    List<String> steps = [];

    try {
      // Backend orchestrator'a gönder (ReAct döngüsü)
      final aiMode = ref.read(aiModeProvider);
      final result = await ApiService.instance.chat(question, aiMode: aiMode);

      responseText = result['response'] as String? ?? 'Yanıt alınamadı.';

      // Kullanılan araçları parse et
      final toolsUsed = result['tools_used'] as List<dynamic>? ?? [];
      tools = toolsUsed
          .map((t) => ToolUsageMock(t.toString()))
          .toList();

      // Düşünme adımlarını parse et
      final thinkingSteps = result['thinking_steps'] as List<dynamic>? ?? [];
      steps = thinkingSteps
          .map((s) => (s as Map<String, dynamic>)['detail'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      // Backend'e ulaşılamazsa hata mesajı göster
      responseText = 'Backend bağlantısı kurulamadı. Lütfen backend sunucusunun çalıştığından emin olun.';
      tools = [];
      steps = [];
    }

    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessageMock(
          id: 'assistant-${_messageCounter++}',
          role: ChatRole.assistant,
          message: responseText,
          timestamp: DateTime.now(),
          tools: tools,
          steps: steps,
        ),
      );
      _isTyping = false;
    });
    _scrollToBottom();
  }


  Future<void> _handleFileAttached(String name, List<int>? bytes) async {
    if (bytes == null || bytes.isEmpty) {
      _showMessage('$name dosyası okunamadı.');
      return;
    }
    setState(() {
      _messages.add(ChatMessageMock(
        id: 'user-file-${_messageCounter++}',
        role: ChatRole.user,
        message: '$name dosyası eklendi. Analiz ediliyor...',
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();
    try {
      final result = await ApiService.instance.processDocument(bytes, name);
      if (!mounted) return;
      final geminiOut = result['gemini_output'] as Map<String, dynamic>? ?? {};
      final tur = result['tur'] as String? ?? geminiOut['belge_tipi'] as String? ?? 'Belge';
      final toplam = result['toplam_tutar'] ?? geminiOut['genel_toplam'] ?? '—';
      final kalemler = geminiOut['kalemler'] as List<dynamic>? ?? [];
      final response = '$tur analiz edildi.\n'
          'Toplam: $toplam TL\n'
          'Kalem sayısı: ${kalemler.length}\n'
          'Güven: %${((result['guven_skoru'] as num?)?.toDouble() ?? 0.9) * 100 ~/ 1}';
      setState(() {
        _messages.add(ChatMessageMock(
          id: 'assistant-file-${_messageCounter++}',
          role: ChatRole.assistant,
          message: response,
          timestamp: DateTime.now(),
          tools: const [ToolUsageMock('process_document')],
          steps: const ['Dosya alındı', 'Gemini Vision ile analiz edildi', 'Sonuç oluşturuldu'],
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessageMock(
          id: 'assistant-err-${_messageCounter++}',
          role: ChatRole.assistant,
          message: 'Dosya analiz edilemedi: $e',
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }
}

class _AssistantIntroCard extends StatelessWidget {
  const _AssistantIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF002045), width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KOBİ AI Asistan',
              style: TextStyle(
                color: Color(0xFF002045),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Stok, finans, KDV ve puantaj verilerinizi analiz edebilirim.',
              style: TextStyle(
                color: Color(0xFF0E5138),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.45,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Doğal Türkçe sorular sorun, sistem kayıtlarınızı yorumlayarak öneriler sunsun.',
              style: TextStyle(
                color: Color(0xFF43474E),
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
