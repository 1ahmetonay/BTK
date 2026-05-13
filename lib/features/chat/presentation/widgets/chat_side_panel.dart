import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../chat_mock_data.dart';
import 'tool_chips.dart';

class ChatSidePanel extends StatelessWidget {
  const ChatSidePanel({
    required this.questions,
    required this.tools,
    required this.recentAnalyses,
    required this.onQuestionSelected,
    super.key,
  });

  final List<SuggestedQuestionMock> questions;
  final List<ToolUsageMock> tools;
  final List<RecentAiAnalysisMock> recentAnalyses;
  final ValueChanged<String> onQuestionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: 'Önerilen Sorular',
          subtitle: 'Tek tıkla örnek analiz başlatın',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: questions
                .map(
                  (question) => ActionChip(
                    avatar: Icon(question.icon, size: 18),
                    label: Text(question.question),
                    onPressed: () => onQuestionSelected(question.question),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Kullanılabilen Araçlar',
          subtitle: 'Demo function calling görünümü',
          child: ToolChips(tools: tools),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Son AI Analizleri',
          subtitle: 'Yakın zamanda üretilen içgörüler',
          child: Column(
            children: recentAnalyses
                .map(
                  (analysis) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: analysis.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            analysis.icon,
                            color: analysis.iconColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            analysis.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
