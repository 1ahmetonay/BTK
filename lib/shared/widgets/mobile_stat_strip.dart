import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'status_badge.dart';

class MobileStatStrip extends StatelessWidget {
  const MobileStatStrip({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final child in children) ...[
            SizedBox(width: 172, child: child),
            if (child != children.last) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class MobileStatTile extends StatelessWidget {
  const MobileStatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.trend,
    this.trendTone = StatusTone.info,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? trend;
  final StatusTone trendTone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 19),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trend != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(label: trend!, tone: trendTone),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
