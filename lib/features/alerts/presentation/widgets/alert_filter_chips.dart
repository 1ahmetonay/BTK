import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../alerts_mock_data.dart';

class AlertFilterChips extends StatelessWidget {
  const AlertFilterChips({
    required this.selectedFilter,
    required this.onSelected,
    super.key,
  });

  final AlertFilter selectedFilter;
  final ValueChanged<AlertFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: AlertFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = AlertFilter.values[index];
          final selected = selectedFilter == filter;

          return InkWell(
            onTap: () => onSelected(filter),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(999),
                border: selected
                    ? null
                    : Border.all(color: AppColors.outline),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
