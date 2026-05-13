import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../alerts_mock_data.dart';

class AlertsSidePanel extends StatelessWidget {
  const AlertsSidePanel({
    required this.priorityDistribution,
    required this.categoryDistribution,
    required this.dailySummary,
    super.key,
  });

  final List<AlertDistributionMock> priorityDistribution;
  final List<AlertDistributionMock> categoryDistribution;
  final String dailySummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DistributionCard(
          title: 'Öncelik Dağılımı',
          items: priorityDistribution,
        ),
        const SizedBox(height: 16),
        _DistributionCard(
          title: 'Kategori Dağılımı',
          items: categoryDistribution,
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'AI Günlük Özeti',
          subtitle: 'Bugünün öncelikli aksiyon önerileri',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dailySummary,
                    style: const TextStyle(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<AlertDistributionMock> items;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge(label: item.value, tone: item.tone),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
