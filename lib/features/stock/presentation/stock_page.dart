import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import 'stock_mock_data.dart';
import 'widgets/ai_stock_suggestions_card.dart';
import 'widgets/critical_stock_card.dart';
import 'widgets/product_stock_table_card.dart';
import 'widgets/stock_insights_card.dart';
import 'widgets/stock_movements_card.dart';
import 'widgets/supplier_comparison_card.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  String _selectedFilter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StockIntroCard(),
        const SizedBox(height: 16),
        const _StockSummaryStrip(summaries: StockMockData.summaries),
        const SizedBox(height: 16),
        CriticalStockCard(
          products: StockMockData.criticalProducts.take(3).toList(),
          onRecommend: _showRecommendMessage,
        ),
        const SizedBox(height: 16),
        const AiStockSuggestionsCard(suggestions: StockMockData.aiSuggestions),
        const SizedBox(height: 16),
        _StockSearchAndFilters(
          selectedFilter: _selectedFilter,
          onSelected: (filter) => setState(() => _selectedFilter = filter),
        ),
        const SizedBox(height: 16),
        const _StockSectionTitle('Ürün Stok Durumu'),
        const SizedBox(height: 8),
        const ProductStockTableCard(products: StockMockData.allProducts),
        const SizedBox(height: 16),
        const StockMovementsCard(movements: StockMockData.movements),
        const SizedBox(height: 16),
        const SupplierComparisonCard(
          productName: StockMockData.selectedSupplierProduct,
          suppliers: StockMockData.suppliers,
          aiInsight: StockMockData.supplierInsight,
        ),
        const SizedBox(height: 16),
        const StockInsightsCard(insights: StockMockData.insights),
      ],
    );
  }

  void _showRecommendMessage(String productName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$productName için tedarik önerisi hazırlanıyor.'),
        ),
      );
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
        color: Color(0xFF002045),
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
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF002045), width: 4)),
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
                color: Color(0xFF002045),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Ürün stoklarını takip edin, kritik seviyeleri görün.',
              style: TextStyle(
                color: Color(0xFF43474E),
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
      StatusTone.success => const Color(0xFF2C694E),
      StatusTone.warning => const Color(0xFFBA1A1A),
      StatusTone.danger => const Color(0xFFBA1A1A),
      StatusTone.info => const Color(0xFF002045),
      StatusTone.neutral => const Color(0xFF43474E),
    };

    return Container(
      width: summary.value.length > 8 ? 164 : 142,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFF7F5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? const Color(0xFFFFDAD6)
              : const Color(0xFFC4C6CF),
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
                  ? const Color(0xFFBA1A1A)
                  : const Color(0xFF43474E),
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
                  ? const Color(0xFFBA1A1A)
                  : const Color(0xFF002045),
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
            prefixIcon: const Icon(Icons.search, color: Color(0xFF74777F)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF002045),
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
          color: selected ? const Color(0xFF002045) : const Color(0xFFE7E8E9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF43474E),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
