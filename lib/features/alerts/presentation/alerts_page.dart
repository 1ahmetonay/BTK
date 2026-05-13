import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/mobile_stat_strip.dart';
import '../../../shared/widgets/stat_card.dart';
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
        const SectionCard(
          title: 'Uyarılar',
          subtitle:
              'Stok, finans, KDV, puantaj ve belge işleme süreçlerinden gelen proaktif uyarıları tek yerden yönetin.',
          child: Text(
            'Demo modunda uyarılar yerel mock veriyle üretilir; aksiyonlar ve durum değişiklikleri yalnızca ekranda tutulur.',
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return MobileStatStrip(
                children: AlertsMockData.summaries
                    .map(
                      (summary) => MobileStatTile(
                        title: summary.title,
                        value: summary.value,
                        trend: summary.trend,
                        trendTone: summary.trendTone,
                        icon: summary.icon,
                        accentColor: summary.accentColor,
                      ),
                    )
                    .toList(),
              );
            }

            final columns = constraints.maxWidth >= 1200
                ? 4
                : constraints.maxWidth >= 720
                    ? 2
                    : 1;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 1 ? 2.25 : 1.25,
              children: AlertsMockData.summaries
                  .map(
                    (summary) => StatCard(
                      title: summary.title,
                      value: summary.value,
                      description: summary.description,
                      trend: summary.trend,
                      trendTone: summary.trendTone,
                      icon: summary.icon,
                      accentColor: summary.accentColor,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Uyarı Filtreleri',
          subtitle: 'Kategori, öncelik veya çözülen uyarılara göre görünümü daraltın',
          child: AlertFilterChips(
            selectedFilter: _selectedFilter,
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1080;

            if (!isWide) {
              return Column(
                children: [
                  AlertsListCard(
                    alerts: visibleAlerts,
                    onStartAction: _startAction,
                    onResolve: _resolveAlert,
                    onIgnore: _ignoreAlert,
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

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: AlertsListCard(
                    alerts: visibleAlerts,
                    onStartAction: _startAction,
                    onResolve: _resolveAlert,
                    onIgnore: _ignoreAlert,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  flex: 3,
                  child: AlertsSidePanel(
                    priorityDistribution: AlertsMockData.priorityDistribution,
                    categoryDistribution: AlertsMockData.categoryDistribution,
                    dailySummary: AlertsMockData.dailySummary,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<AlertMock> _filteredAlerts() {
    final nonIgnored = _alerts
        .where((alert) => alert.status != AlertStatus.ignored)
        .toList(growable: false);

    return switch (_selectedFilter) {
      AlertFilter.all => nonIgnored,
      AlertFilter.critical => nonIgnored
          .where((alert) => alert.priority == AlertPriority.critical)
          .toList(growable: false),
      AlertFilter.stock => _filterByCategory(nonIgnored, AlertCategory.stock),
      AlertFilter.finance => _filterByCategory(nonIgnored, AlertCategory.finance),
      AlertFilter.kdv => _filterByCategory(nonIgnored, AlertCategory.kdv),
      AlertFilter.employees => _filterByCategory(nonIgnored, AlertCategory.employees),
      AlertFilter.document => _filterByCategory(nonIgnored, AlertCategory.document),
      AlertFilter.resolved => nonIgnored
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
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
