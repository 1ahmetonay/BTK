import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';

enum AlertCategory { stock, finance, kdv, employees, document }

enum AlertPriority { critical, high, medium, low }

enum AlertStatus { active, resolved, ignored }

enum AlertFilter { all, critical, stock, finance, kdv, employees, document, resolved }

extension AlertCategoryView on AlertCategory {
  String get label {
    return switch (this) {
      AlertCategory.stock => 'Stok',
      AlertCategory.finance => 'Finans',
      AlertCategory.kdv => 'KDV',
      AlertCategory.employees => 'Puantaj',
      AlertCategory.document => 'Belge',
    };
  }

  IconData get icon {
    return switch (this) {
      AlertCategory.stock => Icons.inventory_2_outlined,
      AlertCategory.finance => Icons.account_balance_wallet_outlined,
      AlertCategory.kdv => Icons.receipt_long_outlined,
      AlertCategory.employees => Icons.groups_2_outlined,
      AlertCategory.document => Icons.description_outlined,
    };
  }

  StatusTone get tone {
    return switch (this) {
      AlertCategory.stock => StatusTone.info,
      AlertCategory.finance => StatusTone.success,
      AlertCategory.kdv => StatusTone.warning,
      AlertCategory.employees => StatusTone.neutral,
      AlertCategory.document => StatusTone.info,
    };
  }
}

extension AlertPriorityView on AlertPriority {
  String get label {
    return switch (this) {
      AlertPriority.critical => 'Kritik',
      AlertPriority.high => 'Yüksek',
      AlertPriority.medium => 'Orta',
      AlertPriority.low => 'Düşük',
    };
  }

  StatusTone get tone {
    return switch (this) {
      AlertPriority.critical => StatusTone.danger,
      AlertPriority.high => StatusTone.warning,
      AlertPriority.medium => StatusTone.warning,
      AlertPriority.low => StatusTone.info,
    };
  }

  Color get color {
    return switch (this) {
      AlertPriority.critical => AppColors.rose,
      AlertPriority.high => AppColors.amber,
      AlertPriority.medium => const Color(0xFFEAB308),
      AlertPriority.low => AppColors.primary,
    };
  }
}

extension AlertFilterView on AlertFilter {
  String get label {
    return switch (this) {
      AlertFilter.all => 'Tümü',
      AlertFilter.critical => 'Kritik',
      AlertFilter.stock => 'Stok',
      AlertFilter.finance => 'Finans',
      AlertFilter.kdv => 'KDV',
      AlertFilter.employees => 'Puantaj',
      AlertFilter.document => 'Belge',
      AlertFilter.resolved => 'Çözüldü',
    };
  }
}

class AlertSummaryMock {
  const AlertSummaryMock({
    required this.title,
    required this.value,
    required this.description,
    required this.trend,
    required this.trendTone,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String description;
  final String trend;
  final StatusTone trendTone;
  final IconData icon;
  final Color accentColor;
}

class AlertDistributionMock {
  const AlertDistributionMock({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final StatusTone tone;
}

class AlertMock {
  const AlertMock({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.description,
    required this.recommendedAction,
    required this.timeLabel,
    this.status = AlertStatus.active,
  });

  final String id;
  final String title;
  final AlertCategory category;
  final AlertPriority priority;
  final String description;
  final String recommendedAction;
  final String timeLabel;
  final AlertStatus status;

  AlertMock copyWith({
    AlertStatus? status,
  }) {
    return AlertMock(
      id: id,
      title: title,
      category: category,
      priority: priority,
      description: description,
      recommendedAction: recommendedAction,
      timeLabel: timeLabel,
      status: status ?? this.status,
    );
  }
}

class AlertsMockData {
  const AlertsMockData._();

  static const summaries = [
    AlertSummaryMock(
      title: 'Aktif Uyarı',
      value: '12',
      description: 'Çözüm bekleyen konu',
      trend: '3 yüksek öncelik',
      trendTone: StatusTone.warning,
      icon: Icons.notifications_active_outlined,
      accentColor: AppColors.primary,
    ),
    AlertSummaryMock(
      title: 'Kritik Risk',
      value: '3',
      description: 'Acil aksiyon gerektirir',
      trend: 'Bugün oluştu',
      trendTone: StatusTone.danger,
      icon: Icons.warning_amber_outlined,
      accentColor: AppColors.rose,
    ),
    AlertSummaryMock(
      title: 'Bekleyen Onay',
      value: '5',
      description: 'Kullanıcı onayı bekliyor',
      trend: '2 belge, 3 aksiyon',
      trendTone: StatusTone.info,
      icon: Icons.rule_folder_outlined,
      accentColor: AppColors.amber,
    ),
    AlertSummaryMock(
      title: 'Çözülen Uyarı',
      value: '28',
      description: 'Bu ay tamamlandı',
      trend: '+14%',
      trendTone: StatusTone.success,
      icon: Icons.task_alt_outlined,
      accentColor: AppColors.emerald,
    ),
  ];

  static const initialAlerts = [
    AlertMock(
      id: 'stock-turk-kahvesi',
      title: 'Türk Kahvesi 250g kritik seviyeye indi',
      category: AlertCategory.stock,
      priority: AlertPriority.critical,
      description:
          'Mevcut stok 12 adet. Son satış hızına göre yaklaşık 4 günlük stok kaldı.',
      recommendedAction: 'En az 80 adet sipariş ver.',
      timeLabel: 'Bugün 10:42',
    ),
    AlertMock(
      id: 'finance-cash-risk',
      title: '14 gün sonra nakit açığı riski',
      category: AlertCategory.finance,
      priority: AlertPriority.critical,
      description: 'Nakit projeksiyonunda 42.000 TL açık riski tespit edildi.',
      recommendedAction: 'Gecikmiş tahsilatlar için hatırlatma gönder.',
      timeLabel: 'Bugün 09:30',
    ),
    AlertMock(
      id: 'kdv-deadline',
      title: 'KDV beyanname tarihi yaklaşıyor',
      category: AlertCategory.kdv,
      priority: AlertPriority.high,
      description: 'Mayıs 2026 KDV beyannamesi için son tarih 26 Mayıs.',
      recommendedAction: 'KDV özetini kontrol et.',
      timeLabel: 'Bugün 08:15',
    ),
    AlertMock(
      id: 'attendance-check',
      title: 'Puantaj kontrolü gerekli',
      category: AlertCategory.employees,
      priority: AlertPriority.medium,
      description:
          'Zeynep Arslan için 3 izin günü ve kontrol gerekli durumu tespit edildi.',
      recommendedAction: 'Puantaj kaydını gözden geçir.',
      timeLabel: 'Dün 18:20',
    ),
    AlertMock(
      id: 'document-damaged-dispatch',
      title: 'İrsaliyede kısmi hasar tespit edildi',
      category: AlertCategory.document,
      priority: AlertPriority.medium,
      description: 'Termal Etiket 100x150 teslimatında kısmi hasar işaretlendi.',
      recommendedAction: 'Depo kontrolü başlat.',
      timeLabel: 'Dün 16:25',
    ),
    AlertMock(
      id: 'stock-filter-cost',
      title: 'Filtre Kahve 1kg maliyeti arttı',
      category: AlertCategory.stock,
      priority: AlertPriority.high,
      description:
          'Son 6 ayda maliyet %31 arttı. Net marj üzerinde baskı oluşturuyor.',
      recommendedAction: 'Alternatif tedarikçi karşılaştırması yap.',
      timeLabel: 'Dün 14:10',
    ),
    AlertMock(
      id: 'finance-overdue',
      title: 'Gecikmiş tahsilat var',
      category: AlertCategory.finance,
      priority: AlertPriority.high,
      description:
          'Ahmet Usta Market ödemesi 9 gündür gecikiyor. Tutar: 18.600 TL.',
      recommendedAction: 'Ödeme hatırlatma taslağı hazırla.',
      timeLabel: '2 gün önce',
    ),
    AlertMock(
      id: 'document-office-receipt',
      title: 'Ofis gider fişi başarıyla işlendi',
      category: AlertCategory.document,
      priority: AlertPriority.low,
      description: 'Ofis Market fişi gider kaydına dönüştürüldü.',
      recommendedAction: 'Ek aksiyon gerekmiyor.',
      timeLabel: '2 gün önce',
      status: AlertStatus.resolved,
    ),
  ];

  static const priorityDistribution = [
    AlertDistributionMock(
      label: 'Kritik',
      value: '3',
      tone: StatusTone.danger,
    ),
    AlertDistributionMock(
      label: 'Yüksek',
      value: '3',
      tone: StatusTone.warning,
    ),
    AlertDistributionMock(
      label: 'Orta',
      value: '2',
      tone: StatusTone.warning,
    ),
    AlertDistributionMock(
      label: 'Düşük',
      value: '1',
      tone: StatusTone.info,
    ),
  ];

  static const categoryDistribution = [
    AlertDistributionMock(label: 'Stok', value: '3', tone: StatusTone.info),
    AlertDistributionMock(label: 'Finans', value: '2', tone: StatusTone.success),
    AlertDistributionMock(label: 'KDV', value: '1', tone: StatusTone.warning),
    AlertDistributionMock(label: 'Puantaj', value: '1', tone: StatusTone.neutral),
    AlertDistributionMock(label: 'Belge', value: '2', tone: StatusTone.info),
  ];

  static const dailySummary =
      'Bugün en önemli 3 konu: kritik stok, nakit açığı ve KDV son tarihi. Öncelikle Türk Kahvesi 250g için tedarik aksiyonu ve gecikmiş tahsilatlar için hatırlatma önerilir.';
}
