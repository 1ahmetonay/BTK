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
        final showSearch = !compact && constraints.maxWidth >= 760;

        return SafeArea(
          bottom: false,
          child: Container(
            height: compact ? 56 : 64,
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border(bottom: BorderSide(color: Color(0xFFC4C6CF))),
            ),
            child: Row(
              children: [
                if (showMenuButton) ...[
                  Builder(
                    builder: (context) {
                      return IconButton(
                        tooltip: 'Menüyü aç',
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        color: const Color(0xFF191C1D),
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
                          color: const Color(0xFF002045),
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
                if (showSearch) ...[
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Ara',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxHeight: 42),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Bildirimler',
                  onPressed: onAlertsPressed,
                  color: const Color(0xFF191C1D),
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                IconButton(
                  tooltip: 'Ayarlar',
                  onPressed: onSettingsPressed,
                  color: const Color(0xFF191C1D),
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
