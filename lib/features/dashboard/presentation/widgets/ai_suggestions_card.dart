import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../dashboard_mock_data.dart';

class AiSuggestionsCard extends StatelessWidget {
  const AiSuggestionsCard({required this.suggestions, super.key});

  final List<AiSuggestionData> suggestions;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'AI Önerileri',
      subtitle: 'Analiz motorunun öne çıkardığı içgörüler',
      child: suggestions.isEmpty
          ? const EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'Henüz AI önerisi yok',
              description: 'Veriler yüklendikçe öneriler burada görünecek.',
            )
          : Column(
              children: [
                for (final suggestion in suggestions)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            suggestion.message,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
