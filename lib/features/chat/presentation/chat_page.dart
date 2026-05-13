import 'package:flutter/material.dart';

import 'chat_mock_data.dart';
import 'widgets/chat_conversation_card.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
          suggestedQuestions: ChatMockData.suggestedQuestions,
          onQuestionSelected: _sendQuestion,
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

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }

    final response = ChatMockData.responseFor(question);
    setState(() {
      _messages.add(
        ChatMessageMock(
          id: 'assistant-${_messageCounter++}',
          role: ChatRole.assistant,
          message: response.message,
          timestamp: DateTime.now(),
          tools: response.tools,
          steps: response.steps,
        ),
      );
      _isTyping = false;
    });
    _scrollToBottom();
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
