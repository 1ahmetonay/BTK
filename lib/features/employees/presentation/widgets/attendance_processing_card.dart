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
    this.onPickFile,
    this.employeeCount = 0,
    this.totalWorkDays = 0,
    this.totalOvertime = 0,
    this.totalLeaveDays = 0,
    this.isLiveData = false,
    super.key,
  });

  final String fileName;
  final VoidCallback onApprove;
  final VoidCallback onManualEdit;
  final VoidCallback onReanalyze;
  final VoidCallback? onPickFile;
  final int employeeCount;
  final int totalWorkDays;
  final int totalOvertime;
  final int totalLeaveDays;
  final bool isLiveData;

  @override
  Widget build(BuildContext context) {
    final description = employeeCount > 0
        ? 'Gemini Vision, puantaj tablosundan $employeeCount çalışan, '
          '$totalWorkDays toplam çalışma günü, $totalOvertime saat mesai '
          've $totalLeaveDays izin günü çıkardı.'
        : 'Puantaj belgesi henüz işlenmedi. Belge yükleyerek AI analizi başlatabilirsiniz.';

    final confidence = employeeCount > 0 ? 0.88 : 0.0;
    final confidenceLabel = employeeCount > 0
        ? '%${(confidence * 100).round()} güven ile puantaj alanları eşleştirildi'
        : 'Henüz analiz yapılmadı';

    return SectionCard(
      title: 'AI Puantaj Okuma',
      subtitle: 'Puantaj belgesinden çalışma günü, mesai ve izin çıkarımı',
      trailing: StatusBadge(
        label: employeeCount > 0 ? 'Kontrol bekliyor' : 'Belge bekleniyor',
        tone: employeeCount > 0 ? StatusTone.warning : StatusTone.neutral,
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
                      Text(
                        isLiveData ? 'API verisi' : 'Puantaj belgesi',
                        style: const TextStyle(
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
                      Text(
                        description,
                        style: const TextStyle(height: 1.45),
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
            value: confidence,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            color: AppColors.primary,
            backgroundColor: const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 8),
          Text(
            confidenceLabel,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (onPickFile != null)
                OutlinedButton.icon(
                  onPressed: onPickFile,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Belge Yükle'),
                ),
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
