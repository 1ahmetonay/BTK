import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../stock_mock_data.dart';

class StockMovementsCard extends StatelessWidget {
  const StockMovementsCard({required this.movements, super.key});

  final List<StockMovementMock> movements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Son Stok Hareketleri'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC4C6CF)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movements.take(2).length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFE1E3E4)),
            itemBuilder: (context, index) {
              return _MovementRow(movement: movements[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});

  final StockMovementMock movement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _MovementIcon(tone: movement.tone),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${movement.timestamp} • ${_shortTitle(movement.title)}',
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
          const SizedBox(width: 12),
          Text(
            _quantity(movement.quantityChange),
            style: TextStyle(
              color: _colorFor(movement.tone),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static String _shortTitle(String title) {
    if (title.contains('Satın alma')) {
      return 'Tedarik Girişi';
    }
    if (title.contains('Satış')) {
      return 'Online Satış';
    }
    return title;
  }

  static String _quantity(String quantity) {
    return quantity.replaceAll(' adet', '');
  }

  Color _colorFor(StatusTone tone) {
    return switch (tone) {
      StatusTone.success => AppColors.emerald,
      StatusTone.warning => AppColors.amber,
      StatusTone.danger => AppColors.rose,
      StatusTone.info => AppColors.primary,
      StatusTone.neutral => AppColors.muted,
    };
  }
}

class _MovementIcon extends StatelessWidget {
  const _MovementIcon({required this.tone});

  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      StatusTone.success => AppColors.emerald,
      StatusTone.warning => AppColors.amber,
      StatusTone.danger => AppColors.rose,
      StatusTone.info => AppColors.primary,
      StatusTone.neutral => AppColors.muted,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        tone == StatusTone.success ? Icons.add : Icons.remove,
        color: color,
        size: 20,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF002045),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}
