import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
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
    return SectionCard(
      title: 'Aktif Uyarılar',
      subtitle: 'Filtreye göre listelenen riskler, öneriler ve yapılacak işler',
      child: alerts.isEmpty
          ? const _EmptyAlerts()
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _AlertTile(
                  alert: alerts[index],
                  onStartAction: onStartAction,
                  onResolve: onResolve,
                  onIgnore: onIgnore,
                );
              },
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isResolved ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isResolved
              ? AppColors.line
              : alert.priority.color.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;

              final badges = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CategoryBadge(category: alert.category),
                  StatusBadge(
                    label: alert.priority.label,
                    tone: alert.priority.tone,
                  ),
                  if (isResolved)
                    const StatusBadge(
                      label: 'Çözüldü',
                      tone: StatusTone.success,
                    ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badges,
                    const SizedBox(height: 10),
                    _TitleTime(alert: alert),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TitleTime(alert: alert)),
                  const SizedBox(width: 12),
                  badges,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            alert.description,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isResolved ? Icons.task_alt_outlined : Icons.auto_awesome_outlined,
                  color: isResolved ? AppColors.emerald : AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    alert.recommendedAction,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isResolved ? null : () => onStartAction(alert),
                icon: const Icon(Icons.play_arrow_outlined),
                label: const Text('Aksiyon Al'),
              ),
              OutlinedButton.icon(
                onPressed: isResolved ? null : () => onResolve(alert),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Çözüldü İşaretle'),
              ),
              TextButton.icon(
                onPressed: () => onIgnore(alert),
                icon: const Icon(
                  Icons.visibility_off_outlined,
                  color: AppColors.rose,
                ),
                label: const Text(
                  'Yok Say',
                  style: TextStyle(color: AppColors.rose),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleTime extends StatelessWidget {
  const _TitleTime({required this.alert});

  final AlertMock alert;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: alert.priority.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            alert.category.icon,
            color: alert.priority.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                alert.timeLabel,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final AlertCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(
            category.label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
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
