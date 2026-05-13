import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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
        _PriorityDistributionCard(items: priorityDistribution),
        const SizedBox(height: 16),
        _CategoryDistributionCard(items: categoryDistribution),
        const SizedBox(height: 16),
        const _PendingApprovalsCard(),
      ],
    );
  }
}

class _PriorityDistributionCard extends StatelessWidget {
  const _PriorityDistributionCard({required this.items});

  final List<AlertDistributionMock> items;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle('Öncelik Dağılımı'),
          const SizedBox(height: 16),
          for (final item in items) ...[
            _PriorityRow(item: item),
            if (item != items.last) const SizedBox(height: 11),
          ],
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({required this.item});

  final AlertDistributionMock item;

  @override
  Widget build(BuildContext context) {
    final value = int.tryParse(item.value) ?? 1;
    final progress = (value / 12).clamp(0.08, 1.0);
    final color = _colorFor(item.tone);

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            item.label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF43474E)),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            borderRadius: BorderRadius.circular(999),
            color: color,
            backgroundColor: const Color(0xFFEDEEEF),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          item.value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Color _colorFor(StatusTone tone) {
    return switch (tone) {
      StatusTone.danger => const Color(0xFFBA1A1A),
      StatusTone.warning => const Color(0xFF002045),
      StatusTone.success => const Color(0xFF2C694E),
      StatusTone.info => const Color(0xFF74777F),
      StatusTone.neutral => const Color(0xFF74777F),
    };
  }
}

class _CategoryDistributionCard extends StatelessWidget {
  const _CategoryDistributionCard({required this.items});

  final List<AlertDistributionMock> items;

  @override
  Widget build(BuildContext context) {
    final visible = [
      const AlertDistributionMock(
        label: 'Stok',
        value: '4',
        tone: StatusTone.info,
      ),
      const AlertDistributionMock(
        label: 'Finans',
        value: '3',
        tone: StatusTone.success,
      ),
      const AlertDistributionMock(
        label: 'KDV / Belge',
        value: '3',
        tone: StatusTone.warning,
      ),
      const AlertDistributionMock(
        label: 'Puantaj / İK',
        value: '2',
        tone: StatusTone.neutral,
      ),
    ];

    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle('Kategori Dağılımı'),
          const SizedBox(height: 12),
          for (final item in visible) ...[
            _CategoryRow(item: item),
            if (item != visible.last)
              const Divider(height: 12, color: Color(0xFFE1E3E4)),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item});

  final AlertDistributionMock item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_iconFor(item.label), color: const Color(0xFF002045), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF191C1D)),
          ),
        ),
        Text(
          item.value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  IconData _iconFor(String label) {
    if (label.startsWith('Stok')) {
      return Icons.inventory_2_outlined;
    }
    if (label.startsWith('Finans')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (label.startsWith('KDV')) {
      return Icons.description_outlined;
    }
    return Icons.badge_outlined;
  }
}

class _PendingApprovalsCard extends StatelessWidget {
  const _PendingApprovalsCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Tedarik önerisi', 'HİZMET ALIMI'),
      ('Ödeme hatırlatma', 'FİNANS'),
      ('Puantaj kontrolü', 'İK'),
    ];

    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle('Bekleyen Onaylar'),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: Color(0xFF191C1D),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: Color(0xFF43474E),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusBadge(
                  label: 'Onay bekliyor',
                  tone: StatusTone.info,
                ),
              ],
            ),
            if (item != items.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
