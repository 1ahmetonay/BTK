import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppTopbar extends StatelessWidget {
  const AppTopbar({
    required this.title,
    required this.subtitle,
    required this.showMenuButton,
    this.compact = false,
    this.onAlertsPressed,
    this.onSettingsPressed,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool showMenuButton;
  final bool compact;
  final VoidCallback? onAlertsPressed;
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          bottom: false,
          child: Container(
            height: compact ? 56 : 64,
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 18),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: AppColors.outline)),
            ),
            child: Row(
              children: [
                if (showMenuButton) ...[
                  Builder(
                    builder: (context) {
                      return IconButton(
                        tooltip: 'Menüyü aç',
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        color: AppColors.onSurface,
                        icon: const Icon(Icons.menu),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: compact ? 18 : 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Bildirimler',
                  onPressed: onAlertsPressed,
                  color: AppColors.onSurface,
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                IconButton(
                  tooltip: 'Ayarlar',
                  onPressed: onSettingsPressed,
                  color: AppColors.onSurface,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
