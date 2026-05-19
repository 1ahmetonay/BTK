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
      AlertPriority.medium => AppColors.yellowWarning,
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
