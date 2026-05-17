import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum ChatRole { user, assistant }

class ToolUsageMock {
  const ToolUsageMock(this.name);

  final String name;
}

class AiResponseMock {
  const AiResponseMock({
    required this.message,
    required this.tools,
    required this.steps,
  });

  final String message;
  final List<ToolUsageMock> tools;
  final List<String> steps;
}

class ChatMessageMock {
  const ChatMessageMock({
    required this.id,
    required this.role,
    required this.message,
    required this.timestamp,
    this.tools = const [],
    this.steps = const [],
  });

  final String id;
  final ChatRole role;
  final String message;
  final DateTime timestamp;
  final List<ToolUsageMock> tools;
  final List<String> steps;
}

class SuggestedQuestionMock {
  const SuggestedQuestionMock({
    required this.question,
    required this.icon,
  });

  final String question;
  final IconData icon;
}

class RecentAiAnalysisMock {
  const RecentAiAnalysisMock({
    required this.title,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
}
