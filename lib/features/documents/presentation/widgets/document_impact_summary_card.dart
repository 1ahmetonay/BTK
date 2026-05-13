import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_card.dart';
import '../documents_mock_data.dart';

class DocumentImpactSummaryCard extends StatelessWidget {
  const DocumentImpactSummaryCard({
    required this.items,
    super.key,
  });

  final List<AutomationEffectItem> items;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Bu belge işlendiğinde',
      subtitle: 'Sistemde oluşacak otomatik hareket özeti',
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, color: item.iconColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.text,
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
