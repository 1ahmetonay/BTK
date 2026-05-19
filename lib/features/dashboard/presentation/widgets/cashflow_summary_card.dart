import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../dashboard_mock_data.dart';

class CashflowSummaryCard extends StatelessWidget {
  const CashflowSummaryCard({
    required this.metrics,
    this.suggestion = '',
    this.trailingLabel,
    super.key,
  });

  final List<CashflowMetricData> metrics;
  final String suggestion;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Nakit Akışı Özeti',
      subtitle: '30 günlük tahmine göre pozisyon görünümü',
      trailing: trailingLabel != null
          ? Text(
              trailingLabel!,
              style: const TextStyle(
                color: AppColors.rose,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
      child: metrics.isEmpty
          ? const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Nakit akışı verisi yok',
              description: 'Backend bağlantısı kurulduğunda veriler burada görünecek.',
            )
          : Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 520 ? 1 : 2;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 3.6 : 2.5,
                      children: metrics
                          .map(
                            (metric) => Container(
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
                                    metric.label,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    metric.value,
                                    style: TextStyle(
                                      color: metric.emphasisColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                if (suggestion.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warningBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.auto_awesome_outlined,
                          color: AppColors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI önerisi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                suggestion,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
