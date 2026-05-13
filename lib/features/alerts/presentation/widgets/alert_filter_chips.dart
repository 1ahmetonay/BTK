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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in AlertFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: selectedFilter == filter,
              onSelected: (_) => onSelected(filter),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}
