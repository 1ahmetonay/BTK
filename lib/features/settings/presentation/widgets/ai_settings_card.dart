import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../settings_mock_data.dart';

class AiSettingsCard extends StatelessWidget {
  const AiSettingsCard({
    required this.values,
    required this.mode,
    required this.onToggle,
    required this.onModeChanged,
    super.key,
  });

  final Map<String, bool> values;
  final AiMode mode;
  final void Function(String key, bool value) onToggle;
  final ValueChanged<AiMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final visible = [
      ('Sabah brifingi', 'Sabah brifingi aktif'),
      ('Kritik stok önerileri', 'Kritik stok önerileri aktif'),
      ('Nakit akışı risk uyarıları', 'Nakit akışı risk uyarıları aktif'),
      ('KDV son tarih uyarıları', 'KDV son tarih uyarıları aktif'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.secondary, width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'AI Asistan Ayarları',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final item in visible) ...[
              _SwitchRow(
                label: item.$1,
                value: values[item.$2] ?? false,
                onChanged: (value) => onToggle(item.$2, value),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            const Text(
              'AI Çalışma Modu',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                children: AiMode.values.map((item) {
                  final selected = mode == item;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onModeChanged(item),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _modeLabel(item),
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _modeDescription(mode),
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _modeLabel(AiMode item) {
    return switch (item) {
      AiMode.balanced => 'Dengeli',
      AiMode.careful => 'Dikkatli',
      AiMode.proactive => 'Proaktif',
    };
  }

  static String _modeDescription(AiMode item) {
    return switch (item) {
      AiMode.balanced => 'Standart analiz. Sorulara doğrudan yanıt verir, gerektiğinde öneri sunar.',
      AiMode.careful => 'Yalnızca doğrulanmış verilerle çalışır. Belirsiz durumlarda uyarır, muhafazakâr öneriler sunar.',
      AiMode.proactive => 'Aktif risk taraması yapar. Ek veriler kontrol eder, fırsat ve tehdit analizi sunar, what-if senaryoları önerir.',
    };
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.secondary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.outlineSoft,
        ),
      ],
    );
  }
}
