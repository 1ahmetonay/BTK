import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../stock_mock_data.dart';

class StockInsightsCard extends StatelessWidget {
  const StockInsightsCard({required this.insights, super.key});

  final List<StockInsightMock> insights;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < insights.length; index++) ...[
          Expanded(child: _InsightMiniCard(insight: insights[index])),
          if (index != insights.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _InsightMiniCard extends StatelessWidget {
  const _InsightMiniCard({required this.insight});

  final StockInsightMock insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 28,
            child: Text(
              _title(insight.title),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              value: insight.progress.clamp(0.08, 0.92),
              strokeWidth: 4,
              color: insight.color,
              backgroundColor: AppColors.outlineSoft,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _value(insight),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: insight.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _title(String title) {
    return switch (title) {
      'Stok Devir Hızı' => 'TÜKETİM HIZI',
      _ => title.toUpperCase(),
    };
  }

  String _value(StockInsightMock insight) {
    return switch (insight.title) {
      'ABC Analizi' => '%82 A Grubu',
      'Enflasyon Etkisi' => '+14% Artış',
      'Stok Devir Hızı' => 'Stabil',
      _ => insight.valueLabel,
    };
  }
}
