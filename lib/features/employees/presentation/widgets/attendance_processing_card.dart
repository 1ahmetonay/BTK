import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AttendanceProcessingCard extends StatelessWidget {
  const AttendanceProcessingCard({
    required this.onPickFile,
    required this.onAnalyze,
    required this.onProcess,
    required this.onManualEdit,
    required this.onReject,
    this.pickedFileName = '',
    this.isAnalyzing = false,
    this.analizSonuc,
    super.key,
  });

  final VoidCallback onPickFile;
  final VoidCallback onAnalyze;
  final VoidCallback onProcess;
  final VoidCallback onManualEdit;
  final VoidCallback onReject;
  final String pickedFileName;
  final bool isAnalyzing;
  final Map<String, dynamic>? analizSonuc;

  @override
  Widget build(BuildContext context) {
    final hasAnalysis = analizSonuc != null && analizSonuc!['success'] == true;
    final sonuclar = hasAnalysis
        ? (analizSonuc!['sonuclar'] as List<dynamic>?) ?? []
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Upload Card ──
        _UploadCard(
          pickedFileName: pickedFileName,
          isAnalyzing: isAnalyzing,
          onPickFile: onPickFile,
          onAnalyze: onAnalyze,
        ),

        if (hasAnalysis) ...[
          const SizedBox(height: 16),
          _AnalysisResultCard(analizSonuc: analizSonuc!),
          const SizedBox(height: 16),
          _EmployeeResultsList(sonuclar: sonuclar),
          const SizedBox(height: 16),
          _ImpactSummary(analizSonuc: analizSonuc!),
          const SizedBox(height: 16),
          _ActionButtons(
            onProcess: onProcess,
            onManualEdit: onManualEdit,
            onReject: onReject,
          ),
        ],
      ],
    );
  }
}

// ─── Upload Card (Belge Yönetimi tarzı) ─────────────────────────────

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.pickedFileName,
    required this.isAnalyzing,
    required this.onPickFile,
    required this.onAnalyze,
  });

  final String pickedFileName;
  final bool isAnalyzing;
  final VoidCallback onPickFile;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.infoLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_ind_outlined,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Puantaj belgesi yükleyin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PDF, JPG, PNG, TIFF, XLSX • Maks. 10 MB',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.attach_file_outlined,
                  color: AppColors.mutedText,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    pickedFileName.isNotEmpty
                        ? pickedFileName
                        : 'Belge seçilmedi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FullWidthButton(
            icon: Icons.upload_outlined,
            label: 'Belge Seç',
            background: AppColors.primary,
            foreground: Colors.white,
            onPressed: onPickFile,
          ),
          const SizedBox(height: 8),
          isAnalyzing
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Gemini analiz ediyor...',
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              : _FullWidthButton(
                  icon: Icons.smart_toy_outlined,
                  label: 'Analiz Et',
                  background: AppColors.secondaryContainer,
                  foreground: AppColors.onSecondaryContainer,
                  onPressed: onAnalyze,
                ),
        ],
      ),
    );
  }
}

// ─── Analysis Result Card ────────────────────────────────────────────

class _AnalysisResultCard extends StatelessWidget {
  const _AnalysisResultCard({required this.analizSonuc});

  final Map<String, dynamic> analizSonuc;

  @override
  Widget build(BuildContext context) {
    final donem = analizSonuc['donem'] as String? ?? '—';
    final calisanSayisi = analizSonuc['calisan_sayisi'] ?? 0;
    final toplamBrut = analizSonuc['toplam_brut_maas'] ?? 0;
    final sonuclar = (analizSonuc['sonuclar'] as List<dynamic>?) ?? [];

    int toplamCG = 0, toplamM = 0, toplamI = 0;
    double toplamNet = 0;
    for (final s in sonuclar) {
      final m = s as Map<String, dynamic>;
      toplamCG += (m['calisma_gunu'] as num?)?.toInt() ?? 0;
      toplamM += (m['mesai_saat'] as num?)?.toInt() ?? 0;
      toplamI += (m['izin_gunu'] as num?)?.toInt() ?? 0;
      toplamNet += (m['net_maas'] as num?)?.toDouble() ?? 0;
    }

    final fields = <_FieldData>[
      _FieldData('Dönem', donem),
      _FieldData('Çalışan Sayısı', '$calisanSayisi kişi'),
      _FieldData('Toplam Çalışma Günü', '$toplamCG gün'),
      _FieldData('Toplam Mesai', '$toplamM saat'),
      _FieldData('Toplam İzin', '$toplamI gün'),
      _FieldData('Toplam Brüt Maaş', '${_fmt(toplamBrut)} TL'),
      _FieldData('Toplam Net Maaş', '${_fmt(toplamNet)} TL'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primary),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI Analiz Sonucu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'ANALİZ TAMAMLANDI',
                  style: TextStyle(
                    color: AppColors.onSecondaryContainer,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final f in fields)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.outlineSoft),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${f.label}:',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    f.value,
                    style: TextStyle(
                      color: f.label.contains('Net Maaş')
                          ? AppColors.primary
                          : AppColors.onSurface,
                      fontSize: f.label.contains('Net Maaş') ? 16 : 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          const Text(
            'Güven Skoru: %88',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.88,
              minHeight: 7,
              color: AppColors.secondary,
              backgroundColor: AppColors.surfaceHigh,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num v) {
    if (v >= 1000) {
      return v
          .toDouble()
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
    }
    return v.toStringAsFixed(0);
  }
}

// ─── Employee Results List ───────────────────────────────────────────

class _EmployeeResultsList extends StatelessWidget {
  const _EmployeeResultsList({required this.sonuclar});

  final List<dynamic> sonuclar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'Okunan Çalışan Verileri',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sonuclar.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final s = sonuclar[index] as Map<String, dynamic>;
            final hasWarning = s.containsKey('uyari');
            return _EmployeeResultCard(data: s, hasWarning: hasWarning);
          },
        ),
      ],
    );
  }
}

class _EmployeeResultCard extends StatelessWidget {
  const _EmployeeResultCard({required this.data, this.hasWarning = false});

  final Map<String, dynamic> data;
  final bool hasWarning;

  @override
  Widget build(BuildContext context) {
    final name = data['calisan'] as String? ?? '—';

    if (hasWarning) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: AppColors.warningDark,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['uyari'] as String? ?? '',
                    style: const TextStyle(
                      color: AppColors.warningDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final cg = data['calisma_gunu'] ?? 0;
    final mesai = data['mesai_saat'] ?? 0;
    final izin = data['izin_gunu'] ?? 0;
    final net = data['net_maas'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '$cg gün · $mesai saat mesai · $izin gün izin',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$net TL',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Impact Summary ──────────────────────────────────────────────────

class _ImpactSummary extends StatelessWidget {
  const _ImpactSummary({required this.analizSonuc});

  final Map<String, dynamic> analizSonuc;

  @override
  Widget build(BuildContext context) {
    final calisanSayisi = analizSonuc['calisan_sayisi'] ?? 0;
    final toplamBrut = analizSonuc['toplam_brut_maas'] ?? 0;
    final sonuclar = (analizSonuc['sonuclar'] as List<dynamic>?) ?? [];
    final uyariSayisi = sonuclar
        .where((s) => (s as Map).containsKey('uyari'))
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bu puantaj işlendiğinde',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _ImpactRow(
            text: '$calisanSayisi çalışan için puantaj kaydı oluşturulacak',
          ),
          const SizedBox(height: 12),
          _ImpactRow(text: 'Maaş hesaplamaları yapılıp bordro oluşturulacak'),
          const SizedBox(height: 12),
          _ImpactRow(
            text: 'Nakit akışına $toplamBrut TL personel gideri eklenecek',
          ),
          if (uyariSayisi > 0) ...[
            const SizedBox(height: 12),
            _ImpactRow(
              text:
                  '$uyariSayisi çalışan sistemde eşleşmedi, kayıt dışı kalacak',
              iconColor: AppColors.warningDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({required this.text, this.iconColor});

  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: iconColor ?? AppColors.secondary,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Action Buttons ──────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onProcess,
    required this.onManualEdit,
    required this.onReject,
  });

  final VoidCallback onProcess;
  final VoidCallback onManualEdit;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: onProcess,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Puantaj Belgesini İşle',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: onManualEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mutedText,
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Manuel Düzenle'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onReject,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Reddet'),
        ),
      ],
    );
  }
}

// ─── Shared ──────────────────────────────────────────────────────────

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: background),
          ),
        ),
        icon: Icon(icon, size: 19),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _FieldData {
  const _FieldData(this.label, this.value);
  final String label;
  final String value;
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.outline),
  );
}
