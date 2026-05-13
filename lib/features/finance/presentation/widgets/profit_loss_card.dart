import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../finance_mock_data.dart';

class ProfitLossCard extends StatelessWidget {
  const ProfitLossCard({
    required this.items,
    required this.margin,
    required this.aiInsight,
    super.key,
  });

  final List<ProfitLossItemMock> items;
  final double margin;
  final String aiInsight;

  @override
  Widget build(BuildContext context) {
    final visibleItems = [
      ProfitLossItemMock(
        label: 'Brüt Satış',
        value: _valueFor('Brüt satış'),
        tone: StatusTone.info,
      ),
      const ProfitLossItemMock(
        label: 'Ürün Maliyeti',
        value: '- 142.000 TL',
        tone: StatusTone.danger,
      ),
      const ProfitLossItemMock(
        label: 'Operasyonel Giderler',
        value: '- 74.300 TL',
        tone: StatusTone.danger,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Column(
        children: [
          const _CardHeader(title: 'Kâr/Zarar Analizi', icon: Icons.analytics),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var index = 0; index < visibleItems.length; index++) ...[
                  _ProfitLine(
                    item: visibleItems[index],
                    progress: index == 0
                        ? 1
                        : index == 1
                        ? 0.50
                        : 0.26,
                  ),
                  if (index != visibleItems.length - 1)
                    const SizedBox(height: 14),
                ],
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF8F3),
                    border: Border(
                      left: BorderSide(color: Color(0xFF2C694E), width: 4),
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.smart_toy_outlined,
                        color: Color(0xFF2C694E),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          aiInsight,
                          style: const TextStyle(
                            color: Color(0xFF0E5138),
                            fontSize: 12,
                            height: 1.45,
                          ),
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

  String _valueFor(String label) {
    return items
        .firstWhere((item) => item.label == label, orElse: () => items.first)
        .value;
  }
}

class _ProfitLine extends StatelessWidget {
  const _ProfitLine({required this.item, required this.progress});

  final ProfitLossItemMock item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(item.tone);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(color: Color(0xFF43474E), fontSize: 13),
              ),
            ),
            Text(
              item.value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          color: color,
          backgroundColor: const Color(0xFFEDEEEF),
        ),
      ],
    );
  }

  Color _colorFor(StatusTone tone) {
    return switch (tone) {
      StatusTone.success => const Color(0xFF2C694E),
      StatusTone.warning => AppColors.amber,
      StatusTone.danger => const Color(0xFFBA1A1A),
      StatusTone.info => const Color(0xFF002045),
      StatusTone.neutral => AppColors.muted,
    };
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xFFE1E3E4))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF002045),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Icon(icon, color: const Color(0xFF002045), size: 18),
        ],
      ),
    );
  }
}
