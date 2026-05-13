import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../employees_mock_data.dart';

class AttendanceIssuesCard extends StatelessWidget {
  const AttendanceIssuesCard({
    required this.issues,
    required this.onReview,
    super.key,
  });

  final List<AttendanceIssueMock> issues;
  final ValueChanged<String> onReview;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Kontrol Gerektiren Durumlar',
      subtitle: 'Bordro öncesi doğrulanması önerilen kayıtlar',
      child: Column(
        children: issues
            .map(
              (issue) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 460;

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IssueText(issue: issue),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => onReview(issue.employeeName),
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Text('Kontrol Et'),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: _IssueText(issue: issue)),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => onReview(issue.employeeName),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Kontrol Et'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _IssueText extends StatelessWidget {
  const _IssueText({required this.issue});

  final AttendanceIssueMock issue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.warning_amber_outlined,
            color: AppColors.rose,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue.employeeName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                issue.description,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
