import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/status_badge.dart';
import '../finance_mock_data.dart';

class KdvSummaryCard extends StatelessWidget {
  const KdvSummaryCard({required this.summary, this.onDetails, super.key});

  final KdvSummaryMock summary;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          _Header(summary: summary),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _VatMetric(
                        label: 'Hesaplanan KDV',
                        value: summary.calculatedVat,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: AppColors.outline,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _VatMetric(
                          label: 'İndirilecek KDV',
                          value: summary.deductibleVat,
                          valueColor: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.outlineSoft),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _VatMetric(
                        label: 'Ödenecek Tahmini',
                        value: summary.payableVat,
                        large: true,
                      ),
                    ),
                    FilledButton(
                      onPressed: onDetails ?? () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Detaylar'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _warningText(summary.warning),
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            height: 1.35,
                            fontStyle: FontStyle.italic,
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

  String _warningText(String warning) {
    if (warning.contains('KDV')) {
      return 'KDV dengeniz son girilen faturalarla riskli bir seviyede. Girdi faturalarınızı kontrol edin.';
    }

    return warning;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary});

  final KdvSummaryMock summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.outlineSoft)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'KDV BEYANNAMESİ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                StatusBadge(label: 'TAKİP GEREKLİ', tone: StatusTone.danger),
              ],
            ),
          ),
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _VatMetric extends StatelessWidget {
  const _VatMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.large = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.onSurface,
            fontSize: large ? 18 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
