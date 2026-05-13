import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../documents_mock_data.dart';

class DocumentItemsTableCard extends StatelessWidget {
  const DocumentItemsTableCard({
    required this.title,
    required this.subtitle,
    required this.columns,
    required this.items,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<String> columns;
  final List<DocumentLineItemMock> items;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      subtitle: subtitle,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, itemIndex) {
          final item = items[itemIndex];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.values.first,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (var index = 1; index < columns.length; index++)
                  _ItemMetric(
                    label: columns[index],
                    value: item.values[index],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemMetric extends StatelessWidget {
  const _ItemMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
