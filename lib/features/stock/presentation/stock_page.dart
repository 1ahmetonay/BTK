import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/status_badge.dart';
import 'stock_mock_data.dart';
import 'widgets/ai_stock_suggestions_card.dart';
import 'widgets/critical_stock_card.dart';
import 'widgets/product_stock_table_card.dart';
import 'widgets/stock_insights_card.dart';
import 'widgets/stock_movements_card.dart';
import 'widgets/supplier_comparison_card.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  String _selectedFilter = 'Tümü';

  List<StockSummaryMock> _summaries = [];
  List<ProductStockMock> _criticalProducts = [];
  List<ProductStockMock> _allProducts = [];
  List<StockMovementMock> _movements = [];
  List<String> _aiSuggestions = [];
  String _supplierProduct = '';
  List<SupplierComparisonMock> _suppliers = [];
  String _supplierInsight = '';
  List<StockInsightMock> _insights = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    try {
      // Paralel API çağrıları
      final results = await Future.wait([
        ApiService.instance.getStockOverview(),
        ApiService.instance.getCriticalStock(),
        ApiService.instance.getStockMovements(limit: 5),
        ApiService.instance.getAbcAnalysis(),
      ]);

      if (!mounted) return;

      final overview = results[0] as Map<String, dynamic>;
      final criticals = results[1] as List<dynamic>;
      final movements = results[2] as List<dynamic>;
      final abc = results[3] as Map<String, dynamic>;

      // ─── Summary strip ───
      final toplamSku = overview['toplam_sku'] ?? 0;
      final kritikSayi = overview['kritik_stok_sayisi'] ?? 0;
      final stokDegeri = (overview['stok_degeri'] ?? 0.0) as num;
      final devirHizi = overview['ortalama_devir_hizi'] ?? '—';

      final liveSummaries = [
        StockSummaryMock(
          title: 'Toplam SKU',
          value: '$toplamSku',
          description: 'Aktif takip edilen ürün',
          trend: 'Canlı veri',
          trendTone: StatusTone.info,
          icon: Icons.category_outlined,
          accentColor: AppColors.primary,
        ),
        StockSummaryMock(
          title: 'Kritik Stok',
          value: '$kritikSayi',
          description: 'Acil tedarik gerektiren',
          trend: kritikSayi > 3 ? 'Acil!' : 'Takip et',
          trendTone: kritikSayi > 0 ? StatusTone.warning : StatusTone.success,
          icon: Icons.warning_amber_outlined,
          accentColor: AppColors.rose,
        ),
        StockSummaryMock(
          title: 'Stok Değeri',
          value: '${_formatTl(stokDegeri.toDouble())} TL',
          description: 'Tahmini mevcut stok maliyeti',
          trend: 'Güncel',
          trendTone: StatusTone.success,
          icon: Icons.warehouse_outlined,
          accentColor: AppColors.teal,
        ),
        StockSummaryMock(
          title: 'Ortalama Devir Hızı',
          value: '$devirHizi',
          description: 'Ortalama stokta kalma süresi',
          trend: 'Hesaplandı',
          trendTone: StatusTone.success,
          icon: Icons.sync_alt_outlined,
          accentColor: AppColors.emerald,
        ),
      ];

      // ─── Tüm ürünleri map'le (overview.urunler) ───
      final urunler = overview['urunler'] as List<dynamic>? ?? [];
      final liveAllProducts = urunler.map<ProductStockMock>((raw) {
        final m = raw as Map<String, dynamic>;
        final mevcut = (m['mevcut_stok'] ?? 0) as num;
        final minimum = (m['min_stok'] ?? 0) as num;
        final durum = m['durum'] as String? ?? 'Normal';
        final durumTon = m['durum_ton'] as String? ?? 'success';
        return ProductStockMock(
          sku: m['sku'] as String? ?? '—',
          productName: m['isim'] as String? ?? '—',
          category: m['kategori'] as String? ?? '—',
          currentStock: '$mevcut',
          minimumStock: '$minimum',
          lastPurchaseCost: '${m['son_alis_maliyeti'] ?? '—'} TL',
          statusLabel: durum,
          statusTone: durumTon == 'danger'
              ? StatusTone.danger
              : durumTon == 'warning'
                  ? StatusTone.warning
                  : StatusTone.success,
          daysRemaining: '${m['kalan_gun'] ?? '?'}',
        );
      }).toList();

      // ─── Kritik ürünleri map'le ───
      final liveCriticals = criticals.map<ProductStockMock>((raw) {
        final m = raw as Map<String, dynamic>;
        final mevcut = (m['mevcut_stok'] ?? 0) as num;
        final minimum = (m['min_stok'] ?? 0) as num;
        return ProductStockMock(
          sku: m['sku'] as String? ?? '—',
          productName: m['isim'] as String? ?? '—',
          category: m['kategori'] as String? ?? '—',
          currentStock: '$mevcut',
          minimumStock: '$minimum',
          lastPurchaseCost: '${m['son_alis_maliyeti'] ?? '—'} TL',
          statusLabel: 'Kritik',
          statusTone: StatusTone.danger,
          daysRemaining: '${m['kalan_gun'] ?? '?'}',
        );
      }).toList();

      // ─── Hareketleri map'le ───
      final liveMovements = movements.map<StockMovementMock>((raw) {
        final m = raw as Map<String, dynamic>;
        final miktar = (m['miktar'] ?? 0) as num;
        return StockMovementMock(
          title: (m['tip'] ?? m['hareket_tipi']) == 'satin_alma'
              ? 'Satın alma faturası'
              : 'Satış faturası',
          productName: (m['urun_adi'] ?? m['urun_isim']) as String? ?? '—',
          quantityChange: '${miktar > 0 ? '+' : ''}$miktar adet',
          timestamp: m['tarih'] as String? ?? '—',
          tone: miktar > 0 ? StatusTone.success : StatusTone.danger,
        );
      }).toList();

      // ─── AI önerileri (kritik ürünlerden dinamik üretim) ───
      final liveSuggestions = <String>[];
      for (final c in liveCriticals.take(3)) {
        liveSuggestions.add(
          '${c.productName} stok seviyesi ${c.currentStock} ile minimum (${c.minimumStock}) altında. '
          '${c.daysRemaining} içinde bitebilir, acil tedarik önerilir.',
        );
      }
      if (liveSuggestions.isEmpty && liveAllProducts.isNotEmpty) {
        liveSuggestions.add('Tüm ürün stokları normal seviyelerde. Kritik ürün bulunmuyor.');
      }

      // ─── ABC analizi → StockInsights ───
      final aGrubu = abc['a_grubu'] as Map<String, dynamic>? ?? {};
      final bGrubu = abc['b_grubu'] as Map<String, dynamic>? ?? {};
      final cGrubu = abc['c_grubu'] as Map<String, dynamic>? ?? {};
      final aCount = aGrubu['sayi'] as int? ?? 0;
      final bCount = bGrubu['sayi'] as int? ?? 0;
      final cCount = cGrubu['sayi'] as int? ?? 0;
      final toplam = aCount + bCount + cCount;
      final aPct = toplam > 0 ? aCount / toplam : 0.0;
      final bPct = toplam > 0 ? bCount / toplam : 0.0;

      final liveInsights = [
        StockInsightMock(
          title: 'ABC Analizi',
          description: 'A grubu yüksek ciro etkisine sahip ürünler',
          valueLabel: 'A %${(aPct * 100).round()} | B %${(bPct * 100).round()} | C %${((1 - aPct - bPct) * 100).round()}',
          progress: aPct.clamp(0.05, 0.95),
          color: AppColors.primary,
        ),
        StockInsightMock(
          title: 'Kritik Oran',
          description: 'Kritik stok ürünlerinin toplam oranı',
          valueLabel: toplam > 0 ? '%${(kritikSayi / toplam * 100).round()}' : '%0',
          progress: toplam > 0 ? (kritikSayi / toplam).clamp(0.05, 0.95) : 0.05,
          color: AppColors.rose,
        ),
        StockInsightMock(
          title: 'Stok Devir Hızı',
          description: 'Ürünlerin stokta ortalama kalma süresi',
          valueLabel: '$devirHizi',
          progress: 0.18,
          color: AppColors.amber,
        ),
      ];

      // ─── Tedarikçi karşılaştırma (ilk kritik ürün veya ilk ürün) ───
      final supplierSku = liveCriticals.isNotEmpty
          ? liveCriticals.first.sku
          : (liveAllProducts.isNotEmpty ? liveAllProducts.first.sku : null);
      if (supplierSku != null) {
        try {
          final firstSku = supplierSku;
          final supplierData =
              await ApiService.instance.getSupplierComparison(firstSku);
          if (mounted) {
            final tedarikciler =
                supplierData['tedarikciler'] as List<dynamic>? ?? [];
            if (tedarikciler.isNotEmpty) {
              final liveSuppliers =
                  tedarikciler.map<SupplierComparisonMock>((raw) {
                final s = raw as Map<String, dynamic>;
                return SupplierComparisonMock(
                  supplierName: s['tedarikci_adi'] as String? ?? '—',
                  price: '${s['birim_fiyat'] ?? '—'} TL',
                  leadTime: s['teslim_suresi'] as String? ?? '—',
                  trustScore: '${s['guvenilirlik'] ?? '—'}',
                );
              }).toList();

              // En ucuz ve en hızlıyı bul
              String cheapest = liveSuppliers.first.supplierName;
              String fastest = liveSuppliers.first.supplierName;
              double minPrice = double.tryParse(
                      liveSuppliers.first.price.replaceAll(' TL', '')) ??
                  999999;
              for (final s in liveSuppliers) {
                final p =
                    double.tryParse(s.price.replaceAll(' TL', '')) ?? 999999;
                if (p < minPrice) {
                  minPrice = p;
                  cheapest = s.supplierName;
                }
                // leadTime "3 gün" gibi, sayıyı parse et
                final lt = int.tryParse(
                        s.leadTime.replaceAll(RegExp(r'[^0-9]'), '')) ??
                    999;
                final ft = int.tryParse(
                        fastest == s.supplierName
                            ? '999'
                            : liveSuppliers
                                .firstWhere(
                                    (x) => x.supplierName == fastest)
                                .leadTime
                                .replaceAll(RegExp(r'[^0-9]'), '')) ??
                    999;
                if (lt < ft) fastest = s.supplierName;
              }

              setState(() {
                _supplierProduct =
                    supplierData['urun'] as String? ?? _supplierProduct;
                _suppliers = liveSuppliers;
                _supplierInsight =
                    'En düşük fiyat $cheapest, en hızlı teslimat $fastest. '
                    'Acil stok için hız, maliyet optimizasyonu için fiyat odaklı seçim önerilir.';
              });
            }
          }
        } catch (_) {
          // tedarikçi verisi alınamazsa boş kalır
        }
      }

      if (!mounted) return;

      setState(() {
        _summaries = liveSummaries;
        _allProducts = liveAllProducts;
        _criticalProducts = liveCriticals;
        _movements = liveMovements;
        _aiSuggestions = liveSuggestions;
        _insights = liveInsights;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Stok verileri yüklenemedi: $e';
        });
      }
    }
  }

  String _formatTl(double val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}.000';
    return val.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _fetchStockData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StockIntroCard(),
        const SizedBox(height: 16),
        _StockSummaryStrip(summaries: _summaries),
        const SizedBox(height: 16),
        CriticalStockCard(
          products: _criticalProducts.take(3).toList(),
          onRecommend: _showRecommendMessage,
        ),
        const SizedBox(height: 16),
        AiStockSuggestionsCard(suggestions: _aiSuggestions),
        const SizedBox(height: 16),
        _StockSearchAndFilters(
          selectedFilter: _selectedFilter,
          onSelected: (filter) => setState(() => _selectedFilter = filter),
        ),
        const SizedBox(height: 16),
        const _StockSectionTitle('Ürün Stok Durumu'),
        const SizedBox(height: 8),
        ProductStockTableCard(products: _allProducts),
        const SizedBox(height: 16),
        StockMovementsCard(movements: _movements),
        const SizedBox(height: 16),
        SupplierComparisonCard(
          productName: _supplierProduct,
          suppliers: _suppliers,
          aiInsight: _supplierInsight,
        ),
        const SizedBox(height: 16),
        StockInsightsCard(insights: _insights),
      ],
    );
  }

  Future<void> _showRecommendMessage(String productName) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$productName için tedarik önerisi hazırlanıyor...'),
          duration: const Duration(seconds: 1),
        ),
      );
    try {
      final result = await ApiService.instance.sendChat(
        message: '$productName için tedarik önerisi ver. Mevcut stok durumunu, en uygun tedarikçiyi ve sipariş miktarını öner.',
      );
      if (!mounted) return;
      final response = result.response.isNotEmpty ? result.response : 'Öneri alınamadı.';
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('$productName — Tedarik Önerisi'),
          content: SingleChildScrollView(
            child: Text(response, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Tedarik önerisi alınamadı: $e')));
      }
    }
  }
}


class _StockSectionTitle extends StatelessWidget {
  const _StockSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _StockIntroCard extends StatelessWidget {
  const _StockIntroCard();

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
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok Yönetimi',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Ürün stoklarını takip edin, kritik seviyeleri görün.',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'AI destekli önerilerle tedarik, maliyet ve stok risklerini yönetin.',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockSummaryStrip extends StatelessWidget {
  const _StockSummaryStrip({required this.summaries});

  final List<StockSummaryMock> summaries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: summaries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _StockSummaryTile(
            summary: summaries[index],
            highlighted: summaries[index].trendTone == StatusTone.warning,
          );
        },
      ),
    );
  }
}

class _StockSummaryTile extends StatelessWidget {
  const _StockSummaryTile({required this.summary, required this.highlighted});

  final StockSummaryMock summary;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final toneColor = switch (summary.trendTone) {
      StatusTone.success => AppColors.secondary,
      StatusTone.warning => AppColors.error,
      StatusTone.danger => AppColors.error,
      StatusTone.info => AppColors.primary,
      StatusTone.neutral => AppColors.mutedText,
    };

    return Container(
      width: summary.value.length > 8 ? 164 : 142,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.highlightedSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? AppColors.errorContainer
              : AppColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            summary.title == 'Ortalama Devir Hızı'
                ? 'Devir Hızı'
                : summary.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlighted
                  ? AppColors.error
                  : AppColors.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlighted
                  ? AppColors.error
                  : AppColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _summaryFootnote(summary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: toneColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _summaryFootnote(StockSummaryMock summary) {
    return switch (summary.title) {
      'Toplam SKU' => 'Aktif ürün',
      'Kritik Stok' => '3 ürün bugün',
      'Stok Değeri' => 'Tahmini maliyet',
      _ => summary.trend,
    };
  }
}

class _StockSearchAndFilters extends StatelessWidget {
  const _StockSearchAndFilters({
    required this.selectedFilter,
    required this.onSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = ['Tümü', 'Kritik', 'Düşük', 'Normal'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Ürün veya SKU ara',
            prefixIcon: const Icon(Icons.search, color: AppColors.neutral),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in filters) ...[
                _FilterPill(
                  label: filter,
                  selected: selectedFilter == filter,
                  onTap: () => onSelected(filter),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
