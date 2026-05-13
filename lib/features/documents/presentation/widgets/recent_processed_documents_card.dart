import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../documents_mock_data.dart';

class RecentProcessedDocumentsCard extends StatelessWidget {
  const RecentProcessedDocumentsCard({
    required this.items,
    super.key,
  });

  final List<RecentProcessedDocumentMock> items;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Son İşlenen Belgeler',
      subtitle: 'Geçmiş belge akışının kısa özeti',
      child: Column(
        children: items
            .map(
              (item) => LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 360;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DocumentInfo(item: item),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.value,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  StatusBadge(
                                    label: item.statusLabel,
                                    tone: item.statusTone,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _DocumentInfo(item: item)),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item.value,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  StatusBadge(
                                    label: item.statusLabel,
                                    tone: item.statusTone,
                                  ),
                                ],
                              ),
                            ],
                          ),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DocumentInfo extends StatelessWidget {
  const _DocumentInfo({required this.item});

  final RecentProcessedDocumentMock item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.documentType,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                item.source,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
