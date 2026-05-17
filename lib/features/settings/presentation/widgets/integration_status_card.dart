import 'package:flutter/material.dart';

import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/status_badge.dart';

class IntegrationStatusCard extends StatefulWidget {
  const IntegrationStatusCard({super.key});

  @override
  State<IntegrationStatusCard> createState() => _IntegrationStatusCardState();
}

class _IntegrationStatusCardState extends State<IntegrationStatusCard> {
  bool _backendConnected = false;
  bool _geminiAvailable = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkIntegrations();
  }

  Future<void> _checkIntegrations() async {
    try {
      final backendOk = await ApiService.instance.isBackendAvailable();
      bool geminiOk = false;
      if (backendOk) {
        try {
          // Gemini'yi test etmek için health check yeterli
          // Gemini API key .env'de varsa backend çalışır
          final health = await ApiService.instance.getDashboardSummary();
          geminiOk = health.isNotEmpty;
        } catch (_) {
          geminiOk = false;
        }
      }
      if (mounted) {
        setState(() {
          _backendConnected = backendOk;
          _geminiAvailable = geminiOk;
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _IntegrationItem(
        name: 'Gemini Vision',
        connected: _geminiAvailable,
        checking: _checking,
        activeLabel: 'AKTİF',
        inactiveLabel: 'BAĞLANAMADI',
      ),
      _IntegrationItem(
        name: 'FastAPI Backend',
        connected: _backendConnected,
        checking: _checking,
        activeLabel: 'BAĞLI',
        inactiveLabel: 'BAĞLANAMADI',
      ),
      _IntegrationItem(
        name: 'E-Fatura XML',
        connected: _backendConnected,
        checking: _checking,
        activeLabel: 'HAZIR',
        inactiveLabel: 'BEKLİYOR',
      ),
    ];

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Entegrasyon Durumu',
            style: TextStyle(
              color: Color(0xFF191C1D),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _IntegrationItem extends StatelessWidget {
  const _IntegrationItem({
    required this.name,
    required this.connected,
    required this.checking,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  final String name;
  final bool connected;
  final bool checking;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(name, style: const TextStyle(fontSize: 14)),
        ),
        if (checking)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          StatusBadge(
            label: connected ? activeLabel : inactiveLabel,
            tone: connected ? StatusTone.success : StatusTone.warning,
          ),
      ],
    );
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
