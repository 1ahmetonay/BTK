import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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

class DashboardMockData {
  const DashboardMockData._();

  static const stats = [
    DashboardStatData(
      title: 'Aylık Ciro',
      value: '284.500 TL',
      description: 'Geçen aya göre sipariş akışı daha güçlü',
      changeLabel: '+%18,4',
      changeTone: StatusTone.success,
      icon: Icons.payments_outlined,
      accentColor: AppColors.primary,
    ),
    DashboardStatData(
      title: 'Net Kâr',
      value: '68.200 TL',
      description: 'Brüt marj korunuyor, gider baskısı sınırlı',
      changeLabel: '+%9,1',
      changeTone: StatusTone.success,
      icon: Icons.trending_up_outlined,
      accentColor: AppColors.emerald,
    ),
    DashboardStatData(
      title: 'Kritik Stok',
      value: '7 ürün',
      description: 'İki ürün için sipariş penceresi daralıyor',
      changeLabel: '+%16,0',
      changeTone: StatusTone.warning,
      icon: Icons.inventory_2_outlined,
      accentColor: AppColors.amber,
    ),
    DashboardStatData(
      title: 'Bekleyen Ödeme',
      value: '43.800 TL',
      description: 'Önümüzdeki 10 günde ödeme yoğunluğu artıyor',
      changeLabel: '-%6,3',
      changeTone: StatusTone.danger,
      icon: Icons.receipt_long_outlined,
      accentColor: AppColors.rose,
    ),
  ];

  static const briefItems = [
    BriefItemData(
      title: 'Ürün X kritik seviyeye indi',
      detail: '12 adet kaldı, tahmini 4 günlük stok',
      accentColor: AppColors.rose,
    ),
    BriefItemData(
      title: '14 gün sonra nakit açığı görünüyor',
      detail: 'Tahmini açık 42.000 TL seviyesinde',
      accentColor: AppColors.amber,
    ),
    BriefItemData(
      title: 'KDV beyanname son tarihi yaklaşıyor',
      detail: 'Son tarih 26 Mayıs olarak görünüyor',
      accentColor: AppColors.primary,
    ),
  ];

  static const stockAlerts = [
    StockAlertData(
      productName: 'Türk Kahvesi 250g',
      quantity: '12 adet',
      statusLabel: 'Kritik',
      statusTone: StatusTone.danger,
    ),
    StockAlertData(
      productName: 'Termal Etiket 100x150',
      quantity: '24 adet',
      statusLabel: 'Düşük',
      statusTone: StatusTone.warning,
    ),
    StockAlertData(
      productName: 'Kargo Poşeti Orta Boy',
      quantity: '31 adet',
      statusLabel: 'Düşük',
      statusTone: StatusTone.warning,
    ),
    StockAlertData(
      productName: 'Filtre Kahve 1kg',
      quantity: '8 adet',
      statusLabel: 'Kritik',
      statusTone: StatusTone.danger,
    ),
  ];

  static const cashflowMetrics = [
    CashflowMetricData(
      label: 'Bugünkü kasa',
      value: '126.400 TL',
      emphasisColor: AppColors.primary,
    ),
    CashflowMetricData(
      label: '30 günlük tahmini giriş',
      value: '91.000 TL',
      emphasisColor: AppColors.emerald,
    ),
    CashflowMetricData(
      label: '30 günlük tahmini çıkış',
      value: '133.000 TL',
      emphasisColor: AppColors.rose,
    ),
    CashflowMetricData(
      label: 'Tahmini fark',
      value: '-42.000 TL',
      emphasisColor: AppColors.rose,
    ),
  ];

  static const cashflowSuggestion =
      'Vadeli tedarik ödemelerini 10 gün ötelemek nakit açığını azaltabilir.';

  static const recentDocuments = [
    RecentDocumentData(
      documentType: 'Satın alma faturası',
      source: 'Aksoy Tedarik',
      value: '18.450 TL',
      statusLabel: 'İşlendi',
      statusTone: StatusTone.success,
    ),
    RecentDocumentData(
      documentType: 'Satış faturası',
      source: 'Trendyol Siparişleri',
      value: '32.100 TL',
      statusLabel: 'İşlendi',
      statusTone: StatusTone.success,
    ),
    RecentDocumentData(
      documentType: 'Puantaj belgesi',
      source: 'Mayıs 2026',
      value: '5 çalışan',
      statusLabel: 'Kontrol bekliyor',
      statusTone: StatusTone.warning,
    ),
    RecentDocumentData(
      documentType: 'İrsaliye',
      source: 'Marmara Lojistik',
      value: '72 koli',
      statusLabel: 'İşlendi',
      statusTone: StatusTone.success,
    ),
  ];

  static const aiSuggestions = [
    AiSuggestionData('Filtre Kahve 1kg ürününde son 6 ayda maliyet %31 arttı.'),
    AiSuggestionData('Kargo poşeti stoğu 9 gün içinde bitebilir.'),
    AiSuggestionData('Bu ay en yüksek kâr marjı Türk Kahvesi 250g ürününde.'),
  ];
}
