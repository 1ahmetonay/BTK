import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../documents_mock_data.dart';

class DocumentAnalysisResultCard extends StatelessWidget {
  const DocumentAnalysisResultCard({
    required this.analysis,
    super.key,
  });

  final DocumentAnalysisMock analysis;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Gemini Vision Analiz Sonucu',
      subtitle: 'Belgeden çıkarılan temel finans ve stok alanları',
      trailing: StatusBadge(
        label: analysis.statusLabel,
        tone: analysis.statusTone,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: analysis.fields
                .map(
                  (field) => _AnalysisFieldTile(
                    label: field.label,
                    value: field.value,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Güven skoru',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: analysis.confidenceScore,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            color: AppColors.primary,
            backgroundColor: AppColors.gray200,
          ),
          const SizedBox(height: 8),
          Text(
            '%${(analysis.confidenceScore * 100).round()} güven ile alan eşleştirmesi tamamlandı',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisFieldTile extends StatelessWidget {
  const _AnalysisFieldTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
