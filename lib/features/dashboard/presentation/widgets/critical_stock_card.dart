import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../dashboard_mock_data.dart';

class CriticalStockCard extends StatelessWidget {
  const CriticalStockCard({required this.products, super.key});

  final List<StockAlertData> products;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Kritik Stok',
      subtitle: 'Stok eşiği altına inen ürünler',
      child: products.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Kritik stok ürünü yok',
              description: 'Tüm ürünleriniz güvenli stok seviyesinde.',
            )
          : Column(
              children: [
                for (final product in products)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: product.statusTone == StatusTone.danger
                                ? AppColors.errorSurface
                                : AppColors.warningContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: product.statusTone == StatusTone.danger
                                ? AppColors.rose
                                : AppColors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                product.quantity,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: product.statusLabel,
                          tone: product.statusTone,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
