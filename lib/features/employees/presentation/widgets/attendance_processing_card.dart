import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';

class AttendanceProcessingCard extends StatelessWidget {
  const AttendanceProcessingCard({
    required this.fileName,
    required this.onApprove,
    required this.onManualEdit,
    required this.onReanalyze,
    super.key,
  });

  final String fileName;
  final VoidCallback onApprove;
  final VoidCallback onManualEdit;
  final VoidCallback onReanalyze;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'AI Puantaj Okuma',
      subtitle: 'Puantaj belgesinden çalışma günü, mesai ve izin çıkarımı',
      trailing: const StatusBadge(
        label: 'Kontrol bekliyor',
        tone: StatusTone.warning,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upload_file_outlined,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seçili mock dosya',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Gemini Vision, puantaj tablosundan 5 çalışan, 110 toplam çalışma günü, 30 saat mesai ve 6 izin günü çıkardı.',
                        style: TextStyle(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Güven skoru',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.88,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            color: AppColors.primary,
            backgroundColor: const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 8),
          const Text(
            '%88 güven ile puantaj alanları eşleştirildi',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Puantajı Onayla'),
              ),
              OutlinedButton.icon(
                onPressed: onManualEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Manuel Düzenle'),
              ),
              TextButton.icon(
                onPressed: onReanalyze,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Yeniden Analiz Et'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
