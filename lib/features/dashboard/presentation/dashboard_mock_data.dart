import 'package:flutter/material.dart';

import '../../../shared/widgets/status_badge.dart';

class DashboardStatData {
  const DashboardStatData({
    required this.title,
    required this.value,
    required this.description,
    required this.changeLabel,
    required this.changeTone,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String description;
  final String changeLabel;
  final StatusTone changeTone;
  final IconData icon;
  final Color accentColor;
}

class BriefItemData {
  const BriefItemData({
    required this.title,
    required this.detail,
    required this.accentColor,
  });

  final String title;
  final String detail;
  final Color accentColor;
}

class StockAlertData {
  const StockAlertData({
    required this.productName,
    required this.quantity,
    required this.statusLabel,
    required this.statusTone,
  });

  final String productName;
  final String quantity;
  final String statusLabel;
  final StatusTone statusTone;
}

class CashflowMetricData {
  const CashflowMetricData({
    required this.label,
    required this.value,
    required this.emphasisColor,
  });

  final String label;
  final String value;
  final Color emphasisColor;
}

class RecentDocumentData {
  const RecentDocumentData({
    required this.documentType,
    required this.source,
    required this.value,
    required this.statusLabel,
    required this.statusTone,
  });

  final String documentType;
  final String source;
  final String value;
  final String statusLabel;
  final StatusTone statusTone;
}

class AiSuggestionData {
  const AiSuggestionData(this.message);

  final String message;
}
