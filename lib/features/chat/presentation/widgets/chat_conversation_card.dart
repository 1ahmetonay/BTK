import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../chat_mock_data.dart';
import 'chat_message_bubble.dart';

class ChatConversationCard extends StatelessWidget {
  const ChatConversationCard({
    required this.messages,
    required this.isTyping,
    required this.controller,
    required this.inputController,
    required this.onSubmit,
    this.suggestedQuestions = const [],
    this.onQuestionSelected,
    this.onFileAttached,
    this.onFileBytesAttached,
    super.key,
  });

  final List<ChatMessageMock> messages;
  final bool isTyping;
  final ScrollController controller;
  final TextEditingController inputController;
  final ValueChanged<String> onSubmit;
  final List<SuggestedQuestionMock> suggestedQuestions;
  final ValueChanged<String>? onQuestionSelected;
  final ValueChanged<String>? onFileAttached;
  final void Function(String name, List<int>? bytes)? onFileBytesAttached;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (suggestedQuestions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Önerilen Sorular',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: suggestedQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final question = suggestedQuestions[index];
                final label = _shortQuestion(question.question);

                return ActionChip(
                  label: Text(label),
                  onPressed: () =>
                      (onQuestionSelected ?? onSubmit)(question.question),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  labelStyle: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        ListView.separated(
          controller: controller,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: messages.length + (isTyping ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            if (index >= messages.length) {
              return const TypingBubble();
            }

            return ChatMessageBubble(message: messages[index]);
          },
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border(top: BorderSide(color: AppColors.outline)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(withData: true);
                      if (result == null || result.files.isEmpty) return;
                      final file = result.files.first;
                      onFileAttached?.call(file.name);
                      onFileBytesAttached?.call(file.name, file.bytes);
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.attach_file),
                  color: AppColors.mutedText,
                  tooltip: 'Dosya ekle',
                ),
                Expanded(
                  child: TextField(
                    controller: inputController,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: onSubmit,
                    decoration: const InputDecoration(
                      hintText: 'AI Asistan’a sorun...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: FilledButton(
                    onPressed: () => onSubmit(inputController.text),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.send_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _shortQuestion(String question) {
    if (question.startsWith('Önümüzdeki ay')) {
      return 'Nakit sıkışması yaşar mıyım?';
    }
    if (question.contains('kârlı') || question.contains('karlı')) {
      return 'En kârlı ürünler hangileri?';
    }

    return question;
  }
}
