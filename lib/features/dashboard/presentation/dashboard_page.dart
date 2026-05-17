import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/status_badge.dart';
import 'dashboard_mock_data.dart';

/// Helper: API verisinden stat kartlarını oluşturur
List<DashboardStatData> _buildStatsFromApi(Map<String, dynamic> stats) {
  final toplam = stats['toplam_sku'] ?? 0;
  final kritik = stats['kritik_stok'] ?? 0;
  final bakiye = stats['mevcut_bakiye'] ?? 0;
  final stokDegeri = stats['stok_degeri'] ?? 0;
  final bekleyenOdeme = stats['bekleyen_odeme'] ?? 0;
  final kdv = stats['odenecek_kdv'] ?? 0;

  String formatTL(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M TL';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K TL';
    return '${v.toStringAsFixed(0)} TL';
  }

  return [
    DashboardStatData(
      title: 'Stok Değeri',
      value: formatTL(stokDegeri),
      description: '$toplam aktif SKU',
      changeLabel: '$toplam SKU',
      changeTone: StatusTone.success,
      icon: Icons.payments_outlined,
      accentColor: const Color(0xFF002045),
    ),
    DashboardStatData(
      title: 'Nakit Bakiye',
      value: formatTL(bakiye),
      description: 'Mevcut kasa durumu',
      changeLabel: bakiye > 0 ? 'Pozitif' : 'Negatif',
      changeTone: bakiye > 0 ? StatusTone.success : StatusTone.danger,
      icon: Icons.account_balance_wallet_outlined,
      accentColor: const Color(0xFF2C694E),
    ),
    DashboardStatData(
      title: 'Kritik Stok',
      value: '$kritik ürün',
      description: 'Min seviye altında',
      changeLabel: kritik > 0 ? 'Dikkat' : 'İyi',
      changeTone: kritik > 0 ? StatusTone.warning : StatusTone.success,
      icon: Icons.inventory_2_outlined,
      accentColor: const Color(0xFFC6955E),
    ),
    DashboardStatData(
      title: 'Bekleyen Ödeme',
      value: formatTL(bekleyenOdeme),
      description: 'KDV: ${formatTL(kdv)}',
      changeLabel: bekleyenOdeme > 0 ? 'Vadeli' : 'Temiz',
      changeTone: bekleyenOdeme > 0 ? StatusTone.danger : StatusTone.success,
      icon: Icons.receipt_long_outlined,
      accentColor: const Color(0xFFBA1A1A),
    ),
  ];
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    this.onNavigate,
    super.key,
  });

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(dashboardSummaryProvider);

    return dashboardDataAsync.when(
      data: (data) {
        final brief = data['sabah_brifingi'] ?? 'Günaydın! Verileriniz yükleniyor...';
        final stats = data['stats'] as Map<String, dynamic>? ?? {};
        final kritikStoklar = data['kritik_stoklar'] as List<dynamic>? ?? [];
        final gecikOdemeler = data['gecikmis_odemeler'] as List<dynamic>? ?? [];
        final apiStats = _buildStatsFromApi(stats);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeCard(briefing: brief),
            const SizedBox(height: 22),
            _StatsStrip(stats: apiStats),
            const SizedBox(height: 22),
            _MorningBriefingCard(
              kritikStoklar: kritikStoklar,
              gecikOdemeler: gecikOdemeler,
              kdvOzet: data['kdv_ozet'] as Map<String, dynamic>? ?? {},
              fullBriefText: brief,
            ),
            const SizedBox(height: 22),
            _QuickActions(onNavigate: onNavigate),
            const SizedBox(height: 22),
            _PriorityAlerts(
              kritikStoklar: kritikStoklar,
              gecikOdemeler: gecikOdemeler,
            ),
            const SizedBox(height: 22),
            _AiRecommendations(onNavigate: onNavigate),
            const SizedBox(height: 12),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _WelcomeCard(briefing: 'Backend bağlantısı kurulamadı. Lütfen sunucuyu başlatın.'),
            const SizedBox(height: 22),
            const _StatsStrip(stats: []),
            const SizedBox(height: 22),
            _QuickActions(onNavigate: onNavigate),
            const SizedBox(height: 12),
          ],
        );
      },
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
  const _WelcomeCard({required this.briefing});

  final String briefing;

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
                      'AI Sabah Brifingi',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _DashboardColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      briefing,
                      style: const TextStyle(
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
  const _StatsStrip({required this.stats});

  final List<DashboardStatData> stats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 142,
            child: _StatTile(data: stats[index]),
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

void _showFullBrief(BuildContext context, String briefText) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF002045),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Günlük AI Brifing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SelectableText(
                  briefText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF002045),
                  ),
                  child: const Text('Kapat'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MorningBriefingCard extends StatelessWidget {
  const _MorningBriefingCard({
    required this.kritikStoklar,
    required this.gecikOdemeler,
    required this.kdvOzet,
    this.fullBriefText,
  });

  final List<dynamic> kritikStoklar;
  final List<dynamic> gecikOdemeler;
  final Map<String, dynamic> kdvOzet;
  final String? fullBriefText;

  @override
  Widget build(BuildContext context) {
    // Gerçek veriden brief satırları oluştur
    final firstCritical = kritikStoklar.isNotEmpty
        ? kritikStoklar.first as Map<String, dynamic>
        : null;
    final stokText = firstCritical != null
        ? '${firstCritical['isim'] ?? 'Ürün'} kritik seviyede: ${firstCritical['mevcut_stok'] ?? '?'} adet kaldı.'
        : 'Stok seviyeleri kontrol altında.';

    final odemeText = gecikOdemeler.isNotEmpty
        ? '${gecikOdemeler.length} adet gecikmiş ödeme mevcut.'
        : 'Gecikmiş ödeme bulunmuyor.';

    final kdvSonTarih = kdvOzet['beyanname_son_tarihi'] ?? '—';
    final kdvText = 'KDV beyanname son tarihi: $kdvSonTarih';

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
            text: stokText,
          ),
          const SizedBox(height: 14),
          _BriefLine(
            icon: Icons.schedule_outlined,
            iconColor: _DashboardColors.warning,
            text: odemeText,
          ),
          const SizedBox(height: 14),
          _BriefLine(
            icon: Icons.event_outlined,
            iconColor: _DashboardColors.primary,
            text: kdvText,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: fullBriefText != null && fullBriefText!.isNotEmpty
                  ? () => _showFullBrief(context, fullBriefText!)
                  : null,
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
  const _PriorityAlerts({
    required this.kritikStoklar,
    required this.gecikOdemeler,
  });

  final List<dynamic> kritikStoklar;
  final List<dynamic> gecikOdemeler;

  @override
  Widget build(BuildContext context) {
    final alerts = <Widget>[];

    // Kritik stok uyarıları
    for (final item in kritikStoklar.take(3)) {
      final m = item as Map<String, dynamic>;
      alerts.add(_AlertCard(
        category: 'Stok Uyarısı',
        title: '${m['isim'] ?? 'Ürün'} — ${m['mevcut_stok'] ?? '?'} adet kaldı',
        badge: 'KRİTİK',
        tone: StatusTone.danger,
      ));
      alerts.add(const SizedBox(height: 8));
    }

    // Gecikmiş ödeme uyarıları
    for (final item in gecikOdemeler.take(2)) {
      final m = item as Map<String, dynamic>;
      alerts.add(_AlertCard(
        category: 'Finans Uyarısı',
        title: '${m['karsi_taraf'] ?? 'Ödeme'} — ${m['gecikme_gun'] ?? '?'} gün gecikmiş',
        badge: 'YÜKSEK',
        tone: StatusTone.warning,
      ));
      alerts.add(const SizedBox(height: 8));
    }

    if (alerts.isEmpty) {
      alerts.add(const _AlertCard(
        category: 'Bilgi',
        title: 'Aktif uyarı bulunmuyor',
        badge: 'İYİ',
        tone: StatusTone.success,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Öncelikli Uyarılar',
          style: TextStyle(
            color: _DashboardColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ...alerts,
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

class _AiRecommendations extends ConsumerWidget {
  const _AiRecommendations({this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(_aiSuggestionsProvider);

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
        suggestionsAsync.when(
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return _AiSuggestionCard(message: 'Şu an aktif öneri bulunmuyor.', onNavigate: onNavigate);
            }
            return Column(
              children: [
                for (final s in suggestions) ...[
                  _AiSuggestionCard(message: s, onNavigate: onNavigate),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => _AiSuggestionCard(
            message: 'AI önerileri yüklenemedi. Backend bağlantısını kontrol edin.',
            onNavigate: onNavigate,
          ),
        ),
      ],
    );
  }
}

/// AI Önerileri Provider — backend /chat/suggestions endpoint'inden çeker
final _aiSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final result = await api.getAiSuggestions();
  final suggestions = result['suggestions'] as List<dynamic>? ?? [];
  return suggestions
      .map((s) => (s as Map<String, dynamic>)['mesaj'] as String? ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
});

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({required this.message, this.onNavigate});

  final String message;
  final ValueChanged<String>? onNavigate;

  /// Öneri metninin içeriğine göre ilgili modülün route'unu ve buton label'ını belirle
  (String route, String label, IconData icon) _detectTarget() {
    final lower = message.toLowerCase();
    if (lower.contains('stok') || lower.contains('ürün') || lower.contains('tedarik')) {
      return (AppRoutes.stock, 'Stok Yönetimine Git', Icons.inventory_2_outlined);
    }
    if (lower.contains('nakit') || lower.contains('ödeme') || lower.contains('tahsilat') || lower.contains('maliyet') || lower.contains('kâr') || lower.contains('kar')) {
      return (AppRoutes.finance, 'Finans Modülüne Git', Icons.account_balance_wallet_outlined);
    }
    if (lower.contains('kdv') || lower.contains('vergi') || lower.contains('beyanname')) {
      return (AppRoutes.finance, 'KDV Detayına Git', Icons.receipt_long_outlined);
    }
    if (lower.contains('puantaj') || lower.contains('çalışan') || lower.contains('mesai')) {
      return (AppRoutes.employees, 'Puantaj Modülüne Git', Icons.groups_2_outlined);
    }
    if (lower.contains('belge') || lower.contains('fatura')) {
      return (AppRoutes.documents, 'Belge İşlemeye Git', Icons.description_outlined);
    }
    return (AppRoutes.chat, 'AI\'a Detay Sor', Icons.smart_toy_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final (route, label, icon) = _detectTarget();

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
                  onPressed: () => onNavigate?.call(route),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: _DashboardColors.secondary,
                  ),
                  label: Text(label),
                  icon: Icon(icon, size: 18),
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
