import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../employees_mock_data.dart';

class SalarySummaryCard extends StatelessWidget {
  const SalarySummaryCard({
    required this.summary,
    super.key,
  });

  final SalarySummaryMock summary;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Maaş ve Mesai Etkisi',
      subtitle: 'Puantaj onaylandığında oluşacak finans etkisi',
      child: Column(
        children: [
          _SalaryRow(label: 'Baz maaş toplamı', value: summary.baseSalaryTotal),
          _SalaryRow(label: 'Mesai ek ödemesi', value: summary.overtimePayment),
          _SalaryRow(label: 'Kesinti/izin etkisi', value: summary.deductionEffect),
          _SalaryRow(
            label: 'Tahmini toplam personel gideri',
            value: summary.totalPersonnelCost,
            valueColor: AppColors.rose,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.infoBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    summary.aiComment,
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
