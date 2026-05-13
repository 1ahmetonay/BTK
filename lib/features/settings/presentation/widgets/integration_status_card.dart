import 'package:flutter/material.dart';

import '../../../../shared/widgets/status_badge.dart';
import '../settings_mock_data.dart';

class IntegrationStatusCard extends StatelessWidget {
  const IntegrationStatusCard({required this.items, super.key});

  final List<IntegrationStatusMock> items;

  @override
  Widget build(BuildContext context) {
    final visible = [
      items.firstWhere((item) => item.name == 'Gemini Vision'),
      items.firstWhere((item) => item.name == 'FastAPI Backend'),
      items.firstWhere((item) => item.name == 'E-Fatura XML'),
    ];

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demo Entegrasyon Durumu',
            style: TextStyle(
              color: Color(0xFF191C1D),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in visible) ...[
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontSize: 14)),
                ),
                StatusBadge(label: _label(item.status), tone: item.status.tone),
              ],
            ),
            if (item != visible.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  String _label(IntegrationStatusType status) {
    return switch (status) {
      IntegrationStatusType.demo => 'DEMO MODUNDA',
      IntegrationStatusType.waiting => 'BEKLİYOR',
      IntegrationStatusType.planned => 'PLANLANDI',
      IntegrationStatusType.mockProduction => 'MOCK ÜRETİM',
    };
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: child,
    );
  }
}
