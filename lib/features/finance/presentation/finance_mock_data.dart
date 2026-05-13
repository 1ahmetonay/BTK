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

class FinanceMockData {
  const FinanceMockData._();

  static const summaries = [
    FinanceSummaryMock(
      title: 'Aylık Gelir',
      value: '284.500 TL',
      description: 'Mayıs 2026 toplam satış',
      trend: '+18,4%',
      trendTone: StatusTone.success,
      icon: Icons.trending_up_outlined,
      accentColor: AppColors.emerald,
    ),
    FinanceSummaryMock(
      title: 'Aylık Gider',
      value: '216.300 TL',
      description: 'Satın alma, operasyon ve personel',
      trend: '+9,7%',
      trendTone: StatusTone.warning,
      icon: Icons.trending_down_outlined,
      accentColor: AppColors.amber,
    ),
    FinanceSummaryMock(
      title: 'Net Kâr',
      value: '68.200 TL',
      description: 'Tahmini aylık net sonuç',
      trend: '+12,1%',
      trendTone: StatusTone.success,
      icon: Icons.account_balance_wallet_outlined,
      accentColor: AppColors.primary,
    ),
    FinanceSummaryMock(
      title: 'Ödenecek KDV',
      value: '12.275 TL',
      description: 'Bu dönem tahmini KDV',
      trend: 'Son gün: 26 Mayıs',
      trendTone: StatusTone.warning,
      icon: Icons.receipt_long_outlined,
      accentColor: AppColors.rose,
    ),
  ];

  static const profitLossItems = [
    ProfitLossItemMock(
      label: 'Brüt satış',
      value: '284.500 TL',
      tone: StatusTone.success,
    ),
    ProfitLossItemMock(
      label: 'Satılan ürün maliyeti',
      value: '154.800 TL',
      tone: StatusTone.warning,
    ),
    ProfitLossItemMock(
      label: 'Operasyon giderleri',
      value: '38.600 TL',
      tone: StatusTone.warning,
    ),
    ProfitLossItemMock(
      label: 'Personel giderleri',
      value: '22.900 TL',
      tone: StatusTone.warning,
    ),
    ProfitLossItemMock(
      label: 'Net kâr',
      value: '68.200 TL',
      tone: StatusTone.success,
    ),
  ];

  static const profitMargin = 0.24;

  static const profitLossInsight =
      'Bu ay net kâr marjı yaklaşık %24. Kahve kategorisindeki maliyet artışına rağmen satış hacmi kârlılığı koruyor.';

  static const kdvSummary = KdvSummaryMock(
    calculatedVat: '47.425 TL',
    deductibleVat: '35.150 TL',
    payableVat: '12.275 TL',
    deadline: '26 Mayıs 2026',
    statusLabel: 'Takip gerekli',
    warning:
        'Son 3 günde işlenen satın alma faturaları indirilecek KDV’yi 3.075 TL artırdı.',
  );

  static const cashflowMetrics = [
    ProfitLossItemMock(
      label: 'Bugünkü kasa',
      value: '126.400 TL',
      tone: StatusTone.info,
    ),
    ProfitLossItemMock(
      label: 'Beklenen tahsilat',
      value: '91.000 TL',
      tone: StatusTone.success,
    ),
    ProfitLossItemMock(
      label: 'Beklenen ödeme',
      value: '133.000 TL',
      tone: StatusTone.danger,
    ),
    ProfitLossItemMock(
      label: 'Tahmini dönem sonu',
      value: '84.400 TL',
      tone: StatusTone.info,
    ),
  ];

  static const cashflowRisk =
      'Risk: 14 gün sonra 42.000 TL nakit açığı oluşabilir';

  static const cashflowPoints = [
    CashflowPointMock(
      label: 'Bugün',
      value: '126.400 TL',
      description: 'Kasa ve banka toplamı',
      tone: StatusTone.info,
    ),
    CashflowPointMock(
      label: '7 gün',
      value: '104.200 TL',
      description: 'Planlı ödemeler sonrası',
      tone: StatusTone.warning,
    ),
    CashflowPointMock(
      label: '14 gün',
      value: '-42.000 TL risk',
      description: 'Tahsilat gecikirse açık oluşur',
      tone: StatusTone.danger,
    ),
    CashflowPointMock(
      label: '30 gün',
      value: '84.400 TL',
      description: 'Dönem sonu tahmini',
      tone: StatusTone.info,
    ),
  ];

  static const overduePayments = [
    OverduePaymentMock(
      customerName: 'Ahmet Usta Market',
      amount: '18.600 TL',
      delay: '9 gün gecikti',
      actionLabel: 'Hatırlatma öner',
    ),
    OverduePaymentMock(
      customerName: 'Yıldız Büfe',
      amount: '7.400 TL',
      delay: '5 gün gecikti',
      actionLabel: 'Hatırlatma öner',
    ),
    OverduePaymentMock(
      customerName: 'Online Pazaryeri Komisyon İadesi',
      amount: '12.800 TL',
      delay: '3 gün gecikti',
      actionLabel: 'Takip et',
    ),
  ];

  static const movements = [
    FinanceMovementMock(
      title: 'Satın alma faturası işlendi',
      source: 'Aksoy Tedarik',
      amount: '-18.450 TL',
      timestamp: 'Bugün 10:42',
      tone: StatusTone.danger,
    ),
    FinanceMovementMock(
      title: 'Satış faturası işlendi',
      source: 'Trendyol Siparişleri',
      amount: '+32.100 TL',
      timestamp: 'Bugün 09:18',
      tone: StatusTone.success,
    ),
    FinanceMovementMock(
      title: 'Puantaj gideri oluşturuldu',
      source: 'Mayıs 2026',
      amount: '-22.900 TL',
      timestamp: 'Dün 18:20',
      tone: StatusTone.danger,
    ),
    FinanceMovementMock(
      title: 'Ofis gider fişi işlendi',
      source: 'Ofis Market',
      amount: '-1.240 TL',
      timestamp: 'Dün 15:12',
      tone: StatusTone.warning,
    ),
  ];

  static const aiInsights = [
    FinanceInsightMock(
      message:
          '14 gün sonra oluşabilecek nakit açığı için Aksoy Tedarik ödemesi 10 gün ertelenebilir.',
      icon: Icons.auto_awesome_outlined,
    ),
    FinanceInsightMock(
      message:
          'Filtre Kahve 1kg maliyet artışı net kâr marjını %4,2 düşürüyor.',
      icon: Icons.lightbulb_outline,
      iconColor: AppColors.amber,
    ),
    FinanceInsightMock(
      message:
          'Gecikmiş 3 tahsilatın toplamı 38.800 TL. Hatırlatma gönderilirse nakit riski azalabilir.',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  static const incomeDistribution = [
    DistributionItemMock(
      label: 'Trendyol satışları',
      valueLabel: '%48',
      progress: 0.48,
      color: AppColors.primary,
    ),
    DistributionItemMock(
      label: 'Mağaza satışları',
      valueLabel: '%32',
      progress: 0.32,
      color: AppColors.emerald,
    ),
    DistributionItemMock(
      label: 'Kurumsal satışlar',
      valueLabel: '%20',
      progress: 0.20,
      color: AppColors.teal,
    ),
  ];

  static const expenseDistribution = [
    DistributionItemMock(
      label: 'Ürün maliyeti',
      valueLabel: '%58',
      progress: 0.58,
      color: AppColors.rose,
    ),
    DistributionItemMock(
      label: 'Personel',
      valueLabel: '%18',
      progress: 0.18,
      color: AppColors.primary,
    ),
    DistributionItemMock(
      label: 'Lojistik',
      valueLabel: '%14',
      progress: 0.14,
      color: AppColors.amber,
    ),
    DistributionItemMock(
      label: 'Ofis/Diğer',
      valueLabel: '%10',
      progress: 0.10,
      color: AppColors.muted,
    ),
  ];
}
