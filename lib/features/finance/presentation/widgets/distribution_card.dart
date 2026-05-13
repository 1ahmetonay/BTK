import 'package:flutter/material.dart';

import '../finance_mock_data.dart';

class DistributionCard extends StatelessWidget {
  const DistributionCard({
    required this.incomeItems,
    required this.expenseItems,
    super.key,
  });

  final List<DistributionItemMock> incomeItems;
  final List<DistributionItemMock> expenseItems;

  @override
  Widget build(BuildContext context) {
    final visibleItems = [
      const DistributionItemMock(
        label: 'Perakende Satış',
        valueLabel: '%65',
        progress: 0.65,
        color: Color(0xFF002045),
      ),
      const DistributionItemMock(
        label: 'Online Sipariş',
        valueLabel: '%25',
        progress: 0.25,
        color: Color(0xFF002045),
      ),
      const DistributionItemMock(
        label: 'Personel Gideri',
        valueLabel: '%40',
        progress: 0.40,
        color: Color(0xFFBA1A1A),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GELİR/GİDER DAĞILIMI',
            style: TextStyle(
              color: Color(0xFF002045),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in visibleItems) ...[
            _DistributionLine(item: item),
            if (item != visibleItems.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DistributionLine extends StatelessWidget {
  const _DistributionLine({required this.item});

  final DistributionItemMock item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Color(0xFF43474E),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              item.valueLabel,
              style: const TextStyle(
                color: Color(0xFF191C1D),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: item.progress,
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          color: item.color,
          backgroundColor: const Color(0xFFEDEEEF),
        ),
      ],
    );
  }
}
