import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';

class FinanceSummaryMock {
  const FinanceSummaryMock({
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

class ProfitLossItemMock {
  const ProfitLossItemMock({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final StatusTone tone;
}

class CashflowPointMock {
  const CashflowPointMock({
    required this.label,
    required this.value,
    required this.description,
    required this.tone,
  });

  final String label;
  final String value;
  final String description;
  final StatusTone tone;
}

class OverduePaymentMock {
  const OverduePaymentMock({
    required this.customerName,
    required this.amount,
    required this.delay,
    required this.actionLabel,
  });

  final String customerName;
  final String amount;
  final String delay;
  final String actionLabel;
}

class FinanceMovementMock {
  const FinanceMovementMock({
    required this.title,
    required this.source,
    required this.amount,
    required this.timestamp,
    required this.tone,
  });

  final String title;
  final String source;
  final String amount;
  final String timestamp;
  final StatusTone tone;
}

class FinanceInsightMock {
  const FinanceInsightMock({
    required this.message,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String message;
  final IconData icon;
  final Color iconColor;
}

class DistributionItemMock {
  const DistributionItemMock({
    required this.label,
    required this.valueLabel,
    required this.progress,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double progress;
  final Color color;
}

class KdvSummaryMock {
  const KdvSummaryMock({
    required this.calculatedVat,
    required this.deductibleVat,
    required this.payableVat,
    required this.deadline,
    required this.statusLabel,
    required this.warning,
  });

  final String calculatedVat;
  final String deductibleVat;
  final String payableVat;
  final String deadline;
  final String statusLabel;
  final String warning;
}
