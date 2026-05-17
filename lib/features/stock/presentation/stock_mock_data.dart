import 'package:flutter/material.dart';

import '../../../shared/widgets/status_badge.dart';

class StockSummaryMock {
  const StockSummaryMock({
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

class ProductStockMock {
  const ProductStockMock({
    required this.sku,
    required this.productName,
    required this.category,
    required this.currentStock,
    required this.minimumStock,
    required this.lastPurchaseCost,
    required this.statusLabel,
    required this.statusTone,
    required this.daysRemaining,
  });

  final String sku;
  final String productName;
  final String category;
  final String currentStock;
  final String minimumStock;
  final String lastPurchaseCost;
  final String statusLabel;
  final StatusTone statusTone;
  final String daysRemaining;
}

class StockMovementMock {
  const StockMovementMock({
    required this.title,
    required this.productName,
    required this.quantityChange,
    required this.timestamp,
    required this.tone,
  });

  final String title;
  final String productName;
  final String quantityChange;
  final String timestamp;
  final StatusTone tone;
}

class SupplierComparisonMock {
  const SupplierComparisonMock({
    required this.supplierName,
    required this.price,
    required this.leadTime,
    required this.trustScore,
  });

  final String supplierName;
  final String price;
  final String leadTime;
  final String trustScore;
}

class StockInsightMock {
  const StockInsightMock({
    required this.title,
    required this.description,
    required this.valueLabel,
    required this.progress,
    required this.color,
  });

  final String title;
  final String description;
  final String valueLabel;
  final double progress;
  final Color color;
}
