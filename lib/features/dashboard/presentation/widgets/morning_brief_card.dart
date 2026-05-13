import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_card.dart';
import '../dashboard_mock_data.dart';

class MorningBriefCard extends StatelessWidget {
  const MorningBriefCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Günaydın, bugün 3 öncelikli konu var',
      subtitle: 'Sabah brifingi',
      trailing: FilledButton.tonalIcon(
        onPressed: () {},
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Detaylı Brifingi Aç'),
      ),
      child: Column(
        children: [
          for (final item in DashboardMockData.briefItems)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.accentColor.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: item.accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.priority_high_outlined,
                      color: item.accentColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.detail,
                          style: const TextStyle(
                            color: Color(0xFF667085),
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
      ),
    );
  }
}
