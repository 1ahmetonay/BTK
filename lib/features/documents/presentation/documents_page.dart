import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/efatura_dialog.dart';
import '../../../shared/widgets/status_badge.dart';
import 'documents_mock_data.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  DocumentType _selectedType = DocumentType.purchaseInvoice;

  // Gerçek analiz sonucu (Gemini demo'dan)
  DocumentScenarioMock? _liveScenario;
  List<RecentProcessedDocumentMock> _recentDocs = [];
  bool _analyzing = false;

  // Seçilen dosya bilgileri
  List<int>? _pickedFileBytes;
  String _pickedFileName = '';

  @override
  void initState() {
    super.initState();
    _fetchRecentDocs();
  }

  Future<void> _fetchRecentDocs() async {
    try {
      final invoices = await ApiService.instance.getRecentInvoices(limit: 5);
      if (!mounted || invoices.isEmpty) return;

      final live = invoices.map<RecentProcessedDocumentMock>((raw) {
        final m = raw as Map<String, dynamic>;
        final tur = m['tur'] as String? ?? 'fatura';
        final isSales = tur.contains('satis');
        return RecentProcessedDocumentMock(
          documentType: isSales ? 'Satış Faturası' : 'Satın Alma Faturası',
          source: m['karsi_taraf'] as String? ?? '—',
          value: '${m['toplam_tutar'] ?? '—'} TL',
          statusLabel: m['odeme_durumu'] == 'odendi' ? 'Ödendi' : 'Ödeme Bekliyor',
          statusTone: m['odeme_durumu'] == 'odendi'
              ? StatusTone.success
              : StatusTone.warning,
        );
      }).toList();

      setState(() {
        _recentDocs = live;
      });
    } catch (_) {
      // Backend bağlantısı yoksa boş kalır
    }
  }

  @override
  Widget build(BuildContext context) {
    // Canlı analiz sonucu varsa onu göster, yoksa seçili belge tipinin mock'unu
    final scenario = _liveScenario;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeaderCard(),
        const SizedBox(height: 12),
        _EFaturaKesButton(onPressed: () => _openEFaturaDialog(context)),
        const SizedBox(height: 16),
        _UploadCard(
          analysis: scenario?.analysis,
          analyzing: _analyzing,
          onAnalyze: _handleGeminiAnalyze,
          onPickFile: _handlePickFile,
          pickedFileName: _pickedFileName,
        ),
        const SizedBox(height: 16),
        _DocumentTypeSelector(
          selectedType: _selectedType,
          onSelectionChanged: _updateSelection,
        ),
        if (scenario != null) ...[
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
        ],
        const SizedBox(height: 20),
        _RecentDocuments(items: _recentDocs),
        const SizedBox(height: 12),
      ],
    );
  }

  void _updateSelection(DocumentType selection) {
    setState(() {
      _selectedType = selection;
      _liveScenario = null; // Tip değişince canlı sonucu temizle
    });
  }

  Future<void> _handleGeminiAnalyze() async {
    setState(() => _analyzing = true);
    try {
      final Map<String, dynamic> result;
      if (_pickedFileBytes != null && _pickedFileBytes!.isNotEmpty) {
        result = await ApiService.instance.processDocument(_pickedFileBytes!, _pickedFileName);
      } else {
        result = await ApiService.instance.processDocumentDemo();
      }
      if (!mounted) return;

      // Backend sonucunu DocumentScenarioMock'a dönüştür
      // Backend düz yapıda döner: {fatura_no, tur, toplam_tutar, kdv_tutari, gemini_output, stok_guncellemeleri}
      // gemini_output içinde kalemler var
      final geminiOut = result['gemini_output'] as Map<String, dynamic>? ?? {};
      final faturaTur = result['tur'] as String? ?? geminiOut['belge_tipi'] as String? ?? 'Fatura';
      final karsiTaraf = geminiOut['satici_adi'] as String? ?? '—';
      final faturaNo = result['fatura_no'] as String? ?? geminiOut['fatura_no'] as String? ?? '—';
      final tarih = geminiOut['tarih'] as String? ?? '—';
      final toplamTutar = result['toplam_tutar'] ?? geminiOut['genel_toplam'];
      final kdvTutar = result['kdv_tutari'] ?? geminiOut['toplam_kdv'];
      final kalemler = geminiOut['kalemler'] as List<dynamic>? ?? [];
      final stokEtki = result['stok_guncellemeleri'] as List<dynamic>? ?? [];

      final fields = <DocumentAnalysisField>[
        DocumentAnalysisField(label: 'Belge tipi', value: faturaTur),
        DocumentAnalysisField(label: 'Satıcı/Kaynak', value: karsiTaraf),
        DocumentAnalysisField(label: 'Fatura No', value: faturaNo),
        DocumentAnalysisField(label: 'Tarih', value: tarih),
        DocumentAnalysisField(label: 'Genel Toplam', value: '${toplamTutar ?? '—'} TL'),
        DocumentAnalysisField(label: 'Toplam KDV', value: '${kdvTutar ?? '—'} TL'),
      ];

      final lineItems = kalemler.map<DocumentLineItemMock>((raw) {
        final m = raw as Map<String, dynamic>;
        return DocumentLineItemMock(values: [
          m['urun_adi'] as String? ?? '—',
          '${m['miktar'] ?? '—'} adet',
          '${m['birim_fiyat'] ?? '—'} TL',
          '%${m['kdv_orani'] ?? 20}',
          '${m['satir_toplam'] ?? m['toplam'] ?? '—'} TL',
        ]);
      }).toList();

      final effects = <AutomationEffectItem>[
        if (kalemler.isNotEmpty)
          AutomationEffectItem(
            icon: Icons.check_circle_outline,
            text: 'Stoklara ${kalemler.length} ürün için giriş hareketi eklendi',
          ),
        if (kdvTutar != null)
          AutomationEffectItem(
            icon: Icons.auto_awesome_outlined,
            text: 'KDV defterine $kdvTutar TL indirilecek KDV kaydı düşüldü',
            iconColor: AppColors.primary,
          ),
        if (toplamTutar != null)
          AutomationEffectItem(
            icon: Icons.account_balance_wallet_outlined,
            text: 'Nakit akışı $toplamTutar TL çıkış olarak güncellendi',
            iconColor: AppColors.rose,
          ),
        for (final etki in stokEtki.take(2))
          AutomationEffectItem(
            icon: Icons.inventory_2_outlined,
            text: () {
              final m = etki as Map<String, dynamic>;
              return m['aciklama'] as String? ?? '${m['urun'] ?? 'Ürün'}: stok güncellendi';
            }(),
            iconColor: AppColors.amber,
          ),
      ];

      final guven = (result['guven_skoru'] as num?)?.toDouble() ?? 0.92;

      setState(() {
        _liveScenario = DocumentScenarioMock(
          analysis: DocumentAnalysisMock(
            type: _selectedType,
            selectedFileName: geminiOut['dosya_adi'] as String? ?? 'gemini_analiz_sonucu.jpg',
            fields: fields,
            confidenceScore: guven,
            statusLabel: 'AI ile İşlendi',
            statusTone: StatusTone.success,
          ),
          tableTitle: 'Gemini ile Okunan Kalemler',
          tableSubtitle: 'AI analizi sonucu yapılandırılan satırlar',
          tableHeaders: const ['Ürün', 'Miktar', 'Birim Fiyat', 'KDV', 'Toplam'],
          lineItems: lineItems.isNotEmpty ? lineItems : [const DocumentLineItemMock(values: ['Demo veri', '—', '—', '—', '—'])],
          automationEffects: effects.isNotEmpty ? effects : [const AutomationEffectItem(icon: Icons.check_circle_outline, text: 'Belge işlendi')],
        );

        // Son belgelere ekle
        _recentDocs = [
          RecentProcessedDocumentMock(
            documentType: faturaTur,
            source: karsiTaraf,
            value: '${toplamTutar ?? '—'} TL',
            statusLabel: 'AI ile İşlendi',
            statusTone: StatusTone.success,
          ),
          ..._recentDocs.take(3),
        ];

        _analyzing = false;
      });

      _showMessage('Belge Gemini AI ile başarıyla analiz edildi!');
    } catch (e) {
      if (mounted) {
        setState(() => _analyzing = false);
        _showMessage('Analiz hatası: $e');
      }
    }
  }

  Future<void> _handlePickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'tiff'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (!mounted) return;
      setState(() {
        _pickedFileBytes = file.bytes;
        _pickedFileName = file.name;
      });
      _showMessage('${file.name} seçildi. "Gemini ile Analiz Et" ile işleyebilirsiniz.');
    } catch (e) {
      if (mounted) _showMessage('Dosya seçilemedi: $e');
    }
  }

  void _handleProcess() {
    if (_liveScenario == null) {
      _showMessage('Önce belge analiz edilmelidir.');
      return;
    }
    // Belge zaten Gemini analizi sırasında backend'de kaydedildi
    // (fatura, stok hareketi, KDV kaydı, nakit akışı oluşturuldu)
    final kalemSayisi = _liveScenario!.lineItems.length;
    _showMessage(
      '${_selectedType.label} başarıyla kayıtlara eklendi. '
      '$kalemSayisi kalem işlendi. Stok, KDV ve nakit akışı güncellendi.',
    );
    _fetchRecentDocs();
  }

  void _handleManualEdit() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manuel Düzenleme'),
        content: const Text('Analiz sonuçlarını düzenlemek için ilgili alana dokunun. Değişiklikler onaylandıktan sonra sisteme işlenecektir.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Anladım')),
        ],
      ),
    );
  }

  void _handleReject() {
    setState(() => _liveScenario = null);
    _showMessage('Belge reddedildi.');
  }

  Future<void> _openEFaturaDialog(BuildContext context) async {
    final result = await showEFaturaDialog(context);
    if (result != null && mounted) {
      _showMessage('E-Fatura ${result['fatura_no']} başarıyla oluşturuldu!');
    }
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
  const _UploadCard({
    required this.analysis,
    this.analyzing = false,
    this.onAnalyze,
    this.onPickFile,
    this.pickedFileName = '',
  });

  final DocumentAnalysisMock? analysis;
  final bool analyzing;
  final VoidCallback? onAnalyze;
  final VoidCallback? onPickFile;
  final String pickedFileName;

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
            'PDF, JPG, PNG, TIFF • Maks. 10 MB',
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
                    pickedFileName.isNotEmpty
                        ? pickedFileName
                        : (analysis?.selectedFileName ?? 'Belge seçilmedi'),
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
            onPressed: onPickFile ?? () {},
          ),
          const SizedBox(height: 8),
          _FullWidthButton(
            icon: Icons.photo_camera_outlined,
            label: 'Fotoğraf Çek',
            background: Colors.white,
            foreground: _DocumentColors.primary,
            borderColor: _DocumentColors.primary,
            onPressed: onPickFile ?? () {},
          ),
          const SizedBox(height: 8),
          analyzing
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Gemini analiz ediyor...', style: TextStyle(color: _DocumentColors.muted, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              : _FullWidthButton(
                  icon: Icons.smart_toy_outlined,
                  label: 'Gemini ile Analiz Et',
                  background: _DocumentColors.secondaryContainer,
                  foreground: _DocumentColors.onSecondaryContainer,
                  onPressed: onAnalyze ?? () {},
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

  void _showAllDocuments(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tüm Son Belgeler'),
        content: SizedBox(
          width: 420,
          child: items.isEmpty
              ? const Text('Henüz işlenmiş belge yok.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFE1E3E4)),
                  itemBuilder: (_, i) {
                    final doc = items[i];
                    return ListTile(
                      dense: true,
                      title: Text(doc.documentType),
                      subtitle: Text('${doc.source} • ${doc.value}'),
                      trailing: StatusBadge(
                        label: doc.statusLabel,
                        tone: doc.statusTone,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

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
              onPressed: () => _showAllDocuments(context),
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

class _EFaturaKesButton extends StatelessWidget {
  const _EFaturaKesButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1a4d2e), Color(0xFF002045)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.receipt_long, color: Color(0xFFAEEECB), size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-Fatura Kes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'UBL-TR XML • QR Doğrulama • PDF',
                      style: TextStyle(
                        color: Color(0xFFAEEECB),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
