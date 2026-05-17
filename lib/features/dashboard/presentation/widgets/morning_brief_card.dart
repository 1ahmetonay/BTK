import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../dashboard_mock_data.dart';

class MorningBriefCard extends StatelessWidget {
  const MorningBriefCard({required this.items, this.onDetailPressed, super.key});

  final List<BriefItemData> items;
  final VoidCallback? onDetailPressed;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: items.isNotEmpty
          ? 'Günaydın, bugün ${items.length} öncelikli konu var'
          : 'Sabah Brifingi',
      subtitle: 'Sabah brifingi',
      trailing: FilledButton.tonalIcon(
        onPressed: onDetailPressed ?? () {},
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Detaylı Brifingi Aç'),
      ),
      child: items.isEmpty
          ? const EmptyState(
              icon: Icons.wb_sunny_outlined,
              title: 'Brifing hazırlanıyor',
              description: 'Veriler yüklendikçe günlük brifing burada görünecek.',
            )
          : Column(
              children: [
                for (final item in items)
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
