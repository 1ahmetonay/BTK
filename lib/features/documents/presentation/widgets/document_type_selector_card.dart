import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_card.dart';
import '../documents_mock_data.dart';

class DocumentTypeSelectorCard extends StatelessWidget {
  const DocumentTypeSelectorCard({
    required this.selectedType,
    required this.onSelectionChanged,
    super.key,
  });

  final DocumentType selectedType;
  final ValueChanged<DocumentType> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Belge Türü',
      subtitle: 'AI analiz akışının yorumlayacağı belge tipi',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final type in DocumentType.values) ...[
              ChoiceChip(
                label: Text(type.label),
                selected: selectedType == type,
                onSelected: (_) => onSelectionChanged(type),
              ),
              const SizedBox(width: 10),
            ],
          ],
        ),
      ),
    );
  }
}
