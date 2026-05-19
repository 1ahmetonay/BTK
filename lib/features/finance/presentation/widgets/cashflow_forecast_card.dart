import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../finance_mock_data.dart';

class CashflowForecastCard extends StatelessWidget {
  const CashflowForecastCard({
    required this.metrics,
    required this.points,
    required this.riskText,
    super.key,
  });

  final List<ProfitLossItemMock> metrics;
  final List<CashflowPointMock> points;
  final String riskText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NAKİT AKIŞI ÖNGÖRÜSÜ',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              const Positioned(
                left: 11,
                top: 12,
                bottom: 12,
                child: VerticalDivider(
                  width: 2,
                  thickness: 2,
                  color: AppColors.outline,
                ),
              ),
              Column(
                children: [
                  for (var index = 0; index < points.length; index++) ...[
                    _TimelinePoint(point: points[index], index: index),
                    if (index != points.length - 1) const SizedBox(height: 18),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelinePoint extends StatelessWidget {
  const _TimelinePoint({required this.point, required this.index});

  final CashflowPointMock point;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(point.tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: point.tone == StatusTone.danger
                ? AppColors.errorContainer
                : index == 0
                ? AppColors.primary
                : AppColors.surfaceDim,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _label(point.label),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: point.tone == StatusTone.danger
                            ? AppColors.error
                            : AppColors.mutedText,
                        fontSize: 11,
                        fontWeight: point.tone == StatusTone.danger
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (point.tone == StatusTone.danger)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.priority_high,
                        color: AppColors.error,
                        size: 13,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _value(point),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: point.tone == StatusTone.danger
                      ? FontWeight.w900
                      : FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (point.tone == StatusTone.success)
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.secondary,
            size: 18,
          )
        else if (point.tone == StatusTone.danger)
          const StatusBadge(label: 'AÇIK VAR', tone: StatusTone.danger),
      ],
    );
  }

  String _label(String label) {
    return switch (label) {
      '7 gün' => '7 Gün Sonra',
      '14 gün' => '14 Gün Sonra',
      '30 gün' => '30 Gün Sonra',
      _ => label,
    };
  }

  String _value(CashflowPointMock point) {
    if (point.label == '7 gün') {
      return '88.200 TL';
    }
    if (point.label == '14 gün') {
      return '- 42.000 TL (Risk)';
    }
    if (point.label == '30 gün') {
      return '15.000 TL';
    }

    return point.value;
  }

  Color _colorFor(StatusTone tone) {
    return switch (tone) {
      StatusTone.success => AppColors.secondary,
      StatusTone.warning => AppColors.amber,
      StatusTone.danger => AppColors.error,
      StatusTone.info => AppColors.primary,
      StatusTone.neutral => AppColors.muted,
    };
  }
}
