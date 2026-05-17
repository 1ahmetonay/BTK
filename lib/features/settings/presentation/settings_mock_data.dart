import 'package:flutter/material.dart';

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
