import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../employees_mock_data.dart';

class AiAttendanceSuggestionsCard extends StatelessWidget {
  const AiAttendanceSuggestionsCard({
    required this.insights,
    super.key,
  });

  final List<EmployeeInsightMock> insights;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'AI Puantaj Önerileri',
      subtitle: 'Bordro, mesai ve kontrol aksiyonları',
      child: Column(
        children: insights
            .map(
              (insight) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceUltraLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: insight.iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        insight.icon,
                        color: insight.iconColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.message,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
