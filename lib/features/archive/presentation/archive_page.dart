import 'package:flutter/material.dart';
import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:kobi_ai_asistan/core/services/api_service.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<dynamic> _invoices = [];
  bool _loading = true;
  String? _error;
  String _filterTur = 'tumu';

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.instance.getInvoiceArchive(limit: 200);
      if (!mounted) return;
      setState(() {
        _invoices = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Arşiv verileri yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  List<dynamic> get _filteredInvoices {
    if (_filterTur == 'tumu') return _invoices;
    return _invoices.where((f) => f['tur'] == _filterTur).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.archive_outlined, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Arşiv Defteri',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildFilterChip('Tümü', 'tumu'),
              const SizedBox(width: 8),
              _buildFilterChip('Satış', 'satis'),
              const SizedBox(width: 8),
              _buildFilterChip('Alış', 'alis'),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _loadInvoices,
                icon: const Icon(Icons.refresh),
                tooltip: 'Yenile',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _filterTur == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filterTur = value),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadInvoices,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    final invoices = _filteredInvoices;
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive_outlined, size: 64, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text(
              _filterTur == 'tumu'
                  ? 'Henüz kayıtlı fatura yok.'
                  : 'Bu kategoride fatura bulunamadı.',
              style: TextStyle(color: AppColors.mutedText, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final f = invoices[index];
        return _InvoiceCard(invoice: f);
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});
  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    final tur = invoice['tur'] ?? '';
    final isSatis = tur == 'satis';
    final color = isSatis ? AppColors.emeraldDark : AppColors.warningDark;
    final icon = isSatis ? Icons.arrow_upward : Icons.arrow_downward;
    final turLabel = isSatis ? 'Satış' : 'Alış';
    final tutar = (invoice['toplam_tutar'] as num?)?.toDouble() ?? 0;
    final kdv = (invoice['kdv_tutari'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          invoice['fatura_no'] ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${invoice['karsi_taraf'] ?? '-'} · $turLabel · ${invoice['tarih'] ?? '-'}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${tutar.toStringAsFixed(0)} TL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 15,
              ),
            ),
            Text(
              'KDV: ${kdv.toStringAsFixed(0)} TL',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
            _buildOdemeBadge(invoice['odeme_durumu']),
          ],
        ),
      ),
    );
  }

  Widget _buildOdemeBadge(String? durum) {
    Color bg;
    String label;
    switch (durum) {
      case 'odendi':
        bg = AppColors.emeraldDark;
        label = 'Ödendi';
        break;
      case 'gecikti':
        bg = AppColors.error;
        label = 'Gecikti';
        break;
      default:
        bg = AppColors.warningDark;
        label = 'Bekliyor';
    }
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: bg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
