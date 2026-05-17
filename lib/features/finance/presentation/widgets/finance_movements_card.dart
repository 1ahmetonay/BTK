import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../finance_mock_data.dart';

class FinanceMovementsCard extends StatelessWidget {
  const FinanceMovementsCard({required this.movements, this.onShowAll, super.key});

  final List<FinanceMovementMock> movements;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Column(
        children: [
          const _Header(),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movements.take(3).length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFE1E3E4)),
            itemBuilder: (context, index) =>
                _MovementRow(movement: movements[index], index: index),
          ),
          TextButton(
            onPressed: onShowAll ?? () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF002045),
              minimumSize: const Size.fromHeight(46),
            ),
            child: const Text('Tümünü Gör'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE1E3E4))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'SON HAREKETLER',
              style: TextStyle(
                color: Color(0xFF002045),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Icon(Icons.history, color: Color(0xFF002045), size: 18),
        ],
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement, required this.index});

  final FinanceMovementMock movement;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(movement.tone);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: movement.tone == StatusTone.success
                  ? const Color(0xFFEFF8F3)
                  : const Color(0xFFEDEEEF),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF43474E),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _amount,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    return switch (index) {
      0 => 'Stok Alımı',
      1 => 'Z-Raporu Tahsilatı',
      2 => 'Personel Ödemesi',
      _ => movement.title,
    };
  }

  String get _source {
    return switch (index) {
      0 => 'Toptan Kahve Çekirdeği',
      1 => '12 Aralık Toplamı',
      2 => 'Murat Ç. Maaş',
      _ => movement.source,
    };
  }

  String get _amount {
    return switch (index) {
      0 => '- 4.250 TL',
      1 => '+ 12.840 TL',
      2 => '- 18.500 TL',
      _ => movement.amount,
    };
  }

  IconData get _icon {
    return switch (index) {
      0 => Icons.shopping_cart_outlined,
      1 => Icons.point_of_sale_outlined,
      2 => Icons.badge_outlined,
      _ => Icons.receipt_long_outlined,
    };
  }

  Color get _iconColor {
    return index == 1 ? const Color(0xFF2C694E) : const Color(0xFF002045);
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
