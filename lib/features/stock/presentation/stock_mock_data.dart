import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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

class StockMockData {
  const StockMockData._();

  static const summaries = [
    StockSummaryMock(
      title: 'Toplam SKU',
      value: '128',
      description: 'Aktif takip edilen ürün',
      trend: '+12 bu ay',
      trendTone: StatusTone.info,
      icon: Icons.category_outlined,
      accentColor: AppColors.primary,
    ),
    StockSummaryMock(
      title: 'Kritik Stok',
      value: '7',
      description: 'Acil tedarik gerektiren ürün',
      trend: '3 ürün bugün kritikleşti',
      trendTone: StatusTone.warning,
      icon: Icons.warning_amber_outlined,
      accentColor: AppColors.rose,
    ),
    StockSummaryMock(
      title: 'Stok Değeri',
      value: '842.500 TL',
      description: 'Tahmini mevcut stok maliyeti',
      trend: '+8,4%',
      trendTone: StatusTone.success,
      icon: Icons.warehouse_outlined,
      accentColor: AppColors.teal,
    ),
    StockSummaryMock(
      title: 'Ortalama Devir Hızı',
      value: '18 gün',
      description: 'Ürünlerin ortalama stokta kalma süresi',
      trend: '-2 gün iyileşme',
      trendTone: StatusTone.success,
      icon: Icons.sync_alt_outlined,
      accentColor: AppColors.emerald,
    ),
  ];

  static const criticalProducts = [
    ProductStockMock(
      sku: 'KHV-250',
      productName: 'Türk Kahvesi 250g',
      category: 'Kahve',
      currentStock: '12',
      minimumStock: '30',
      lastPurchaseCost: '120 TL',
      statusLabel: 'Kritik',
      statusTone: StatusTone.danger,
      daysRemaining: '4 gün',
    ),
    ProductStockMock(
      sku: 'KHV-1000',
      productName: 'Filtre Kahve 1kg',
      category: 'Kahve',
      currentStock: '8',
      minimumStock: '20',
      lastPurchaseCost: '310 TL',
      statusLabel: 'Kritik',
      statusTone: StatusTone.danger,
      daysRemaining: '6 gün',
    ),
    ProductStockMock(
      sku: 'ETK-150',
      productName: 'Termal Etiket 100x150',
      category: 'Ambalaj',
      currentStock: '24',
      minimumStock: '50',
      lastPurchaseCost: '17,50 TL',
      statusLabel: 'Düşük',
      statusTone: StatusTone.warning,
      daysRemaining: '9 gün',
    ),
    ProductStockMock(
      sku: 'AMB-001',
      productName: 'Kargo Poşeti Orta Boy',
      category: 'Ambalaj',
      currentStock: '31',
      minimumStock: '80',
      lastPurchaseCost: '5,50 TL',
      statusLabel: 'Düşük',
      statusTone: StatusTone.warning,
      daysRemaining: '11 gün',
    ),
  ];

  static const allProducts = [
    ProductStockMock(
      sku: 'KHV-250',
      productName: 'Türk Kahvesi 250g',
      category: 'Kahve',
      currentStock: '12',
      minimumStock: '30',
      lastPurchaseCost: '120 TL',
      statusLabel: 'Kritik',
      statusTone: StatusTone.danger,
      daysRemaining: '4 gün',
    ),
    ProductStockMock(
      sku: 'KHV-1000',
      productName: 'Filtre Kahve 1kg',
      category: 'Kahve',
      currentStock: '8',
      minimumStock: '20',
      lastPurchaseCost: '310 TL',
      statusLabel: 'Kritik',
      statusTone: StatusTone.danger,
      daysRemaining: '6 gün',
    ),
    ProductStockMock(
      sku: 'AMB-001',
      productName: 'Kargo Poşeti Orta Boy',
      category: 'Ambalaj',
      currentStock: '31',
      minimumStock: '80',
      lastPurchaseCost: '5,50 TL',
      statusLabel: 'Düşük',
      statusTone: StatusTone.warning,
      daysRemaining: '11 gün',
    ),
    ProductStockMock(
      sku: 'ETK-150',
      productName: 'Termal Etiket 100x150',
      category: 'Ambalaj',
      currentStock: '24',
      minimumStock: '50',
      lastPurchaseCost: '17,50 TL',
      statusLabel: 'Düşük',
      statusTone: StatusTone.warning,
      daysRemaining: '9 gün',
    ),
    ProductStockMock(
      sku: 'KHV-ESP',
      productName: 'Espresso Çekirdeği 1kg',
      category: 'Kahve',
      currentStock: '42',
      minimumStock: '20',
      lastPurchaseCost: '285 TL',
      statusLabel: 'Normal',
      statusTone: StatusTone.success,
      daysRemaining: '21 gün',
    ),
    ProductStockMock(
      sku: 'KUP-001',
      productName: 'Karton Bardak 8oz',
      category: 'Sarf',
      currentStock: '1.200',
      minimumStock: '400',
      lastPurchaseCost: '1,20 TL',
      statusLabel: 'Normal',
      statusTone: StatusTone.success,
      daysRemaining: '36 gün',
    ),
  ];

  static const movements = [
    StockMovementMock(
      title: 'Satın alma faturası işlendi',
      productName: 'Türk Kahvesi 250g',
      quantityChange: '+50 adet',
      timestamp: 'Bugün 10:42',
      tone: StatusTone.success,
    ),
    StockMovementMock(
      title: 'Satış faturası işlendi',
      productName: 'Filtre Kahve 1kg',
      quantityChange: '-30 adet',
      timestamp: 'Bugün 09:18',
      tone: StatusTone.danger,
    ),
    StockMovementMock(
      title: 'İrsaliye onaylandı',
      productName: 'Kargo Poşeti Orta Boy',
      quantityChange: '+500 adet',
      timestamp: 'Dün 16:25',
      tone: StatusTone.success,
    ),
    StockMovementMock(
      title: 'Manuel sayım farkı',
      productName: 'Termal Etiket 100x150',
      quantityChange: '-6 adet',
      timestamp: 'Dün 14:10',
      tone: StatusTone.warning,
    ),
  ];

  static const aiSuggestions = [
    'Türk Kahvesi 250g ürünü 4 gün içinde bitebilir. En az 80 adet sipariş önerilir.',
    'Filtre Kahve 1kg maliyeti son 6 ayda %31 arttı. Alternatif tedarikçi kontrol edilmeli.',
    'Kargo Poşeti Orta Boy’da satış hızı son 14 günde %22 arttı. Minimum stok seviyesi 80’den 120’ye çıkarılabilir.',
  ];

  static const selectedSupplierProduct = 'Filtre Kahve 1kg';

  static const suppliers = [
    SupplierComparisonMock(
      supplierName: 'Aksoy Tedarik',
      price: '310 TL',
      leadTime: '3 gün',
      trustScore: '8.7',
    ),
    SupplierComparisonMock(
      supplierName: 'Marmara Gıda',
      price: '298 TL',
      leadTime: '5 gün',
      trustScore: '7.9',
    ),
    SupplierComparisonMock(
      supplierName: 'Ege Kahve Deposu',
      price: '322 TL',
      leadTime: '2 gün',
      trustScore: '9.1',
    ),
  ];

  static const supplierInsight =
      'En hızlı teslimat Ege Kahve Deposu’nda, en düşük fiyat Marmara Gıda’da. Acil stok için Ege, maliyet optimizasyonu için Marmara önerilir.';

  static const insights = [
    StockInsightMock(
      title: 'ABC Analizi',
      description: 'A grubu yüksek ciro etkisine sahip ürünler',
      valueLabel: 'A %70 | B %20 | C %10',
      progress: 0.70,
      color: AppColors.primary,
    ),
    StockInsightMock(
      title: 'Enflasyon Etkisi',
      description: 'Kahve kategorisinde son 6 ay maliyet artışı',
      valueLabel: '%28 artış',
      progress: 0.28,
      color: AppColors.rose,
    ),
    StockInsightMock(
      title: 'Stok Devir Hızı',
      description: 'Ambalaj ürünlerinde son 30 gün tüketim',
      valueLabel: '%18 artış',
      progress: 0.18,
      color: AppColors.amber,
    ),
  ];
}
