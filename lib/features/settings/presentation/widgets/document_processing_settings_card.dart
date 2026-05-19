import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class DocumentProcessingSettingsCard extends StatelessWidget {
  const DocumentProcessingSettingsCard({
    required this.values,
    required this.confidenceThreshold,
    required this.onToggle,
    required this.onThresholdChanged,
    super.key,
  });

  final Map<String, bool> values;
  final int confidenceThreshold;
  final void Function(String key, bool value) onToggle;
  final ValueChanged<int> onThresholdChanged;

  @override
  Widget build(BuildContext context) {
    const firstKey =
        'Düşük güven skorlu belgeleri otomatik kontrol listesine al';
    const secondKey = 'Fatura işlenince stokları otomatik güncelle';

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Belge İşleme',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SwitchRow(
            label: 'Düşük güven skorlu belgeleri kontrol listesine al',
            value: values[firstKey] ?? false,
            onChanged: (value) => onToggle(firstKey, value),
          ),
          const SizedBox(height: 12),
          _SwitchRow(
            label: 'Fatura işlenince stokları güncelle',
            value: values[secondKey] ?? false,
            onChanged: (value) => onToggle(secondKey, value),
          ),
          const SizedBox(height: 18),
          Text(
            'Güven Skoru Eşiği (%$confidenceThreshold)',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.outlineSoft,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primaryOverlay,
              trackHeight: 4,
            ),
            child: Slider(
              min: 80,
              max: 95,
              divisions: 3,
              value: confidenceThreshold.toDouble(),
              onChanged: (value) => onThresholdChanged(value.round()),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('80', style: _TickStyle()),
                Text('85', style: _TickStyle()),
                Text('90', style: _TickStyle()),
                Text('95', style: _TickStyle()),
              ],
            ),
          ),
        ],
      ),
    );
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
            style: const TextStyle(fontSize: 13, height: 1.25),
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }
}

class _TickStyle extends TextStyle {
  const _TickStyle()
    : super(
        color: AppColors.mutedText,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );
}
