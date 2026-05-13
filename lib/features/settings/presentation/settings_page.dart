import 'package:flutter/material.dart';

import 'settings_mock_data.dart';
import 'widgets/ai_settings_card.dart';
import 'widgets/business_profile_card.dart';
import 'widgets/document_processing_settings_card.dart';
import 'widgets/integration_status_card.dart';
import 'widgets/security_data_card.dart';
import 'widgets/settings_side_panel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AiMode _aiMode = AiMode.proactive;
  int _confidenceThreshold = 90;

  final Map<String, bool> _aiSettings = {
    'Sabah brifingi aktif': true,
    'Kritik stok önerileri aktif': true,
    'Nakit akışı risk uyarıları aktif': true,
    'KDV son tarih uyarıları aktif': true,
    'Puantaj kontrol önerileri aktif': true,
    'Tedarikçi karşılaştırma önerileri aktif': true,
  };

  final Map<String, bool> _documentSettings = {
    'Düşük güven skorlu belgeleri otomatik kontrol listesine al': true,
    'Fatura işlenince stokları otomatik güncelle': true,
    'Satış faturasında stok düşümü yap': true,
    'KDV kayıtlarını otomatik oluştur': true,
    'Puantaj belgesi işlenince finans modülüne personel gideri hazırla': true,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SettingsIntroCard(),
        const SizedBox(height: 16),
        Column(children: _mainCards()),
      ],
    );
  }

  List<Widget> _mainCards() {
    return [
      BusinessProfileCard(
        profile: SettingsMockData.profile,
        onSave: () => _showMessage('İşletme profili demo modunda kaydedildi.'),
      ),
      const SizedBox(height: 16),
      AiSettingsCard(
        values: _aiSettings,
        mode: _aiMode,
        onToggle: _toggleAiSetting,
        onModeChanged: (mode) {
          setState(() {
            _aiMode = mode;
          });
        },
      ),
      const SizedBox(height: 16),
      DocumentProcessingSettingsCard(
        values: _documentSettings,
        confidenceThreshold: _confidenceThreshold,
        onToggle: _toggleDocumentSetting,
        onThresholdChanged: (value) {
          setState(() {
            _confidenceThreshold = value;
          });
        },
      ),
      const SizedBox(height: 16),
      const IntegrationStatusCard(items: SettingsMockData.integrations),
      const SizedBox(height: 16),
      SecurityDataCard(
        notes: SettingsMockData.securityNotes,
        onResetDemoData: () =>
            _showMessage('Demo verileri sıfırlama işlemi simüle edildi.'),
        onCheckSystem: () => _showMessage('Tüm demo modülleri çalışıyor.'),
      ),
      const SizedBox(height: 16),
      const SettingsSidePanel(
        activeModules: SettingsMockData.activeModules,
        activities: SettingsMockData.recentActivities,
        checklist: SettingsMockData.setupChecklist,
      ),
    ];
  }

  void _toggleAiSetting(String key, bool value) {
    setState(() {
      _aiSettings[key] = value;
    });
  }

  void _toggleDocumentSetting(String key, bool value) {
    setState(() {
      _documentSettings[key] = value;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsIntroCard extends StatelessWidget {
  const _SettingsIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF002045), width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ayarlar',
              style: TextStyle(
                color: Color(0xFF002045),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İşletme, AI asistan ve bildirim tercihlerinizi yönetin.',
              style: TextStyle(
                color: Color(0xFF43474E),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E8E9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFC4C6CF)),
              ),
              child: const Text(
                'Demo modunda ayarlar local olarak gösterilir. Gerçekleşen değişiklikler geçicidir.',
                style: TextStyle(
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
    );
  }
}
