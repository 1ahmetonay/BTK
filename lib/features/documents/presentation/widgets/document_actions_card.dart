import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class DocumentActionsCard extends StatelessWidget {
  const DocumentActionsCard({
    required this.onProcess,
    required this.onManualEdit,
    required this.onReject,
    super.key,
  });

  final VoidCallback onProcess;
  final VoidCallback onManualEdit;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilledButton.icon(
            onPressed: onProcess,
            icon: const Icon(Icons.playlist_add_check_circle_outlined),
            label: const Text('Belgeyi İşle'),
          ),
          OutlinedButton.icon(
            onPressed: onManualEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Manuel Düzenle'),
          ),
          TextButton.icon(
            onPressed: onReject,
            icon: const Icon(
              Icons.close_outlined,
              color: AppColors.rose,
            ),
            label: const Text(
              'Reddet',
              style: TextStyle(color: AppColors.rose),
            ),
          ),
        ],
      ),
    );
  }
}
