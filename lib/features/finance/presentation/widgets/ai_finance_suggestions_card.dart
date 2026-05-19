import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../finance_mock_data.dart';

class AiFinanceSuggestionsCard extends StatelessWidget {
  const AiFinanceSuggestionsCard({
    required this.insights,
    this.onApply,
    super.key,
  });

  final List<FinanceInsightMock> insights;
  final ValueChanged<String>? onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.secondary, size: 18),
            SizedBox(width: 8),
            Text(
              'AI ÖNERİLERİ',
              style: TextStyle(
                color: AppColors.primary,
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
              return _AiSuggestionCard(
                insight: insights[index],
                index: index,
                onApply: onApply,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({
    required this.insight,
    required this.index,
    this.onApply,
  });

  final FinanceInsightMock insight;
  final int index;
  final ValueChanged<String>? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 4),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              _message,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: FilledButton(
              onPressed: () => onApply?.call(insight.message),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
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

  String get _message => insight.message;
}
