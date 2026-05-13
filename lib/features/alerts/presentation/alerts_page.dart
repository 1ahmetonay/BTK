import 'package:flutter/material.dart';

import '../../../shared/widgets/status_badge.dart';
import 'alerts_mock_data.dart';
import 'widgets/alert_filter_chips.dart';
import 'widgets/alerts_list_card.dart';
import 'widgets/alerts_side_panel.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  AlertFilter _selectedFilter = AlertFilter.all;
  late List<AlertMock> _alerts;

  @override
  void initState() {
    super.initState();
    _alerts = List<AlertMock>.of(AlertsMockData.initialAlerts);
  }

  @override
  Widget build(BuildContext context) {
    final visibleAlerts = _filteredAlerts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AlertsIntroCard(),
        const SizedBox(height: 16),
        const _AlertSummaryStrip(summaries: AlertsMockData.summaries),
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
        const _DailySummaryCard(summary: AlertsMockData.dailySummary),
        const SizedBox(height: 16),
        AlertsListCard(
          alerts: visibleAlerts,
          onStartAction: _startAction,
          onResolve: _resolveAlert,
          onIgnore: _ignoreAlert,
        ),
        const SizedBox(height: 16),
        _ResolvedAlertStrip(
          alert: _alerts.firstWhere(
            (alert) => alert.status == AlertStatus.resolved,
            orElse: () => AlertsMockData.initialAlerts.last,
          ),
        ),
        const SizedBox(height: 16),
        const AlertsSidePanel(
          priorityDistribution: AlertsMockData.priorityDistribution,
          categoryDistribution: AlertsMockData.categoryDistribution,
          dailySummary: AlertsMockData.dailySummary,
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

  void _startAction(AlertMock alert) {
    _showMessage('${alert.title} uyarısı için aksiyon başlatıldı.');
  }

  void _resolveAlert(AlertMock alert) {
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
            onPressed: () {},
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
