import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackHeader = trailing != null && constraints.maxWidth < 560;

        return Card(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (stackHeader) ...[
                  _HeaderText(title: title, subtitle: subtitle),
                  const SizedBox(height: 12),
                  trailing!,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HeaderText(title: title, subtitle: subtitle),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
