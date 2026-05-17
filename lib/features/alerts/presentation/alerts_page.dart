import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/status_badge.dart';
import 'alerts_mock_data.dart';
import 'widgets/alert_filter_chips.dart';
import 'widgets/alerts_list_card.dart';
import 'widgets/alerts_side_panel.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> {
  AlertFilter _selectedFilter = AlertFilter.all;
  List<AlertMock> _alerts = [];
  bool _apiLoaded = false;
  String _dailySummary = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    try {
      final data = await ApiService.instance.getAlerts();
      if (!mounted) return;
      final now = DateTime.now();
      final mapped = data.map<AlertMock>((raw) {
        final m = raw as Map<String, dynamic>;
        final tarihStr = m['tarih'] as String?;
        final tarih = tarihStr != null ? DateTime.tryParse(tarihStr) : null;

        String timeLabel;
        if (tarih == null) {
          timeLabel = 'Az önce';
        } else {
          final diff = now.difference(tarih);
          if (diff.inMinutes < 60) {
            timeLabel = '${diff.inMinutes} dakika önce';
          } else if (diff.inHours < 24) {
            timeLabel = '${diff.inHours} saat önce';
          } else {
            timeLabel = '${diff.inDays} gün önce';
          }
        }

        return AlertMock(
          id: m['id']?.toString() ?? UniqueKey().toString(),
          title: m['baslik'] as String? ?? '',
          description: m['mesaj'] as String? ?? '',
          category: _mapCategory(m['tur'] as String? ?? ''),
          priority: _mapPriority(m['oncelik'] as String? ?? 'normal'),
          status: (m['okundu'] == true)
              ? AlertStatus.resolved
              : AlertStatus.active,
          recommendedAction: 'Aksiyona Al',
          timeLabel: timeLabel,
        );
      }).toList();

      // Gerçek veriden günlük özet oluştur
      final kritikSayi = mapped.where((a) => a.priority == AlertPriority.critical && a.status == AlertStatus.active).length;
      final aktifSayi = mapped.where((a) => a.status == AlertStatus.active).length;
      final kategoriler = <String>{};
      for (final a in mapped.where((a) => a.status == AlertStatus.active).take(3)) {
        kategoriler.add(a.category.label);
      }
      final liveSummary = aktifSayi > 0
          ? 'Bugün $aktifSayi aktif uyarı mevcut${kritikSayi > 0 ? ' ($kritikSayi kritik)' : ''}. '
            'Öncelikli konular: ${kategoriler.join(', ')}.'
          : 'Tüm uyarılar çözüldü, aktif sorun bulunmuyor.';

      setState(() {
        _alerts = mapped;
        _apiLoaded = true;
        _dailySummary = liveSummary;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  AlertCategory _mapCategory(String tur) {
    if (tur.contains('stok')) return AlertCategory.stock;
    if (tur.contains('kdv') || tur.contains('vergi')) return AlertCategory.kdv;
    if (tur.contains('nakit') || tur.contains('odeme')) return AlertCategory.finance;
    if (tur.contains('puantaj') || tur.contains('calisan')) return AlertCategory.employees;
    if (tur.contains('belge') || tur.contains('fatura')) return AlertCategory.document;
    return AlertCategory.stock;
  }

  AlertPriority _mapPriority(String oncelik) {
    switch (oncelik) {
      case 'kritik': return AlertPriority.critical;
      case 'yuksek': return AlertPriority.high;
      case 'dusuk': return AlertPriority.low;
      default: return AlertPriority.medium;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final visibleAlerts = _filteredAlerts();
    final critikSayi = _alerts.where((a) => a.priority == AlertPriority.critical && a.status == AlertStatus.active).length;
    final toplamAktif = _alerts.where((a) => a.status == AlertStatus.active).length;

    final cozulenSayi = _alerts.where((a) => a.status == AlertStatus.resolved).length;
    final bekleyenSayi = _alerts.where((a) => a.status == AlertStatus.active && a.priority != AlertPriority.critical).length;

    // Tüm summary kartları gerçek veriden
    final liveSummaries = [
      AlertSummaryMock(
        title: 'Aktif Uyarı',
        value: '$toplamAktif',
        description: 'Çözüm bekleyen uyarılar',
        trend: 'Bekliyor',
        trendTone: toplamAktif > 3 ? StatusTone.danger : StatusTone.warning,
        icon: Icons.notifications_active_outlined,
        accentColor: AppColors.primary,
      ),
      AlertSummaryMock(
        title: 'Kritik Risk',
        value: '$critikSayi',
        description: 'Acil aksiyon gerektirir',
        trend: critikSayi > 0 ? 'Acil' : 'Temiz',
        trendTone: critikSayi > 0 ? StatusTone.danger : StatusTone.success,
        icon: Icons.warning_amber_outlined,
        accentColor: AppColors.rose,
      ),
      AlertSummaryMock(
        title: 'Bekleyen Onay',
        value: '$bekleyenSayi',
        description: 'Kullanıcı onayı bekliyor',
        trend: bekleyenSayi > 0 ? 'İncelenmeli' : 'Temiz',
        trendTone: bekleyenSayi > 0 ? StatusTone.info : StatusTone.success,
        icon: Icons.rule_folder_outlined,
        accentColor: AppColors.amber,
      ),
      AlertSummaryMock(
        title: 'Çözülen Uyarı',
        value: '$cozulenSayi',
        description: 'Bu dönem tamamlandı',
        trend: cozulenSayi > 0 ? '+$cozulenSayi' : '—',
        trendTone: StatusTone.success,
        icon: Icons.task_alt_outlined,
        accentColor: AppColors.emerald,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AlertsIntroCard(),
        const SizedBox(height: 16),
        _AlertSummaryStrip(summaries: liveSummaries),
        const SizedBox(height: 16),
        AlertFilterChips(
          selectedFilter: _selectedFilter,
          onSelected: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        ),
        const SizedBox(height: 16),
        _DailySummaryCard(summary: _dailySummary),
        const SizedBox(height: 16),
        AlertsListCard(
          alerts: visibleAlerts,
          onStartAction: _startAction,
          onResolve: _resolveAlert,
          onIgnore: _ignoreAlert,
        ),
        const SizedBox(height: 16),
        if (_alerts.any((a) => a.status == AlertStatus.resolved))
          _ResolvedAlertStrip(
            alert: _alerts.firstWhere(
              (alert) => alert.status == AlertStatus.resolved,
            ),
          ),
        const SizedBox(height: 16),
        AlertsSidePanel(
          priorityDistribution: _buildPriorityDistribution(),
          categoryDistribution: _buildCategoryDistribution(),
          dailySummary: _dailySummary,
        ),
      ],
    );
  }

  List<AlertMock> _filteredAlerts() {
    final nonIgnored = _alerts
        .where((alert) => alert.status != AlertStatus.ignored)
        .toList(growable: false);

    return switch (_selectedFilter) {
      AlertFilter.all =>
        nonIgnored
            .where((alert) => alert.status == AlertStatus.active)
            .toList(growable: false),
      AlertFilter.critical =>
        nonIgnored
            .where((alert) => alert.priority == AlertPriority.critical)
            .toList(growable: false),
      AlertFilter.stock => _filterByCategory(nonIgnored, AlertCategory.stock),
      AlertFilter.finance => _filterByCategory(
        nonIgnored,
        AlertCategory.finance,
      ),
      AlertFilter.kdv => _filterByCategory(nonIgnored, AlertCategory.kdv),
      AlertFilter.employees => _filterByCategory(
        nonIgnored,
        AlertCategory.employees,
      ),
      AlertFilter.document => _filterByCategory(
        nonIgnored,
        AlertCategory.document,
      ),
      AlertFilter.resolved =>
        nonIgnored
            .where((alert) => alert.status == AlertStatus.resolved)
            .toList(growable: false),
    };
  }

  List<AlertMock> _filterByCategory(
    List<AlertMock> alerts,
    AlertCategory category,
  ) {
    return alerts
        .where((alert) => alert.category == category)
        .toList(growable: false);
  }

  List<AlertDistributionMock> _buildPriorityDistribution() {
    final active = _alerts.where((a) => a.status == AlertStatus.active);
    return [
      AlertDistributionMock(label: 'Kritik', value: '${active.where((a) => a.priority == AlertPriority.critical).length}', tone: StatusTone.danger),
      AlertDistributionMock(label: 'Yüksek', value: '${active.where((a) => a.priority == AlertPriority.high).length}', tone: StatusTone.warning),
      AlertDistributionMock(label: 'Orta', value: '${active.where((a) => a.priority == AlertPriority.medium).length}', tone: StatusTone.warning),
      AlertDistributionMock(label: 'Düşük', value: '${active.where((a) => a.priority == AlertPriority.low).length}', tone: StatusTone.info),
    ];
  }

  List<AlertDistributionMock> _buildCategoryDistribution() {
    final active = _alerts.where((a) => a.status == AlertStatus.active);
    return [
      AlertDistributionMock(label: 'Stok', value: '${active.where((a) => a.category == AlertCategory.stock).length}', tone: StatusTone.info),
      AlertDistributionMock(label: 'Finans', value: '${active.where((a) => a.category == AlertCategory.finance).length}', tone: StatusTone.success),
      AlertDistributionMock(label: 'KDV', value: '${active.where((a) => a.category == AlertCategory.kdv).length}', tone: StatusTone.warning),
      AlertDistributionMock(label: 'Puantaj', value: '${active.where((a) => a.category == AlertCategory.employees).length}', tone: StatusTone.neutral),
      AlertDistributionMock(label: 'Belge', value: '${active.where((a) => a.category == AlertCategory.document).length}', tone: StatusTone.info),
    ];
  }

  Future<void> _startAction(AlertMock alert) async {
    if (_apiLoaded) {
      try {
        await ApiService.instance.markAlertActionTaken(int.tryParse(alert.id) ?? 0);
      } catch (_) {}
    }

    if (!mounted) return;

    // Uyarı tipine göre somut aksiyon dialog'u göster
    switch (alert.category) {
      case AlertCategory.stock:
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Stok Aksiyonu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(alert.description),
                const SizedBox(height: 12),
                const Text('Önerilen Aksiyon:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(alert.recommendedAction),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF95D4B3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Color(0xFF2C694E)),
                      SizedBox(width: 8),
                      Expanded(child: Text('Stok Yönetimi sayfasından tedarikçi karşılaştırması yapabilirsiniz.', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resolveAlert(alert);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF002045)),
                child: const Text('Çözüldü Olarak İşaretle'),
              ),
            ],
          ),
        );
      case AlertCategory.finance:
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Finans Aksiyonu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(alert.description),
                const SizedBox(height: 12),
                const Text('Önerilen Aksiyon:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(alert.recommendedAction),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCD9BD)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Color(0xFFC6955E)),
                      SizedBox(width: 8),
                      Expanded(child: Text('Finans sayfasından gecikmiş ödemeler için hatırlatma taslağı oluşturabilirsiniz.', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resolveAlert(alert);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF002045)),
                child: const Text('Çözüldü Olarak İşaretle'),
              ),
            ],
          ),
        );
      case AlertCategory.kdv:
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('KDV Aksiyonu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(alert.description),
                const SizedBox(height: 12),
                Text(alert.recommendedAction),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, size: 16, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Expanded(child: Text('Finans sayfasındaki KDV özet kartından detaylı bilgi alabilirsiniz.', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resolveAlert(alert);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF002045)),
                child: const Text('Çözüldü Olarak İşaretle'),
              ),
            ],
          ),
        );
      default:
        // employees, document ve diğerleri için genel aksiyon dialog'u
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('${alert.category.label} Aksiyonu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(alert.description),
                const SizedBox(height: 12),
                const Text('Önerilen Aksiyon:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(alert.recommendedAction),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resolveAlert(alert);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF002045)),
                child: const Text('Çözüldü Olarak İşaretle'),
              ),
            ],
          ),
        );
    }

    _fetchAlerts();
  }

  Future<void> _resolveAlert(AlertMock alert) async {
    if (_apiLoaded) {
      try {
        await ApiService.instance.markAlertAsRead(int.tryParse(alert.id) ?? 0);
      } catch (_) {}
    }
    setState(() {
      _alerts = _alerts
          .map(
            (item) => item.id == alert.id
                ? item.copyWith(status: AlertStatus.resolved)
                : item,
          )
          .toList(growable: false);
    });
    _showMessage('Uyarı çözüldü olarak işaretlendi.');
    _fetchAlerts();
  }

  void _ignoreAlert(AlertMock alert) {
    setState(() {
      _alerts = _alerts
          .map(
            (item) => item.id == alert.id
                ? item.copyWith(status: AlertStatus.ignored)
                : item,
          )
          .toList(growable: false);
    });
    _showMessage('Uyarı yok sayıldı.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AlertsIntroCard extends StatelessWidget {
  const _AlertsIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF002045), width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Proaktif riskleri ve bekleyen aksiyonları yönetin.',
                style: TextStyle(
                  color: Color(0xFF191C1D),
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.notifications_active,
              color: Color(0xFF002045),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertSummaryStrip extends StatelessWidget {
  const _AlertSummaryStrip({required this.summaries});

  final List<AlertSummaryMock> summaries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: summaries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _SummaryTile(summary: summaries[index]);
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.summary});

  final AlertSummaryMock summary;

  @override
  Widget build(BuildContext context) {
    final critical = summary.trendTone == StatusTone.danger;
    final success = summary.trendTone == StatusTone.success;
    final color = critical
        ? const Color(0xFFBA1A1A)
        : success
        ? const Color(0xFF2C694E)
        : const Color(0xFF002045);

    return Container(
      width: 142,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: critical
            ? const Color(0xFFFFDAD6)
            : success
            ? const Color(0xFFAEEECB)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: critical
              ? const Color(0xFFBA1A1A)
              : success
              ? const Color(0xFF2C694E)
              : const Color(0xFFC4C6CF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.title == 'Çözülen Uyarı' ? 'Çözülen' : summary.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: critical
                  ? const Color(0xFF93000A)
                  : const Color(0xFF43474E),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            summary.value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            _subtitle(summary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: critical
                  ? const Color(0xFF93000A)
                  : const Color(0xFF43474E),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(AlertSummaryMock summary) {
    return switch (summary.title) {
      'Aktif Uyarı' => 'Çözüm bekliyor',
      'Kritik Risk' => 'Acil aksiyon',
      'Çözülen Uyarı' => 'Bu ay',
      _ => summary.trend,
    };
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF2C694E), width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF2C694E), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Günlük Özeti',
                    style: TextStyle(
                      color: Color(0xFF2C694E),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    summary,
                    style: const TextStyle(
                      color: Color(0xFF43474E),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolvedAlertStrip extends StatelessWidget {
  const _ResolvedAlertStrip({required this.alert});

  final AlertMock alert;

  void _showDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(alert.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(label: alert.category.label, tone: alert.category.tone),
                const SizedBox(width: 8),
                StatusBadge(label: alert.priority.label, tone: alert.priority.tone),
                const SizedBox(width: 8),
                const StatusBadge(label: 'ÇÖZÜLDÜ', tone: StatusTone.success),
              ],
            ),
            const SizedBox(height: 14),
            Text(alert.description, style: const TextStyle(fontSize: 14, height: 1.45)),
            const SizedBox(height: 10),
            const Text('Önerilen Aksiyon:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 4),
            Text(alert.recommendedAction, style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 10),
            Text('Zaman: ${alert.timeLabel}', style: const TextStyle(fontSize: 12, color: Color(0xFF43474E))),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEEF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC4C6CF),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF2C694E),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF43474E), fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          const StatusBadge(label: 'ÇÖZÜLDÜ', tone: StatusTone.success),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () => _showDetail(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF002045),
              padding: EdgeInsets.zero,
              minimumSize: const Size(42, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Detayı Gör',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
