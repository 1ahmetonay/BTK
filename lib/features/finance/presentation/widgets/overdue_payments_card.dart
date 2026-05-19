import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/status_badge.dart';
import '../finance_mock_data.dart';

class OverduePaymentsCard extends StatelessWidget {
  const OverduePaymentsCard({
    required this.payments,
    required this.onDraftReminder,
    super.key,
  });

  final List<OverduePaymentMock> payments;
  final ValueChanged<OverduePaymentMock> onDraftReminder;

  @override
  Widget build(BuildContext context) {
    final maxDelay = payments
        .map((payment) => int.tryParse(payment.delay.split(' ').first) ?? 0)
        .fold<int>(0, (max, delay) => delay > max ? delay : max);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          _Header(count: payments.length, maxDelay: maxDelay),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.outlineSoft),
            itemBuilder: (context, index) => _PaymentRow(
              payment: payments[index],
              onReminder: () => onDraftReminder(payments[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: payments.isEmpty
                    ? null
                    : () => onDraftReminder(
                        OverduePaymentMock(
                          customerName: 'Vadesi geçen tahsilatlar',
                          amount: '${payments.length} tahsilat',
                          delay: '$maxDelay gün gecikti',
                          actionLabel: 'Hatırlatma öner',
                        ),
                      ),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Hatırlatma Taslağı Oluştur'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.maxDelay});

  final int count;
  final int maxDelay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineSoft)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'VADESİ GEÇEN TAHSİLATLAR',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
          StatusBadge(
            label: count == 0 ? 'TEMİZ' : '$maxDelay GÜN GECİKME',
            tone: count == 0 ? StatusTone.success : StatusTone.warning,
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.onReminder});

  final OverduePaymentMock payment;
  final VoidCallback onReminder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryDark,
            child: Text(
              _initials(payment.customerName),
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${payment.amount} • ${payment.delay}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: onReminder,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Hatırlat'),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length < 2) {
      return name.characters.take(2).toString().toUpperCase();
    }

    return '${parts.first.characters.first}${parts[1].characters.first}'
        .toUpperCase();
  }
}
