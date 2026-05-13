import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({
    required this.values,
    required this.briefingTime,
    required this.onToggle,
    required this.onSave,
    super.key,
  });

  final Map<String, bool> values;
  final String briefingTime;
  final void Function(String key, bool value) onToggle;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Bildirim Tercihleri',
      subtitle: 'Kritik aksiyon ve günlük özet bildirimleri',
      child: Column(
        children: [
          for (final entry in values.entries)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: entry.value,
              onChanged: (value) => onToggle(entry.key, value),
              title: Text(entry.key),
              activeThumbColor: AppColors.primary,
            ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: briefingTime,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Sabah brifingi saati',
              prefixIcon: Icon(Icons.schedule_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Bildirimleri Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
