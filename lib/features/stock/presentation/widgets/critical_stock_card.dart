import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../stock_mock_data.dart';

class CriticalStockCard extends StatelessWidget {
  const CriticalStockCard({
    required this.products,
    required this.onRecommend,
    super.key,
  });

  final List<ProductStockMock> products;
  final ValueChanged<String> onRecommend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Kritik Stoklar'),
        const SizedBox(height: 8),
        for (final product in products) ...[
          _CriticalProductCard(
            product: product,
            onRecommend: () => onRecommend(product.productName),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CriticalProductCard extends StatelessWidget {
  const _CriticalProductCard({
    required this.product,
    required this.onRecommend,
  });

  final ProductStockMock product;
  final VoidCallback onRecommend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.currentStock} adet / Min ${product.minimumStock}',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _CompactStatusBadge(
                label: product.statusLabel,
                tone: product.statusTone,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton(
              onPressed: onRecommend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Tedarik Öner'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatusBadge extends StatelessWidget {
  const _CompactStatusBadge({required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.82,
      alignment: Alignment.topRight,
      child: StatusBadge(label: label.toUpperCase(), tone: tone),
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
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}
