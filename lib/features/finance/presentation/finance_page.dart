import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import 'finance_mock_data.dart';
import 'widgets/ai_finance_suggestions_card.dart';
import 'widgets/cashflow_forecast_card.dart';
import 'widgets/distribution_card.dart';
import 'widgets/finance_movements_card.dart';
import 'widgets/kdv_summary_card.dart';
import 'widgets/overdue_payments_card.dart';
import 'widgets/profit_loss_card.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  List<ProfitLossItemMock> _plItems = [];
  double _profitMargin = 0;
  String _plInsight = '';
  KdvSummaryMock? _kdvSummary;
  List<ProfitLossItemMock> _cashflowMetrics = [];
  List<CashflowPointMock> _cashflowPoints = [];
  String _cashflowRisk = '';
  List<OverduePaymentMock> _overduePayments = [];
  List<FinanceSummaryMock> _summaries = [];
  final List<DistributionItemMock> _incomeDistribution = [];
  List<DistributionItemMock> _expenseDistribution = [];
  List<FinanceInsightMock> _aiInsights = [];
  List<FinanceMovementMock> _finMovements = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFinanceData();
  }

  Future<void> _fetchFinanceData() async {
    try {
      // P&L, Cashflow ve KDV paralel çek
      final results = await Future.wait([
        ApiService.instance.getPlSummary(),
        ApiService.instance.getCashflow(),
        ApiService.instance.getKdvSummary(),
        ApiService.instance.getOverduePayments(type: 'satis'),
      ]);

      if (!mounted) return;

      final pl = results[0] as Map<String, dynamic>;
      final cashflow = results[1] as Map<String, dynamic>;
      final kdv = results[2] as Map<String, dynamic>;
      final overdue = results[3] as List<dynamic>;

      // P&L verisini dönüştür
      final gelir = (pl['toplam_gelir'] ?? pl['gelir'] ?? 0.0) as num;
      final gider = (pl['toplam_gider'] ?? 0.0) as num;
      final netKar = (pl['net_kar'] ?? 0.0) as num;
      final marj = gelir > 0 ? netKar / gelir : 0.0;

      final livePlItems = [
        ProfitLossItemMock(
          label: 'Brüt satış',
          value: '${_fmt(gelir.toDouble())} TL',
          tone: StatusTone.success,
        ),
        ProfitLossItemMock(
          label: 'Toplam gider',
          value: '${_fmt(gider.toDouble())} TL',
          tone: StatusTone.warning,
        ),
        ProfitLossItemMock(
          label: 'Net kâr',
          value: '${_fmt(netKar.toDouble())} TL',
          tone: netKar > 0 ? StatusTone.success : StatusTone.danger,
        ),
      ];

      // Summary strip
      final kdvOdenecek = (kdv['odenecek_kdv'] ?? 0.0) as num;
      final liveSummaries = [
        FinanceSummaryMock(
          title: 'Aylık Gelir',
          value: '${_fmt(gelir.toDouble())} TL',
          description: 'Toplam satış',
          trend: '+Gerçek',
          trendTone: StatusTone.success,
          icon: Icons.trending_up_outlined,
          accentColor: AppColors.secondary,
        ),
        FinanceSummaryMock(
          title: 'Aylık Gider',
          value: '${_fmt(gider.toDouble())} TL',
          description: 'Tüm giderler',
          trend: 'Güncel',
          trendTone: StatusTone.warning,
          icon: Icons.trending_down_outlined,
          accentColor: AppColors.warning,
        ),
        FinanceSummaryMock(
          title: 'Net Kâr',
          value: '${_fmt(netKar.toDouble())} TL',
          description: 'Tahmini net sonuç',
          trend: '${(marj * 100).toStringAsFixed(1)}% marj',
          trendTone: netKar > 0 ? StatusTone.success : StatusTone.danger,
          icon: Icons.account_balance_wallet_outlined,
          accentColor: AppColors.primary,
        ),
        FinanceSummaryMock(
          title: 'Ödenecek KDV',
          value: '${_fmt(kdvOdenecek.toDouble())} TL',
          description: 'Bu dönem KDV',
          trend: 'Son gün kontrol et',
          trendTone: StatusTone.warning,
          icon: Icons.receipt_long_outlined,
          accentColor: AppColors.error,
        ),
      ];

      // KDV özeti
      final liveKdv = KdvSummaryMock(
        calculatedVat: '${_fmt((kdv['hesaplanan_kdv'] ?? 0.0) as double)} TL',
        deductibleVat: '${_fmt((kdv['indirilecek_kdv'] ?? 0.0) as double)} TL',
        payableVat: '${_fmt(kdvOdenecek.toDouble())} TL',
        deadline:
            (kdv['son_odeme_tarihi'] ?? kdv['beyanname_son_tarihi'])
                as String? ??
            '—',
        statusLabel:
            kdv['durum'] as String? ??
            (kdv['uyari'] == true ? 'Son gün yaklaşıyor' : 'Normal'),
        warning: 'KDV hesaplandı. Lütfen son tarihi kontrol edin.',
      );

      // Cashflow
      final bakiye = (cashflow['mevcut_bakiye'] ?? 0.0) as num;
      final projeksiyon =
          (cashflow['projeksiyon'] ?? cashflow['projeksiyonlar'])
              as List<dynamic>? ??
          [];

      double donemSonuTahmini;
      if (cashflow['donem_sonu_tahmini'] != null) {
        donemSonuTahmini = (cashflow['donem_sonu_tahmini'] as num).toDouble();
      } else if (projeksiyon.isNotEmpty) {
        final last = projeksiyon.last as Map<String, dynamic>;
        donemSonuTahmini =
            (last['tahmini_bakiye'] as num?)?.toDouble() ?? bakiye.toDouble();
      } else {
        donemSonuTahmini = bakiye.toDouble();
      }

      final liveCfMetrics = [
        ProfitLossItemMock(
          label: 'Bugünkü kasa',
          value: '${_fmt(bakiye.toDouble())} TL',
          tone: StatusTone.info,
        ),
        ProfitLossItemMock(
          label: 'Tahmini dönem sonu',
          value: '${_fmt(donemSonuTahmini)} TL',
          tone: StatusTone.info,
        ),
      ];

      final liveCfPoints = projeksiyon.take(4).map<CashflowPointMock>((p) {
        final pm = p as Map<String, dynamic>;
        final val = (pm['tahmini_bakiye'] ?? 0.0) as num;
        final gunLabel = pm['gun'];
        return CashflowPointMock(
          label: gunLabel is int
              ? '$gunLabel. gün'
              : (gunLabel as String? ?? '—'),
          value: '${_fmt(val.toDouble())} TL',
          description:
              pm['notlar'] as String? ?? (val < 0 ? 'Risk bölgesi' : ''),
          tone: val < 0 ? StatusTone.danger : StatusTone.info,
        );
      }).toList();

      final bool hasRisk = projeksiyon.any(
        (p) => (p as Map<String, dynamic>)['risk'] == true,
      );
      final riskStr =
          cashflow['risk_uyarisi'] as String? ??
          (hasRisk
              ? 'Dikkat: Nakit akışında risk tespit edildi.'
              : 'Nakit akışı normal seyrediyor.');

      // Gecikmiş ödemeler
      final liveOverdue = overdue.map<OverduePaymentMock>((raw) {
        final m = raw as Map<String, dynamic>;
        return OverduePaymentMock(
          invoiceId: m['fatura_id'] as int?,
          customerName: m['karsi_taraf'] as String? ?? '—',
          amount: '${_fmt((m['tutar'] ?? 0.0) as double)} TL',
          delay: '${m['gecikme_gun'] ?? 0} gün gecikti',
          actionLabel: 'Hatırlatma öner',
        );
      }).toList();

      // Son faturaları çek → movements + distribution
      List<FinanceMovementMock> liveMovements = [];
      try {
        final invoices = await ApiService.instance.getRecentInvoices(limit: 5);
        liveMovements = invoices.map<FinanceMovementMock>((raw) {
          final m = raw as Map<String, dynamic>;
          final tutar = (m['toplam_tutar'] as num?)?.toDouble() ?? 0;
          final tur = m['tur'] as String? ?? '';
          final isGelir = tur.contains('satis');
          return FinanceMovementMock(
            title: isGelir ? 'Satış faturası' : 'Satın alma faturası',
            source: m['karsi_taraf'] as String? ?? '—',
            amount: '${isGelir ? '+' : '-'}${_fmt(tutar)} TL',
            timestamp: m['tarih'] as String? ?? '—',
            tone: isGelir ? StatusTone.success : StatusTone.danger,
          );
        }).toList();
      } catch (_) {}

      // AI insights — gerçek veriden türet
      final liveInsights = <FinanceInsightMock>[];
      Map<String, dynamic>? riskyProjection;
      for (final item in projeksiyon) {
        final p = item as Map<String, dynamic>;
        if (p['risk'] == true) {
          riskyProjection = p;
          break;
        }
      }
      if (riskyProjection != null) {
        final riskDay = riskyProjection['gun'];
        final riskBalance =
            (riskyProjection['tahmini_bakiye'] as num?)?.toDouble() ?? 0;
        liveInsights.add(
          FinanceInsightMock(
            title: 'Nakit Açığı Yönetimi',
            message:
                '$riskDay. gün tahmini bakiye ${_fmt(riskBalance)} TL. Gecikmiş tahsilatları hızlandırıp zorunlu olmayan çıkışları ötelemeniz önerilir.',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.error,
          ),
        );
      } else {
        liveInsights.add(
          FinanceInsightMock(
            title: 'Nakit Açığı Yönetimi',
            message:
                '30 günlük projeksiyonda nakit açığı görünmüyor. Dönem sonu tahmini bakiye ${_fmt(donemSonuTahmini)} TL.',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.secondary,
          ),
        );
      }
      liveInsights.add(
        FinanceInsightMock(
          title: 'Marj Analizi',
          message:
              'Net kâr marjı ${(marj * 100).toStringAsFixed(1)}%. Gelir ${_fmt(gelir.toDouble())} TL, gider ${_fmt(gider.toDouble())} TL, net kâr ${_fmt(netKar.toDouble())} TL.',
          icon: Icons.trending_up_outlined,
          iconColor: marj < 0.15 ? AppColors.amber : AppColors.secondary,
        ),
      );
      if (liveOverdue.isNotEmpty) {
        final toplamGeciken = overdue.fold<double>(
          0,
          (s, m) =>
              s +
              ((m as Map<String, dynamic>)['tutar'] as num? ?? 0).toDouble(),
        );
        liveInsights.add(
          FinanceInsightMock(
            title: 'Tahsilat Hatırlatıcı',
            message:
                '${liveOverdue.length} gecikmiş tahsilatın toplamı ${_fmt(toplamGeciken)} TL. Hatırlatma gönderilmesi önerilir.',
            icon: Icons.auto_awesome_outlined,
          ),
        );
      }
      if (kdvOdenecek.toDouble() > 0) {
        liveInsights.add(
          FinanceInsightMock(
            title: 'KDV Nakit Planı',
            message:
                'Bu dönem ${_fmt(kdvOdenecek.toDouble())} TL KDV ödemesi yapılacak.',
            icon: Icons.auto_awesome_outlined,
          ),
        );
      }

      // Gelir/gider dağılımı — basit hesap
      final toplamGider = gider.toDouble();
      final satinAlma =
          (pl['satin_alma_gideri'] as num?)?.toDouble() ?? toplamGider * 0.6;
      final giderDagilimi = pl['gider_dagilimi'] as List<dynamic>? ?? [];
      double? parsedPersonel;
      for (final item in giderDagilimi) {
        final m = item as Map<String, dynamic>;
        if (m['kategori'] == 'Maaş') {
          parsedPersonel = (m['tutar'] as num?)?.toDouble();
          break;
        }
      }
      final personelGider =
          (pl['personel_gideri'] as num?)?.toDouble() ??
          parsedPersonel ??
          toplamGider * 0.2;
      final digerGider = toplamGider - satinAlma - personelGider;

      setState(() {
        _plItems = livePlItems;
        _profitMargin = marj.toDouble();
        _plInsight =
            'Gerçek verilere göre net kâr marjı ${(marj * 100).toStringAsFixed(1)}%.';
        _kdvSummary = liveKdv;
        _cashflowMetrics = liveCfMetrics;
        _cashflowPoints = liveCfPoints;
        _cashflowRisk = riskStr;
        _summaries = liveSummaries;
        _overduePayments = liveOverdue;
        _finMovements = liveMovements;
        _aiInsights = liveInsights;

        if (toplamGider > 0) {
          _expenseDistribution = [
            DistributionItemMock(
              label: 'Ürün maliyeti',
              valueLabel: '%${(satinAlma / toplamGider * 100).round()}',
              progress: satinAlma / toplamGider,
              color: AppColors.rose,
            ),
            DistributionItemMock(
              label: 'Personel',
              valueLabel: '%${(personelGider / toplamGider * 100).round()}',
              progress: personelGider / toplamGider,
              color: AppColors.primary,
            ),
            DistributionItemMock(
              label: 'Diğer',
              valueLabel: '%${(digerGider / toplamGider * 100).round()}',
              progress: digerGider / toplamGider,
              color: AppColors.amber,
            ),
          ];
        }
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Finans verileri yüklenemedi: $e';
        });
      }
    }
  }

  String _fmt(double val) {
    if (val.abs() >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val.abs() >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}.${((val.abs() % 1000) ~/ 100) * 100 == 0 ? '000' : ((val.abs() % 1000) ~/ 100) * 100}';
    }
    return val.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _fetchFinanceData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FinanceIntroCard(),
        const SizedBox(height: 16),
        _FinanceRiskStrip(
          overdueCount: _overduePayments.length,
          profitMargin: _profitMargin,
          kdvPayable: _kdvSummary?.payableVat ?? '',
        ),
        const SizedBox(height: 16),
        _FinanceSummaryStrip(summaries: _summaries),
        const SizedBox(height: 16),
        ProfitLossCard(
          items: _plItems,
          margin: _profitMargin,
          aiInsight: _plInsight,
        ),
        const SizedBox(height: 16),
        if (_kdvSummary != null)
          KdvSummaryCard(
            summary: _kdvSummary!,
            onDetails: () => _showKdvDetails(context),
          ),
        const SizedBox(height: 16),
        CashflowForecastCard(
          metrics: _cashflowMetrics,
          points: _cashflowPoints,
          riskText: _cashflowRisk,
        ),
        const SizedBox(height: 16),
        OverduePaymentsCard(
          payments: _overduePayments,
          onDraftReminder: _showReminderMessage,
        ),
        const SizedBox(height: 16),
        DistributionCard(
          incomeItems: _incomeDistribution,
          expenseItems: _expenseDistribution,
        ),
        const SizedBox(height: 16),
        AiFinanceSuggestionsCard(
          insights: _aiInsights,
          onApply: (msg) => _applyFinanceInsight(msg),
        ),
        const SizedBox(height: 16),
        FinanceMovementsCard(
          movements: _finMovements,
          onShowAll: () => _showAllMovements(context),
        ),
      ],
    );
  }

  void _showKdvDetails(BuildContext context) {
    final s = _kdvSummary;
    if (s == null) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('KDV Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kdvRow('Hesaplanan KDV', s.calculatedVat),
            _kdvRow('İndirilecek KDV', s.deductibleVat),
            _kdvRow('Ödenecek KDV', s.payableVat),
            const Divider(),
            _kdvRow('Son Ödeme Tarihi', s.deadline),
            _kdvRow('Durum', s.statusLabel),
            const SizedBox(height: 8),
            Text(
              s.warning,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _kdvRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _showAllMovements(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tüm Hareketler'),
        content: SizedBox(
          width: 420,
          child: _finMovements.isEmpty
              ? const Text('Henüz hareket kaydı yok.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _finMovements.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = _finMovements[i];
                    return ListTile(
                      dense: true,
                      title: Text(m.title),
                      subtitle: Text('${m.source} • ${m.timestamp}'),
                      trailing: Text(
                        m.amount,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: m.tone == StatusTone.success
                              ? AppColors.secondary
                              : AppColors.error,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyFinanceInsight(String msg) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('AI önerisi analiz ediliyor...'),
          duration: Duration(seconds: 1),
        ),
      );
    try {
      final result = await ApiService.instance.sendChat(
        message: 'Bu finans önerisini detaylandır ve somut adımlar öner: $msg',
      );
      if (!mounted) return;
      final response = result.response.isNotEmpty
          ? result.response
          : 'Detay alınamadı.';
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('AI Öneri Detayı'),
          content: SingleChildScrollView(
            child: SelectableText(
              response,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Öneri detayı alınamadı: $e')));
      }
    }
  }

  Future<void> _showReminderMessage(OverduePaymentMock payment) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${payment.customerName} için hatırlatma taslağı oluşturuluyor...',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    try {
      final result = await ApiService.instance.sendChat(
        message:
            '${payment.customerName} için ödeme hatırlatma mesajı yaz. Resmi ama nazik bir dille, ödeme tutarını ve gecikme süresini belirt. Tutar: ${payment.amount}. Gecikme: ${payment.delay}.',
      );
      if (!mounted) return;
      final response = result.response.isNotEmpty
          ? result.response
          : 'Taslak oluşturulamadı.';

      // Hatırlatma taslağı dialog'u — tarih seçici ve kaydet butonu ile
      DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

      showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${payment.customerName} — Hatırlatma',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hatırlatma Metni:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: SelectableText(
                      response,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hatırlatma Tarihi:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        helpText: 'Hatırlatma tarihi seçin',
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Değiştir',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('İptal'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  // Backend'e uyarı/hatırlatma olarak kaydet
                  try {
                    await ApiService.instance.createPaymentReminder(
                      customerName: payment.customerName,
                      reminderDate: selectedDate,
                      draftText: response,
                      amount: payment.amount,
                      delay: payment.delay,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text('Hatırlatma kaydedilemedi: $e'),
                          ),
                        );
                    }
                    return;
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            '${payment.customerName} için ${selectedDate.day}.${selectedDate.month}.${selectedDate.year} tarihine hatırlatma kaydedildi.',
                          ),
                        ),
                      );
                  }
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Hatırlatmayı Kaydet'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Hatırlatma taslağı oluşturulamadı: $e')),
          );
      }
    }
  }
}

class _FinanceIntroCard extends StatelessWidget {
  const _FinanceIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Finans ve KDV',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gelir, gider, KDV ve nakit akışınızı takip edin.',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondaryContainer,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI destekli özetlerle finansal riskleri önceden görün.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceRiskStrip extends StatelessWidget {
  const _FinanceRiskStrip({
    required this.overdueCount,
    required this.profitMargin,
    required this.kdvPayable,
  });

  final int overdueCount;
  final double profitMargin;
  final String kdvPayable;

  @override
  Widget build(BuildContext context) {
    final nakitTone = profitMargin < 0.10
        ? StatusTone.danger
        : profitMargin < 0.20
        ? StatusTone.warning
        : StatusTone.success;
    final nakitLabel = profitMargin < 0.10
        ? 'Yüksek'
        : profitMargin < 0.20
        ? 'Orta'
        : 'Düşük';

    final kdvTone = kdvPayable.contains('0') && kdvPayable.length <= 3
        ? StatusTone.success
        : StatusTone.warning;

    final tahsilatTone = overdueCount == 0
        ? StatusTone.success
        : overdueCount > 3
        ? StatusTone.danger
        : StatusTone.warning;

    final items = [
      ('Nakit Riski', nakitLabel, nakitTone),
      ('KDV Durumu', kdvPayable == '0 TL' ? 'Temiz' : 'Takip', kdvTone),
      (
        'Tahsilat',
        overdueCount > 0 ? '$overdueCount Geciken' : 'Temiz',
        tahsilatTone,
      ),
    ];

    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: Container(
              height: 82,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: StatusBadge(
                      label: items[index].$2,
                      tone: items[index].$3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _FinanceSummaryStrip extends StatelessWidget {
  const _FinanceSummaryStrip({required this.summaries});

  final List<FinanceSummaryMock> summaries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: summaries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _FinanceSummaryTile(summary: summaries[index]),
      ),
    );
  }
}

class _FinanceSummaryTile extends StatelessWidget {
  const _FinanceSummaryTile({required this.summary});

  final FinanceSummaryMock summary;

  @override
  Widget build(BuildContext context) {
    final trendColor = switch (summary.trendTone) {
      StatusTone.success => AppColors.secondary,
      StatusTone.warning => AppColors.error,
      StatusTone.danger => AppColors.error,
      StatusTone.info => AppColors.primary,
      StatusTone.neutral => AppColors.mutedText,
    };

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.title,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                summary.title == 'Ödenecek KDV'
                    ? Icons.schedule
                    : Icons.trending_up,
                color: trendColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _shortTrend(summary),
                style: TextStyle(
                  color: trendColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortTrend(FinanceSummaryMock summary) {
    if (summary.title == 'Ödenecek KDV') {
      return '26 Gün';
    }

    return summary.trend
        .replaceAll('+18,4%', '%12')
        .replaceAll('+9,7%', '%8')
        .replaceAll('+12,1%', '%4');
  }
}
