import 'package:flutter/material.dart';

import '../finance_mock_data.dart';

class AiFinanceSuggestionsCard extends StatelessWidget {
  const AiFinanceSuggestionsCard({required this.insights, this.onApply, super.key});

  final List<FinanceInsightMock> insights;
  final ValueChanged<String>? onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF2C694E), size: 18),
            SizedBox(width: 8),
            Text(
              'AI ÖNERİLERİ',
              style: TextStyle(
                color: Color(0xFF002045),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 174,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: insights.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _AiSuggestionCard(insight: insights[index], index: index, onApply: onApply);
            },
          ),
        ),
      ],
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({required this.insight, required this.index, this.onApply});

  final FinanceInsightMock insight;
  final int index;
  final ValueChanged<String>? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFF2C694E), width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF002045),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              _message,
              style: const TextStyle(
                color: Color(0xFF43474E),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: FilledButton(
              onPressed: () => onApply?.call(_message),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C694E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Uygula'),
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    return switch (index) {
      0 => 'Nakit Açığı Yönetimi',
      1 => 'Marj Analizi',
      _ => 'Tahsilat Hatırlatıcı',
    };
  }

  String get _message {
    return switch (index) {
      0 =>
        '14. gün beklenen nakit açığı için tedarikçi ödemelerinizi 5 gün ötelemeniz önerilir.',
      1 =>
        'Lojistik maliyetleriniz geçen aya göre %18 arttı. Alternatif kurye hizmetlerini inceleyin.',
      _ => insight.message,
    };
  }
}
