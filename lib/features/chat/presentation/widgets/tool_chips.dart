import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../chat_mock_data.dart';

class ToolChips extends StatelessWidget {
  const ToolChips({required this.tools, super.key});

  final List<ToolUsageMock> tools;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tools
          .map(
            (tool) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outline),
              ),
              child: Text(
                tool.name,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
