import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../stock_mock_data.dart';

class SupplierComparisonCard extends StatelessWidget {
  const SupplierComparisonCard({
    required this.productName,
    required this.suppliers,
    required this.aiInsight,
    super.key,
  });

  final String productName;
  final List<SupplierComparisonMock> suppliers;
  final String aiInsight;

  @override
  Widget build(BuildContext context) {
    if (suppliers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(productName.isNotEmpty
              ? 'Tedarikçi Karşılaştırması: $productName'
              : 'Tedarikçi Karşılaştırması'),
          const SizedBox(height: 8),
          const EmptyState(
            icon: Icons.compare_arrows_outlined,
            title: 'Tedarikçi verisi bulunamadı',
            description: 'Kritik stok ürünü bulunduğunda tedarikçi karşılaştırması burada görünecektir.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Tedarikçi Karşılaştırması: $productName'),
        const SizedBox(height: 8),
        for (var index = 0; index < suppliers.length; index++) ...[
          _SupplierTile(supplier: suppliers[index], cheapest: index == 1),
          const SizedBox(height: 8),
        ],
        if (aiInsight.isNotEmpty) _SupplierAiComment(text: aiInsight),
      ],
    );
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({required this.supplier, required this.cheapest});

  final SupplierComparisonMock supplier;
  final bool cheapest;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cheapest ? AppColors.successSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cheapest ? AppColors.secondaryLight : AppColors.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      supplier.supplierName,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (cheapest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'EN UCUZ',
                          style: TextStyle(
                            color: AppColors.onSecondaryContainer,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Teslimat: ${supplier.leadTime}',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            supplier.price,
            style: TextStyle(
              color: cheapest
                  ? AppColors.onSecondaryContainer
                  : AppColors.primary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierAiComment extends StatelessWidget {
  const _SupplierAiComment({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 16),
              SizedBox(width: 6),
              Text(
                'AI YORUMU',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _compactInsight(text),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _compactInsight(String value) {
    if (value.contains('Marmara') && value.contains('Ege')) {
      return 'Maliyet odaklı Marmara Gıda en iyi seçenek ancak acil ihtiyaç varsa Ege Kahve Deposu tercih edilmeli.';
    }

    return value;
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
        letterSpacing: 0.9,
        height: 1.25,
      ),
    );
  }
}
