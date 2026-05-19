import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../alerts_mock_data.dart';

class AlertsListCard extends StatelessWidget {
  const AlertsListCard({
    required this.alerts,
    required this.onStartAction,
    required this.onResolve,
    required this.onIgnore,
    super.key,
  });

  final List<AlertMock> alerts;
  final ValueChanged<AlertMock> onStartAction;
  final ValueChanged<AlertMock> onResolve;
  final ValueChanged<AlertMock> onIgnore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AKTİF UYARILAR',
          style: TextStyle(
            color: AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        if (alerts.isEmpty)
          const _EmptyAlerts()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _AlertTile(
                alert: alerts[index],
                onStartAction: onStartAction,
                onResolve: onResolve,
                onIgnore: onIgnore,
              );
            },
          ),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.alert,
    required this.onStartAction,
    required this.onResolve,
    required this.onIgnore,
  });

  final AlertMock alert;
  final ValueChanged<AlertMock> onStartAction;
  final ValueChanged<AlertMock> onResolve;
  final ValueChanged<AlertMock> onIgnore;

  @override
  Widget build(BuildContext context) {
    final isResolved = alert.status == AlertStatus.resolved;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isResolved ? AppColors.surfaceDim : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AlertBadge(alert: alert),
              const Spacer(),
              Text(
                _timeLabel(alert.timeLabel),
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            _title(alert),
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _description(alert),
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Aksiyon Al',
                  primary: true,
                  onPressed: isResolved ? null : () => onStartAction(alert),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Çözüldü\nİşaretle',
                  onPressed: isResolved ? null : () => onResolve(alert),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Yok Say',
                  onPressed: () => onIgnore(alert),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _title(AlertMock alert) {
    return switch (alert.id) {
      'document-damaged-dispatch' => 'İrsaliye hasar bildirimi',
      'stock-filter-cost' => 'Filtre Kahve maliyet artışı',
      'finance-overdue' => 'Gecikmiş tahsilat hatırlatması',
      _ => alert.title,
    };
  }

  String _description(AlertMock alert) {
    return switch (alert.id) {
      'stock-turk-kahvesi' => 'Mevcut stok 12 adet. 4 günlük stok kaldı.',
      'finance-cash-risk' => '42.000 TL açık riski tespit edildi.',
      'kdv-deadline' => 'Son tarih 26 Mayıs. Evraklarınızı tamamlayın.',
      'attendance-check' =>
        'Nisan ayı puantajları için onay bekleyen 4 personel var.',
      'document-damaged-dispatch' =>
        'Gelen son sevkiyatta 3 koli hasarlı olarak işaretlendi.',
      'stock-filter-cost' => 'Birim maliyet son 1 ayda %15 artış gösterdi.',
      'finance-overdue' => 'X Müşterisinden 15.000 TL ödeme 5 gün gecikti.',
      _ => alert.description,
    };
  }

  String _timeLabel(String timeLabel) {
    if (timeLabel.contains('10:42')) {
      return '1 saat önce';
    }
    if (timeLabel.contains('09:30')) {
      return '3 saat önce';
    }
    if (timeLabel.contains('08:15')) {
      return 'Dün';
    }

    return timeLabel;
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({required this.alert});

  final AlertMock alert;

  @override
  Widget build(BuildContext context) {
    final tone = alert.priority == AlertPriority.critical
        ? StatusTone.danger
        : alert.priority == AlertPriority.high
        ? StatusTone.info
        : alert.priority == AlertPriority.medium
        ? StatusTone.neutral
        : StatusTone.warning;

    final label = '${_categoryLabel(alert.category)} | ${alert.priority.label}'
        .toUpperCase();

    return Transform.scale(
      scale: 0.78,
      alignment: Alignment.centerLeft,
      child: StatusBadge(label: label, tone: tone),
    );
  }

  String _categoryLabel(AlertCategory category) {
    return switch (category) {
      AlertCategory.employees => 'İK',
      AlertCategory.document => 'Belge',
      _ => category.label,
    };
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (primary) {
      return SizedBox(
        height: 42,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        child: child,
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt_outlined, color: AppColors.emerald, size: 34),
          SizedBox(height: 10),
          Text(
            'Bu filtrede gösterilecek uyarı yok.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
