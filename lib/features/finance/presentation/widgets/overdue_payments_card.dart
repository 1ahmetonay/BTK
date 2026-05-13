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
  final ValueChanged<String> onDraftReminder;

  @override
  Widget build(BuildContext context) {
    final visiblePayments = payments.take(2).toList();

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
            itemCount: visiblePayments.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFE1E3E4)),
            itemBuilder: (context, index) => _PaymentRow(
              payment: visiblePayments[index],
              onReminder: () =>
                  onDraftReminder(visiblePayments[index].customerName),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: () => onDraftReminder('Vadesi geçen tahsilatlar'),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Hatırlatma Taslağı Oluştur'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2C694E),
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
              'VADESİ GEÇEN TAHSİLATLAR',
              style: TextStyle(
                color: Color(0xFF002045),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
          StatusBadge(label: '6 GÜN GECİKME', tone: StatusTone.warning),
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
            backgroundColor: const Color(0xFF1A365D),
            child: Text(
              _initials(payment.customerName),
              style: const TextStyle(
                color: Color(0xFFADC7F7),
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
                    color: Color(0xFF191C1D),
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
                    color: Color(0xFF43474E),
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
              foregroundColor: const Color(0xFF2C694E),
              side: const BorderSide(color: Color(0xFF2C694E)),
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
