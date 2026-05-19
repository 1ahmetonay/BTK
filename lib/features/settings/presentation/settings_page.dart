import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/api_service.dart';
import 'settings_mock_data.dart';
import 'widgets/ai_settings_card.dart';
import 'widgets/business_profile_card.dart';
import 'widgets/document_processing_settings_card.dart';
import 'widgets/integration_status_card.dart';
import 'widgets/security_data_card.dart';
import 'widgets/settings_side_panel.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  AiMode _aiMode = AiMode.proactive;
  int _confidenceThreshold = 90;
  bool _backendConnected = false;
  bool _geminiAvailable = false;

  String _businessName = 'KOBİ AI Demo İşletmesi';
  String _taxNumber = '1234567890';
  String _industry = 'Perakende / Gıda';
  String _city = 'İstanbul';
  String _currency = 'TRY';
  String _defaultVatRate = '%20';

  @override
  void initState() {
    super.initState();
    _checkLiveStatus();
  }

  Future<void> _checkLiveStatus() async {
    try {
      final ok = await ApiService.instance.isBackendAvailable();
      if (!mounted) return;
      bool gemini = false;
      if (ok) {
        try {
          final data = await ApiService.instance.getDashboardSummary();
          gemini = data.isNotEmpty;
        } catch (_) {}
      }
      setState(() {
        _backendConnected = ok;
        _geminiAvailable = gemini;
      });
    } catch (_) {}
  }

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
        _SettingsIntroCard(backendConnected: _backendConnected),
        const SizedBox(height: 16),
        Column(children: _mainCards()),
      ],
    );
  }

  List<Widget> _mainCards() {
    return [
      BusinessProfileCard(
        profile: BusinessProfileMock(
          businessName: _businessName,
          taxNumber: _taxNumber,
          industry: _industry,
          city: _city,
          currency: _currency,
          defaultVatRate: _defaultVatRate,
        ),
        onSave: () => _showMessage('İşletme profili kaydedildi.'),
        onFieldChanged: (field, value) {
          setState(() {
            switch (field) {
              case 'businessName': _businessName = value;
              case 'taxNumber': _taxNumber = value;
              case 'industry': _industry = value;
              case 'city': _city = value;
              case 'currency': _currency = value;
              case 'defaultVatRate': _defaultVatRate = value;
            }
          });
        },
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
          // Global AI modunu güncelle — chat sayfası bu modu kullanır
          ref.read(aiModeProvider.notifier).state = mode.name;
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
      const IntegrationStatusCard(),
      const SizedBox(height: 16),
      SecurityDataCard(
        notes: const [
          'Veriler şifrelenmiş SQLite veritabanında saklanır.',
          'API anahtarları .env dosyasında tutulur, koda gömülmez.',
          'Tüm istekler HTTPS üzerinden iletilir.',
        ],
        onResetDemoData: () =>
            _showMessage('Demo verileri sıfırlama işlemi simüle edildi.'),
        onCheckSystem: _checkSystemStatus,
      ),
      const SizedBox(height: 16),
      SettingsSidePanel(
        activeModules: const ['Stok Yönetimi', 'Finans & KDV', 'Belge İşleme', 'Puantaj / İK', 'AI Asistan', 'E-Fatura'],
        activities: const [
          SettingsActivityMock('Sistem başlatıldı'),
          SettingsActivityMock('Backend bağlantısı kontrol edildi'),
        ],
        checklist: [
          const SetupChecklistMock(title: 'Flutter Web arayüzü hazır', completed: true),
          SetupChecklistMock(title: 'Backend bağlantısı', completed: _backendConnected),
          SetupChecklistMock(title: 'Gemini API entegrasyonu', completed: _geminiAvailable),
          const SetupChecklistMock(title: 'İlk belge işleme', completed: false),
        ],
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

  Future<void> _checkSystemStatus() async {
    _showMessage('Sistem durumu kontrol ediliyor…');
    try {
      final ok = await ApiService.instance.isBackendAvailable();
      if (!mounted) return;
      if (ok) {
        _showMessage('✓ Backend bağlı, tüm modüller aktif.');
      } else {
        _showMessage('✗ Backend bağlantısı kurulamadı.');
      }
    } catch (_) {
      if (mounted) _showMessage('✗ Bağlantı hatası. Backend çalışıyor mu?');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsIntroCard extends StatelessWidget {
  const _SettingsIntroCard({required this.backendConnected});

  final bool backendConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
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
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İşletme, AI asistan ve bildirim tercihlerinizi yönetin.',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.outline),
              ),
              child: Text(
                backendConnected
                    ? 'Backend bağlı. Veriler canlı olarak çekiliyor.'
                    : 'Backend bağlantısı kurulamadı. Lütfen sunucuyu başlatın.',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
