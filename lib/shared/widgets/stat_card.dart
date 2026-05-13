import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'status_badge.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.description,
    this.trend,
    this.trendTone = StatusTone.info,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? description;
  final String? trend;
  final StatusTone trendTone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                if (trend != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: StatusBadge(
                        label: trend!,
                        tone: trendTone,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 10),
              Text(
                description!,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
