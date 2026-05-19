import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum StatusTone { success, warning, danger, info, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    this.tone = StatusTone.neutral,
    super.key,
  });

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.$2,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(StatusTone tone) {
    return switch (tone) {
      StatusTone.success => (
        AppColors.successContainer,
        AppColors.emerald,
      ),
      StatusTone.warning => (
        AppColors.warningContainer,
        AppColors.amber,
      ),
      StatusTone.danger => (
        AppColors.errorSurface,
        AppColors.rose,
      ),
      StatusTone.info => (
        AppColors.infoContainer,
        AppColors.primary,
      ),
      StatusTone.neutral => (
        AppColors.neutralContainer,
        AppColors.muted,
      ),
    };
  }
}
