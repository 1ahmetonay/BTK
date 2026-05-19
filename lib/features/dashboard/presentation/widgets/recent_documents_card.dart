import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../dashboard_mock_data.dart';

class RecentDocumentsCard extends StatelessWidget {
  const RecentDocumentsCard({required this.documents, super.key});

  final List<RecentDocumentData> documents;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Son İşlenen Belgeler',
      subtitle: 'Bugün sisteme alınan ve kontrol edilen kayıtlar',
      child: documents.isEmpty
          ? const EmptyState(
              icon: Icons.description_outlined,
              title: 'Henüz işlenmiş belge yok',
              description: 'Belge yüklediğinizde burada görünecek.',
            )
          : Column(
              children: [
                for (final row in documents)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 540;

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
                                  _DocumentIdentity(row: row),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        row.value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      StatusBadge(
                                        label: row.statusLabel,
                                        tone: row.statusTone,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _DocumentIdentity(row: row)),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        row.value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      StatusBadge(
                                        label: row.statusLabel,
                                        tone: row.statusTone,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

class _DocumentIdentity extends StatelessWidget {
  const _DocumentIdentity({required this.row});

  final RecentDocumentData row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.infoSurface,
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
                row.documentType,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                row.source,
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
