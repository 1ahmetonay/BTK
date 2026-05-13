import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../chat_mock_data.dart';
import 'tool_chips.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({required this.message, super.key});

  final ChatMessageMock message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: isUser ? 0.86 : (message.tools.isEmpty ? 0.86 : 0.92),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF002045)
                    : message.tools.isEmpty
                    ? const Color(0xFFE7E8E9)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 12 : 2),
                  topRight: Radius.circular(isUser ? 2 : 12),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
                border: isUser
                    ? null
                    : Border.all(color: const Color(0xFFC4C6CF)),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.ink,
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: isUser ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    if (!isUser && message.tools.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const _RecommendationCard(),
                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFC4C6CF)),
                      const SizedBox(height: 8),
                      _AnalysisSteps(steps: message.steps),
                      const SizedBox(height: 18),
                      const Text(
                        'Kullanılan Araçlar',
                        style: TextStyle(
                          color: Color(0xFF43474E),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ToolChips(tools: message.tools),
                      const SizedBox(height: 18),
                      const _ResultSummary(),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.bolt, size: 18),
                          label: const Text('Uygula'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF002045),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isUser ? 'SİZ • 2 DK ÖNCE' : _assistantStamp,
              style: const TextStyle(
                color: Color(0xFF43474E),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _assistantStamp {
    return message.tools.isEmpty
        ? 'AI ASİSTAN • ŞİMDİ'
        : 'AI ASİSTAN • 1 DK ÖNCE';
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFFE6F7EC),
        border: Border(left: BorderSide(color: Color(0xFF2C694E), width: 4)),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Önerim:',
            style: TextStyle(
              color: Color(0xFF0E5138),
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Aksoy Tedarik ödemesini 10 gün ertelemek ve toplam 38.800 TL gecikmiş tahsilat için hatırlatma göndermek.',
            style: TextStyle(
              color: Color(0xFF191C1D),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisSteps extends StatelessWidget {
  const _AnalysisSteps({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.analytics_outlined, color: Color(0xFF43474E), size: 16),
            SizedBox(width: 5),
            Text(
              'Analiz Adımları',
              style: TextStyle(
                color: Color(0xFF43474E),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final step in steps) ...[
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF2C694E),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Color(0xFF0E5138),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ],
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Özet Sonuç',
            style: TextStyle(
              color: Color(0xFF002045),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: _SummaryMetric(label: 'Risk', value: 'Orta', pill: true),
              ),
              _divider(),
              const Expanded(
                child: _SummaryMetric(
                  label: 'Tahmini Açık',
                  value: '42.000 TL',
                  valueColor: Color(0xFFBA1A1A),
                ),
              ),
              _divider(),
              const Expanded(
                child: _SummaryMetric(
                  label: 'Zaman',
                  value: '14 gün',
                  valueColor: Color(0xFF002045),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _divider() {
    return Container(width: 1, height: 42, color: const Color(0xFFC4C6CF));
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.pill = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF43474E), fontSize: 12),
        ),
        const SizedBox(height: 6),
        if (pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2D7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE9B963)),
            ),
            child: const Text(
              'Orta',
              style: TextStyle(
                color: Color(0xFF633F0F),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF191C1D),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE7E8E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC4C6CF)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Analiz ediliyor...'),
          ],
        ),
      ),
    );
  }
}
