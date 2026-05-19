import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';

// ─── Veri Modelleri ─────────────────────────────────────────────────────

enum ArchiveRecordType {
  outgoingEinvoice,
  purchaseInvoice,
  receipt,
  dispatchNote,
  timesheet,
}

class ArchiveLineItem {
  const ArchiveLineItem(this.name, this.quantity, this.value);
  final String name;
  final String quantity;
  final String value;
}

class ArchiveRecord {
  const ArchiveRecord({
    this.invoiceId,
    required this.type,
    required this.documentLabel,
    required this.counterparty,
    required this.documentNo,
    required this.date,
    required this.amount,
    required this.statusLabel,
    required this.statusTone,
    required this.xmlSnippet,
    required this.lineItems,
  });

  final int? invoiceId;
  final ArchiveRecordType type;
  final String documentLabel;
  final String counterparty;
  final String documentNo;
  final DateTime date;
  final double amount;
  final String statusLabel;
  final StatusTone statusTone;
  final String xmlSnippet;
  final List<ArchiveLineItem> lineItems;

  factory ArchiveRecord.fromJson(Map<String, dynamic> json) {
    final tur = json['tur'] as String? ?? '';
    final isSale = tur.contains('satis');
    final documentLabel = isSale ? 'Satış E-Faturası' : 'Alış Faturası';
    final counterparty = json['karsi_taraf'] as String?;
    final documentNo = json['fatura_no'] as String?;
    final amount = (json['toplam_tutar'] as num?)?.toDouble() ?? 0;
    final status = _statusView(json['odeme_durumu'] as String?);

    return ArchiveRecord(
      invoiceId: (json['id'] as num?)?.toInt(),
      type: isSale
          ? ArchiveRecordType.outgoingEinvoice
          : ArchiveRecordType.purchaseInvoice,
      documentLabel: documentLabel,
      counterparty: (counterparty == null || counterparty.isEmpty)
          ? 'Karşı taraf bilgisi yok'
          : counterparty,
      documentNo: (documentNo == null || documentNo.isEmpty)
          ? 'Fatura No Yok'
          : documentNo,
      date: _parseDate(json['tarih']) ?? DateTime.now(),
      amount: amount,
      statusLabel: status.label,
      statusTone: status.tone,
      xmlSnippet: _sampleXml(
        (documentNo == null || documentNo.isEmpty)
            ? 'Fatura No Yok'
            : documentNo,
        (counterparty == null || counterparty.isEmpty)
            ? 'Karşı taraf bilgisi yok'
            : counterparty,
      ),
      lineItems: [
        ArchiveLineItem(
          documentLabel,
          'DB kayıt ID: ${json['id'] ?? '-'}',
          _formatMoney(amount),
        ),
        ArchiveLineItem(
          'KDV',
          'Kayıtlı tutar',
          _formatMoney((json['kdv_tutari'] as num?)?.toDouble() ?? 0),
        ),
      ],
    );
  }

  bool get canMarkPaid {
    return invoiceId != null &&
        (statusLabel == 'Ödeme Bekliyor' || statusLabel == 'Bekliyor');
  }

  IconData get icon {
    return switch (type) {
      ArchiveRecordType.outgoingEinvoice => Icons.picture_as_pdf_outlined,
      ArchiveRecordType.purchaseInvoice => Icons.receipt_long_outlined,
      ArchiveRecordType.receipt => Icons.receipt_long_outlined,
      ArchiveRecordType.dispatchNote => Icons.local_shipping_outlined,
      ArchiveRecordType.timesheet => Icons.assignment_ind_outlined,
    };
  }

  Color get iconColor {
    return switch (type) {
      ArchiveRecordType.outgoingEinvoice => AppColors.primary,
      ArchiveRecordType.dispatchNote => AppColors.warningDark,
      ArchiveRecordType.timesheet => AppColors.secondary,
      _ => AppColors.secondary,
    };
  }

  Color get iconBackground {
    return switch (type) {
      ArchiveRecordType.outgoingEinvoice => AppColors.infoSurface,
      ArchiveRecordType.dispatchNote => AppColors.warningLight,
      ArchiveRecordType.timesheet => AppColors.successSurface,
      _ => AppColors.secondaryBg,
    };
  }

  List<String> get filterTags {
    final tags = <String>[statusLabel];
    switch (type) {
      case ArchiveRecordType.outgoingEinvoice:
      case ArchiveRecordType.purchaseInvoice:
        tags.add('Fatura');
      case ArchiveRecordType.receipt:
        tags.add('Fiş');
      case ArchiveRecordType.dispatchNote:
        tags.add('İrsaliye');
      case ArchiveRecordType.timesheet:
        tags.add('Puantaj');
    }
    if (statusLabel == 'Ödeme Bekliyor' || statusLabel == 'Bekliyor') {
      tags.add('Bekliyor');
    }
    return tags;
  }
}

// ─── Sayfa ──────────────────────────────────────────────────────────────

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<ArchiveRecord> _records = [];
  bool _loading = true;
  String? _error;
  String _activeFilter = 'Tümü';
  ArchiveRecord? _expandedRecord;

  static const _filters = [
    'Tümü',
    'Fatura',
    'Bekliyor',
    'Ödendi',
    'Gecikti',
  ];

  @override
  void initState() {
    super.initState();
    _fetchArchive();
  }

  Future<void> _fetchArchive() async {
    try {
      final data = await ApiService.instance.getInvoiceArchive();
      if (!mounted) return;
      setState(() {
        _records = data
            .cast<Map<String, dynamic>>()
            .map((j) => ArchiveRecord.fromJson(j))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Arşiv yüklenemedi: $e';
        });
      }
    }
  }

  List<ArchiveRecord> get _filteredRecords {
    if (_activeFilter == 'Tümü') return _records;
    return _records
        .where((r) => r.filterTags.contains(_activeFilter))
        .toList();
  }

  Future<void> _markAsPaid(ArchiveRecord record) async {
    if (record.invoiceId == null) return;
    try {
      await ApiService.instance.updateInvoicePaymentStatus(
        invoiceId: record.invoiceId!,
        status: 'odendi',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fatura "Ödendi" olarak işaretlendi.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      setState(() {
        _loading = true;
        _error = null;
        _expandedRecord = null;
      });
      _fetchArchive();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _fetchArchive();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredRecords;
    final totalAmount =
        filtered.fold<double>(0, (sum, r) => sum + r.amount);
    final paidCount =
        filtered.where((r) => r.statusLabel == 'Ödendi').length;
    final waitingCount =
        filtered.where((r) => r.canMarkPaid).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Başlık ──
        SectionCard(
          title: 'Arşiv Defteri',
          subtitle: 'E-faturalar ve işlenen belgeler',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatChip(
                label: '${filtered.length} Kayıt',
                icon: Icons.folder_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: _formatMoney(totalAmount),
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.secondary,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  size: 16, color: AppColors.emerald),
              const SizedBox(width: 4),
              Text(
                '$paidCount ödendi',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.emerald),
              ),
              const SizedBox(width: 16),
              if (waitingCount > 0) ...[
                Icon(Icons.schedule, size: 16, color: AppColors.amber),
                const SizedBox(width: 4),
                Text(
                  '$waitingCount bekliyor',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.amber),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Filtreler ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: _activeFilter == f,
                        onSelected: (_) =>
                            setState(() => _activeFilter = f),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _activeFilter == f
                              ? Colors.white
                              : AppColors.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: AppColors.surfaceWhite,
                        side: BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),

        // ── Liste ──
        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 48, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text(
                    _activeFilter == 'Tümü'
                        ? 'Henüz arşivlenmiş belge yok.'
                        : '"$_activeFilter" filtresiyle eşleşen kayıt yok.',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = filtered[index];
              final isExpanded = _expandedRecord == record;
              return _ArchiveRecordCard(
                record: record,
                isExpanded: isExpanded,
                onTap: () => setState(() =>
                    _expandedRecord = isExpanded ? null : record),
                onMarkPaid: record.canMarkPaid
                    ? () => _markAsPaid(record)
                    : null,
                onCopyXml: () => _copyXml(record),
              );
            },
          ),
      ],
    );
  }

  void _copyXml(ArchiveRecord record) {
    Clipboard.setData(ClipboardData(text: record.xmlSnippet));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('XML panoya kopyalandı'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// ─── Kart Widget'ı ──────────────────────────────────────────────────────

class _ArchiveRecordCard extends StatelessWidget {
  const _ArchiveRecordCard({
    required this.record,
    required this.isExpanded,
    required this.onTap,
    this.onMarkPaid,
    required this.onCopyXml,
  });

  final ArchiveRecord record;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onMarkPaid;
  final VoidCallback onCopyXml;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: _cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              // ── Özet satırı ──
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: record.iconBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(record.icon,
                          color: record.iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.documentNo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${record.counterparty} • ${_formatDate(record.date)}',
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatMoney(record.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(
                          label: record.statusLabel,
                          tone: record.statusTone,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ],
                ),
              ),

              // ── Detay paneli (genişletilmiş) ──
              if (isExpanded) _buildExpandedPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceUltraLight,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        border: Border(top: BorderSide(color: AppColors.outline, width: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Belge tipi etiketi
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: record.iconBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.documentLabel,
                  style: TextStyle(
                    color: record.iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${record.invoiceId ?? '-'}',
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kalem tablosu
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                // Başlık
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text('Kalem',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mutedText))),
                      Expanded(
                          flex: 2,
                          child: Text('Detay',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mutedText))),
                      Expanded(
                          flex: 2,
                          child: Text('Tutar',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mutedText))),
                    ],
                  ),
                ),
                // Satırlar
                ...record.lineItems.map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: AppColors.outline, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(item.name,
                                  style: const TextStyle(fontSize: 12))),
                          Expanded(
                              flex: 2,
                              child: Text(item.quantity,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted))),
                          Expanded(
                              flex: 2,
                              child: Text(item.value,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // XML Önizleme
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code, color: Colors.white54, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'UBL-TR XML Önizleme',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: onCopyXml,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy, color: Colors.white54, size: 12),
                            SizedBox(width: 4),
                            Text('Kopyala',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  record.xmlSnippet.trim(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFF89B4FA),
                    height: 1.4,
                  ),
                  maxLines: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Aksiyon butonları
          Row(
            children: [
              if (onMarkPaid != null)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Ödendi İşaretle'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              if (onMarkPaid != null) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopyXml,
                  icon: const Icon(Icons.code, size: 18),
                  label: const Text('XML Kopyala'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    side: const BorderSide(color: AppColors.outline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Yardımcı Widget'lar ────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Yardımcı Fonksiyonlar ──────────────────────────────────────────────

class _StatusView {
  const _StatusView(this.label, this.tone);
  final String label;
  final StatusTone tone;
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.outline),
  );
}

String _formatDate(DateTime date) {
  const months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatMoney(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final buffer = StringBuffer();
  for (var i = 0; i < parts.first.length; i++) {
    final reverseIndex = parts.first.length - i;
    buffer.write(parts.first[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return '${buffer.toString()}.${parts.last} TL';
}

DateTime? _parseDate(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

_StatusView _statusView(String? value) {
  final normalized = value?.trim().toLowerCase();
  return switch (normalized) {
    'odendi' ||
    'ödendi' ||
    'paid' =>
      const _StatusView('Ödendi', StatusTone.success),
    'gecikti' ||
    'vadesi_gecti' ||
    'vadesi geçti' =>
      const _StatusView('Gecikti', StatusTone.danger),
    'islendi' ||
    'işlendi' =>
      const _StatusView('AI ile İşlendi', StatusTone.info),
    _ => const _StatusView('Ödeme Bekliyor', StatusTone.warning),
  };
}

String _sampleXml(String documentNo, String partyName) {
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
  <cbc:ID>$documentNo</cbc:ID>
  <cbc:IssueDate>2026-05-19</cbc:IssueDate>
  <cac:AccountingCustomerParty>
    <cac:Party>
      <cbc:Name>$partyName</cbc:Name>
    </cac:Party>
  </cac:AccountingCustomerParty>
  <cac:InvoiceLine>
    <cbc:InvoicedQuantity unitCode="C62">1</cbc:InvoicedQuantity>
    <cbc:LineExtensionAmount currencyID="TRY">100.00</cbc:LineExtensionAmount>
  </cac:InvoiceLine>
</Invoice>
''';
}
