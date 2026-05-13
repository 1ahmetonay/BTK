import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/status_badge.dart';
import 'dashboard_mock_data.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    this.onNavigate,
    super.key,
  });

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WelcomeCard(),
        const SizedBox(height: 22),
        const _StatsStrip(),
        const SizedBox(height: 22),
        const _MorningBriefingCard(),
        const SizedBox(height: 22),
        _QuickActions(onNavigate: onNavigate),
        const SizedBox(height: 22),
        const _PriorityAlerts(),
        const SizedBox(height: 22),
        const _AiRecommendations(),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DashboardColors {
  const _DashboardColors._();

  static const primary = Color(0xFF002045);
  static const secondary = Color(0xFF2C694E);
  static const secondaryContainer = Color(0xFFB1F0CE);
  static const onSecondaryContainer = Color(0xFF0E5138);
  static const outline = Color(0xFFC4C6CF);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFF43474E);
  static const error = Color(0xFFBA1A1A);
  static const warning = Color(0xFFC6955E);
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: _DashboardColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günaydın',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _DashboardColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bugün 3 öncelikli konu var',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF191C1D),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kritik stok, nakit riski ve KDV son tarihi takip edilmeli.',
                      style: TextStyle(
                        color: _DashboardColors.muted,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: DashboardMockData.stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 142,
            child: _StatTile(data: DashboardMockData.stats[index]),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final DashboardStatData data;

  @override
  Widget build(BuildContext context) {
    final isCritical =
        data.title == 'Kritik Stok' || data.changeTone == StatusTone.warning;
    final foreground = isCritical ? _DashboardColors.error : data.accentColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 22, color: foreground),
          const Spacer(),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _DashboardColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground == _DashboardColors.error
                  ? _DashboardColors.error
                  : _DashboardColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isCritical ? Icons.warning_amber_outlined : Icons.trending_up,
                size: 16,
                color: isCritical
                    ? _DashboardColors.error
                    : _DashboardColors.secondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  isCritical ? data.statusLabelForDashboard : data.changeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCritical
                        ? _DashboardColors.error
                        : _DashboardColors.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on DashboardStatData {
  String get statusLabelForDashboard {
    if (title == 'Bekleyen Ödeme') {
      return 'Vade bekliyor';
    }
    return 'Düşük';
  }
}

class _MorningBriefingCard extends StatelessWidget {
  const _MorningBriefingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: _DashboardColors.primary),
              SizedBox(width: 8),
              Text(
                'Sabah Brifingi',
                style: TextStyle(
                  color: _DashboardColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BriefLine(
            icon: Icons.error_outline,
            iconColor: _DashboardColors.error,
            text: '${DashboardMockData.stockAlerts.first.productName} kritik '
                'seviyede: ${DashboardMockData.stockAlerts.first.quantity} kaldı.',
          ),
          const SizedBox(height: 14),
          const _BriefLine(
            icon: Icons.schedule_outlined,
            iconColor: _DashboardColors.warning,
            text: '14 gün sonra 42.000 TL nakit açığı riski var.',
          ),
          const SizedBox(height: 14),
          const _BriefLine(
            icon: Icons.event_outlined,
            iconColor: _DashboardColors.primary,
            text: 'KDV beyanname son tarihi: 26 Mayıs.',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: _DashboardColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Detaylı Brifingi Aç'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BriefLine extends StatelessWidget {
  const _BriefLine({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _DashboardColors.muted,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    void go(String route) => onNavigate?.call(route);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.camera_alt_outlined,
                label: 'Belge Tara',
                onTap: () => go(AppRoutes.documents),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionTile(
                icon: Icons.inventory_2_outlined,
                label: 'Stok Kontrol',
                onTap: () => go(AppRoutes.stock),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionTile(
                icon: Icons.smart_toy_outlined,
                label: 'AI’a Sor',
                emphasized: true,
                onTap: () => go(AppRoutes.chat),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.badge_outlined,
                label: 'Puantaj',
                onTap: () => go(AppRoutes.employees),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _ActionTile(
                icon: Icons.notifications_active_outlined,
                label: 'Bekleyen Uyarılar',
                horizontal: true,
                onTap: () => go(AppRoutes.alerts),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasized = false,
    this.horizontal = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasized;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final foreground = emphasized
        ? _DashboardColors.onSecondaryContainer
        : const Color(0xFF191C1D);

    return Material(
      color:
          emphasized ? _DashboardColors.secondaryContainer : _DashboardColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _DashboardColors.outline),
          ),
          child: horizontal
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: foreground),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: foreground),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 12,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PriorityAlerts extends StatelessWidget {
  const _PriorityAlerts();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Öncelikli Uyarılar',
          style: TextStyle(
            color: _DashboardColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 14),
        _AlertCard(
          category: 'Stok Uyarısı',
          title: 'Türk Kahvesi 250g kritik seviye',
          badge: 'KRİTİK',
          tone: StatusTone.danger,
        ),
        SizedBox(height: 8),
        _AlertCard(
          category: 'Finans Uyarısı',
          title: 'Nakit açığı riski',
          badge: 'KRİTİK',
          tone: StatusTone.danger,
        ),
        SizedBox(height: 8),
        _AlertCard(
          category: 'KDV',
          title: 'KDV son tarihi yaklaşıyor',
          badge: 'YÜKSEK',
          tone: StatusTone.warning,
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.category,
    required this.title,
    required this.badge,
    required this.tone,
  });

  final String category;
  final String title;
  final String badge;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final danger = tone == StatusTone.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFFF8F8) : const Color(0xFFF1EEE8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: danger ? const Color(0xFFF2B8B5) : const Color(0xFFD8C7B3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: _DashboardColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color:
                  danger ? _DashboardColors.error : _DashboardColors.warning,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiRecommendations extends StatelessWidget {
  const _AiRecommendations();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: _DashboardColors.secondary),
            SizedBox(width: 8),
            Text(
              'AI Önerileri',
              style: TextStyle(
                color: _DashboardColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final suggestion in DashboardMockData.aiSuggestions) ...[
          _AiSuggestionCard(message: suggestion.message),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _DashboardColors.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(color: _DashboardColors.secondary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 3, height: 74, color: _DashboardColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: _DashboardColors.muted,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: _DashboardColors.secondary,
                  ),
                  label: const Text('Uygula'),
                  icon: const Icon(Icons.chevron_right, size: 18),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: _DashboardColors.surface,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: _DashboardColors.outline),
  );
}
