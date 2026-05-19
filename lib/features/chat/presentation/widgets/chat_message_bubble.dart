import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../chat_mock_data.dart';
import 'tool_chips.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({required this.message, super.key});

  final ChatMessageMock message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: isUser ? 0.86 : (message.tools.isEmpty ? 0.86 : 0.92),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : message.tools.isEmpty
                    ? AppColors.surfaceHigh
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 12 : 2),
                  topRight: Radius.circular(isUser ? 2 : 12),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.outline),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.ink,
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: isUser ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    if (!isUser && message.tools.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.outline),
                      const SizedBox(height: 8),
                      if (message.steps.isNotEmpty) ...[
                        _AnalysisSteps(steps: message.steps),
                        const SizedBox(height: 18),
                      ],
                      const Text(
                        'Kullanılan Araçlar',
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ToolChips(tools: message.tools),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _GoToModuleButton(tools: message.tools),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isUser
                  ? 'SİZ • ${_relativeTime(message.timestamp)}'
                  : 'AI ASİSTAN • ${_relativeTime(message.timestamp)}',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 30) return 'ŞİMDİ';
    if (diff.inMinutes < 1) return '${diff.inSeconds} SN ÖNCE';
    if (diff.inMinutes < 60) return '${diff.inMinutes} DK ÖNCE';
    if (diff.inHours < 24) return '${diff.inHours} SAAT ÖNCE';
    return '${diff.inDays} GÜN ÖNCE';
  }
}

class _AnalysisSteps extends StatelessWidget {
  const _AnalysisSteps({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppColors.mutedText, size: 16),
            SizedBox(width: 5),
            Text(
              'Analiz Adımları',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final step in steps) ...[
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.secondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step,
                  style: const TextStyle(
                    color: AppColors.onSecondaryContainer,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ],
    );
  }
}

/// Kullanılan araçlara göre ilgili modüle yönlendiren buton
class _GoToModuleButton extends StatelessWidget {
  const _GoToModuleButton({required this.tools});

  final List<ToolUsageMock> tools;

  (String route, String label, IconData icon) _detectModule() {
    final allTools = tools.map((t) => t.name.toLowerCase()).join(' ');

    if (allTools.contains('stock') || allTools.contains('supplier') || allTools.contains('product')) {
      return (AppRoutes.stock, 'Stok Modülüne Git', Icons.inventory_2_outlined);
    }
    if (allTools.contains('cash') || allTools.contains('overdue') || allTools.contains('finance') || allTools.contains('pl')) {
      return (AppRoutes.finance, 'Finans Modülüne Git', Icons.account_balance_wallet_outlined);
    }
    if (allTools.contains('kdv') || allTools.contains('tax')) {
      return (AppRoutes.finance, 'KDV Detayına Git', Icons.receipt_long_outlined);
    }
    if (allTools.contains('employee') || allTools.contains('attendance') || allTools.contains('salary')) {
      return (AppRoutes.employees, 'Puantaj Modülüne Git', Icons.groups_2_outlined);
    }
    if (allTools.contains('document') || allTools.contains('process')) {
      return (AppRoutes.documents, 'Belge İşlemeye Git', Icons.description_outlined);
    }
    return (AppRoutes.alerts, 'Uyarıları Gör', Icons.notifications_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final (route, label, icon) = _detectModule();

    return TextButton.icon(
      onPressed: () {
        // Sayfa değiştirmek için en üst navigation'a ulaş
        // DefaultTabController veya shell scaffold kullanıyorsa, route navigate yap
        Navigator.of(context).popUntil((r) => r.isFirst);
        // Snackbar ile yönlendirme bildirimi
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('$label — ilgili sayfaya gidin.'),
            duration: const Duration(seconds: 2),
          ));
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Analiz ediliyor...'),
          ],
        ),
      ),
    );
  }
}
