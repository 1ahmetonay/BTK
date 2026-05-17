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
        border: Border.all(color: const Color(0xFFC4C6CF)),
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
                      color: const Color(0xFFC4C6CF),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _VatMetric(
                          label: 'İndirilecek KDV',
                          value: summary.deductibleVat,
                          valueColor: const Color(0xFF2C694E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE1E3E4)),
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
                        backgroundColor: const Color(0xFF002045),
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
                    color: const Color(0xFFE7E8E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        color: Color(0xFFBA1A1A),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _warningText(summary.warning),
                          style: const TextStyle(
                            color: Color(0xFF43474E),
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
        color: Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xFFE1E3E4))),
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
                    color: Color(0xFF002045),
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
            color: Color(0xFF002045),
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
          style: const TextStyle(color: Color(0xFF43474E), fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF191C1D),
            fontSize: large ? 18 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
