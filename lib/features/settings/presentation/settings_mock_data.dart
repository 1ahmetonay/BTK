import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';

enum AiMode { balanced, careful, proactive }

enum IntegrationStatusType { demo, waiting, planned, mockProduction }

extension AiModeView on AiMode {
  String get label {
    return switch (this) {
      AiMode.balanced => 'Dengeli',
      AiMode.careful => 'Daha dikkatli',
      AiMode.proactive => 'Daha proaktif',
    };
  }
}

extension IntegrationStatusTypeView on IntegrationStatusType {
  String get label {
    return switch (this) {
      IntegrationStatusType.demo => 'Demo modunda',
      IntegrationStatusType.waiting => 'Bağlantı bekliyor',
      IntegrationStatusType.planned => 'Planlandı',
      IntegrationStatusType.mockProduction => 'Mock üretim',
    };
  }

  StatusTone get tone {
    return switch (this) {
      IntegrationStatusType.demo => StatusTone.info,
      IntegrationStatusType.waiting => StatusTone.warning,
      IntegrationStatusType.planned => StatusTone.neutral,
      IntegrationStatusType.mockProduction => StatusTone.success,
    };
  }
}

class BusinessProfileMock {
  const BusinessProfileMock({
    required this.businessName,
    required this.taxNumber,
    required this.industry,
    required this.city,
    required this.currency,
    required this.defaultVatRate,
  });

  final String businessName;
  final String taxNumber;
  final String industry;
  final String city;
  final String currency;
  final String defaultVatRate;
}

class IntegrationStatusMock {
  const IntegrationStatusMock({
    required this.name,
    required this.status,
    required this.icon,
  });

  final String name;
  final IntegrationStatusType status;
  final IconData icon;
}

class SettingsActivityMock {
  const SettingsActivityMock(this.title);

  final String title;
}

class SetupChecklistMock {
  const SetupChecklistMock({
    required this.title,
    required this.completed,
  });

  final String title;
  final bool completed;
}

class SettingsMockData {
  const SettingsMockData._();

  static const profile = BusinessProfileMock(
    businessName: 'KOBİ Demo Mağaza',
    taxNumber: '1234567890',
    industry: 'E-Ticaret / Gıda',
    city: 'Erzurum',
    currency: 'TRY',
    defaultVatRate: '%20',
  );

  static const integrations = [
    IntegrationStatusMock(
      name: 'Gemini Vision',
      status: IntegrationStatusType.demo,
      icon: Icons.auto_awesome_outlined,
    ),
    IntegrationStatusMock(
      name: 'FastAPI Backend',
      status: IntegrationStatusType.waiting,
      icon: Icons.api_outlined,
    ),
    IntegrationStatusMock(
      name: 'SQLite Veritabanı',
      status: IntegrationStatusType.planned,
      icon: Icons.storage_outlined,
    ),
    IntegrationStatusMock(
      name: 'E-Fatura XML',
      status: IntegrationStatusType.mockProduction,
      icon: Icons.receipt_long_outlined,
    ),
    IntegrationStatusMock(
      name: 'Bildirim Servisi',
      status: IntegrationStatusType.demo,
      icon: Icons.notifications_active_outlined,
    ),
    IntegrationStatusMock(
      name: 'Trendyol / Pazaryeri',
      status: IntegrationStatusType.mockProduction,
      icon: Icons.storefront_outlined,
    ),
  ];

  static const activeModules = [
    'Dashboard',
    'Belge İşleme',
    'Stok',
    'Finans',
    'AI Asistan',
    'Uyarılar',
    'Puantaj',
  ];

  static const recentActivities = [
    SettingsActivityMock('AI modu daha proaktif olarak ayarlandı'),
    SettingsActivityMock('Güven skoru eşiği %90 seçildi'),
    SettingsActivityMock('Sabah brifingi 09:00 olarak ayarlandı'),
  ];

  static const setupChecklist = [
    SetupChecklistMock(title: 'Flutter Web arayüzü hazır', completed: true),
    SetupChecklistMock(title: 'Mock veri ekranları hazır', completed: true),
    SetupChecklistMock(title: 'Backend bağlantısı bekliyor', completed: false),
    SetupChecklistMock(title: 'Gemini API entegrasyonu bekliyor', completed: false),
  ];

  static const securityNotes = [
    'Veriler demo modunda local mock data ile gösteriliyor.',
    'Gerçek müşteri verisi kullanılmıyor.',
    'Gemini entegrasyonu eklendiğinde belge analizleri backend üzerinden yapılacak.',
    'Üretim ortamında PostgreSQL ve kullanıcı bazlı yetkilendirme önerilir.',
  ];

  static const moduleIconColor = AppColors.primary;
}
