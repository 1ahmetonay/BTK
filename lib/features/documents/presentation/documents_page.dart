import 'package:flutter/material.dart';

import '../../../shared/widgets/status_badge.dart';
import 'documents_mock_data.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  DocumentType _selectedType = DocumentType.purchaseInvoice;

  @override
  Widget build(BuildContext context) {
    final scenario = DocumentsMockData.scenarioFor(_selectedType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeaderCard(),
        const SizedBox(height: 16),
        _UploadCard(analysis: scenario.analysis),
        const SizedBox(height: 16),
        _DocumentTypeSelector(
          selectedType: _selectedType,
          onSelectionChanged: _updateSelection,
        ),
        const SizedBox(height: 16),
        _AnalysisResultCard(analysis: scenario.analysis),
        const SizedBox(height: 16),
        _LineItemsList(
          title: scenario.tableTitle,
          headers: scenario.tableHeaders,
          items: scenario.lineItems,
        ),
        const SizedBox(height: 16),
        _ImpactSummary(items: scenario.automationEffects),
        const SizedBox(height: 16),
        _ActionButtons(
          onProcess: _handleProcess,
          onManualEdit: _handleManualEdit,
          onReject: _handleReject,
        ),
        const SizedBox(height: 20),
        const _RecentDocuments(items: DocumentsMockData.recentDocuments),
        const SizedBox(height: 12),
      ],
    );
  }

  void _updateSelection(DocumentType selection) {
    setState(() {
      _selectedType = selection;
    });
  }

  void _handleProcess() {
    _showMessage('${_selectedType.label} işleme kuyruğuna alındı.');
  }

  void _handleManualEdit() {
    _showMessage('Manuel düzenleme modu yakında eklenecek.');
  }

  void _handleReject() {
    _showMessage('Belge reddedildi.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DocumentColors {
  const _DocumentColors._();

  static const primary = Color(0xFF002045);
  static const secondary = Color(0xFF2C694E);
  static const secondaryContainer = Color(0xFFB1F0CE);
  static const onSecondaryContainer = Color(0xFF0E5138);
  static const outline = Color(0xFFC4C6CF);
  static const outlineSoft = Color(0xFFE1E3E4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF3F4F5);
  static const surfaceHigh = Color(0xFFE7E8E9);
  static const muted = Color(0xFF43474E);
  static const error = Color(0xFFBA1A1A);
  static const warning = Color(0xFF4F2E00);
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: _DocumentColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Belge İşleme',
                      style: TextStyle(
                        color: _DocumentColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fatura, fiş, irsaliye ve puantaj belgelerini AI ile okuyun.',
                      style: TextStyle(
                        color: Color(0xFF191C1D),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Yüklenen belgeler stok, KDV, finans ve puantaj kayıtlarına dönüştürülebilir.',
                      style: TextStyle(
                        color: _DocumentColors.muted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.analysis});

  final DocumentAnalysisMock analysis;

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
              color: Color(0xFFD6E3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              color: _DocumentColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Belge yükleyin veya fotoğraf çekin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF191C1D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            DocumentsMockData.supportedFormats,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _DocumentColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _DocumentColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _DocumentColors.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.attach_file_outlined,
                  color: _DocumentColors.muted,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    analysis.selectedFileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _DocumentColors.primary,
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
            background: _DocumentColors.primary,
            foreground: Colors.white,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          _FullWidthButton(
            icon: Icons.photo_camera_outlined,
            label: 'Fotoğraf Çek',
            background: Colors.white,
            foreground: _DocumentColors.primary,
            borderColor: _DocumentColors.primary,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          _FullWidthButton(
            icon: Icons.smart_toy_outlined,
            label: 'Gemini ile Analiz Et',
            background: _DocumentColors.secondaryContainer,
            foreground: _DocumentColors.onSecondaryContainer,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _DocumentTypeSelector extends StatelessWidget {
  const _DocumentTypeSelector({
    required this.selectedType,
    required this.onSelectionChanged,
  });

  final DocumentType selectedType;
  final ValueChanged<DocumentType> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Belge Türü',
          style: TextStyle(
            color: Color(0xFF191C1D),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final type in DocumentType.values) ...[
                ChoiceChip(
                  label: Text(_shortLabel(type)),
                  selected: selectedType == type,
                  onSelected: (_) => onSelectionChanged(type),
                  showCheckmark: false,
                  selectedColor: _DocumentColors.primary,
                  labelStyle: TextStyle(
                    color: selectedType == type
                        ? Colors.white
                        : _DocumentColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selectedType == type
                          ? _DocumentColors.primary
                          : _DocumentColors.outline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _shortLabel(DocumentType type) {
    return switch (type) {
      DocumentType.purchaseInvoice => 'Satın Alma',
      DocumentType.salesInvoice => 'Satış',
      DocumentType.receipt => 'Fiş',
      DocumentType.dispatchNote => 'İrsaliye',
      DocumentType.attendance => 'Puantaj',
    };
  }
}

class _AnalysisResultCard extends StatelessWidget {
  const _AnalysisResultCard({required this.analysis});

  final DocumentAnalysisMock analysis;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: _DocumentColors.primary),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI Analiz Sonucu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _DocumentColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: analysis.statusLabel, tone: analysis.statusTone),
            ],
          ),
          const SizedBox(height: 16),
          for (final field in analysis.fields)
            _AnalysisRow(field: field),
          const SizedBox(height: 14),
          Text(
            'Güven Skoru: %${(analysis.confidenceScore * 100).round()}',
            style: const TextStyle(
              color: _DocumentColors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: analysis.confidenceScore,
              minHeight: 7,
              color: _DocumentColors.secondary,
              backgroundColor: _DocumentColors.surfaceHigh,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({required this.field});

  final DocumentAnalysisField field;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _DocumentColors.outlineSoft),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${field.label}:',
              style: const TextStyle(
                color: _DocumentColors.muted,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              field.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: field.label == 'Genel Toplam'
                    ? _DocumentColors.primary
                    : const Color(0xFF191C1D),
                fontSize: field.label == 'Genel Toplam' ? 16 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineItemsList extends StatelessWidget {
  const _LineItemsList({
    required this.title,
    required this.headers,
    required this.items,
  });

  final String title;
  final List<String> headers;
  final List<DocumentLineItemMock> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'Okunan Kalemler',
            style: TextStyle(
              color: _DocumentColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _LineItemCard(headers: headers, item: items[index]);
          },
        ),
      ],
    );
  }
}

class _LineItemCard extends StatelessWidget {
  const _LineItemCard({
    required this.headers,
    required this.item,
  });

  final List<String> headers;
  final DocumentLineItemMock item;

  @override
  Widget build(BuildContext context) {
    final values = item.values;
    final detailValues = values.length > 2
        ? values.sublist(1, values.length - 1).join(' · ')
        : values.skip(1).join(' · ');
    final trailing = values.length > 1 ? values.last : '';

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
                Text(
                  values.first,
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detailValues.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDetail(headers, values, detailValues),
                    style: const TextStyle(
                      color: _DocumentColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              trailing,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _DocumentColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDetail(
    List<String> headers,
    List<String> values,
    String fallback,
  ) {
    if (headers.length >= 5 && values.length >= 5) {
      return '${values[1]} · ${values[2]} · KDV ${values[3]}';
    }
    return fallback;
  }
}

class _ImpactSummary extends StatelessWidget {
  const _ImpactSummary({required this.items});

  final List<AutomationEffectItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DocumentColors.surfaceHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DocumentColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bu belge işlendiğinde',
            style: TextStyle(
              color: _DocumentColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in items.take(4)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: _DocumentColors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.text,
                    style: const TextStyle(
                      color: Color(0xFF191C1D),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            if (item != items.take(4).last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

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
              backgroundColor: _DocumentColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Belgeyi İşle',
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
              foregroundColor: _DocumentColors.muted,
              side: const BorderSide(color: _DocumentColors.outline),
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
          style: TextButton.styleFrom(foregroundColor: _DocumentColors.error),
          child: const Text('Reddet'),
        ),
      ],
    );
  }
}

class _RecentDocuments extends StatelessWidget {
  const _RecentDocuments({required this.items});

  final List<RecentProcessedDocumentMock> items;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Son Belgeler',
                style: TextStyle(
                  color: Color(0xFF191C1D),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: _DocumentColors.primary,
              ),
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: _cardDecoration(),
          child: Column(
            children: [
              for (var index = 0; index < visibleItems.length; index++) ...[
                _RecentDocumentRow(item: visibleItems[index]),
                if (index != visibleItems.length - 1)
                  const Divider(height: 1, color: _DocumentColors.outline),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentDocumentRow extends StatelessWidget {
  const _RecentDocumentRow({required this.item});

  final RecentProcessedDocumentMock item;

  @override
  Widget build(BuildContext context) {
    final success = item.statusTone == StatusTone.success;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _DocumentColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconFor(item.documentType),
              color: _DocumentColors.muted,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.documentType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DocumentColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${success ? '✓' : '⊙'} ${item.statusLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: success ? _DocumentColors.secondary : _DocumentColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('puantaj')) {
      return Icons.assignment_ind_outlined;
    }
    if (lower.contains('irsaliye')) {
      return Icons.local_shipping_outlined;
    }
    return Icons.receipt_long_outlined;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.tone,
  });

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final success = tone == StatusTone.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: success
            ? _DocumentColors.secondaryContainer
            : const Color(0xFFFFDDBA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: success
              ? _DocumentColors.onSecondaryContainer
              : _DocumentColors.warning,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color? borderColor;
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
            side: BorderSide(color: borderColor ?? background),
          ),
        ),
        icon: Icon(icon, size: 19),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: _DocumentColors.surface,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: _DocumentColors.outline),
  );
}
