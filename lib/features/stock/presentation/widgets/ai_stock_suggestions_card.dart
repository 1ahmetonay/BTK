import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AiStockSuggestionsCard extends StatelessWidget {
  const AiStockSuggestionsCard({required this.suggestions, super.key});

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: AppColors.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'AI STOK ÖNERİLERİ',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final suggestion in suggestions) ...[
          _SuggestionTile(text: suggestion),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.text});

  final String text;

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
        border: Border(left: BorderSide(color: AppColors.secondaryLight, width: 3)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 13,
              height: 1.35,
            ),
            children: _spansFor(text),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _spansFor(String value) {
    final highlights = <String, (Color, FontWeight)>{
      'En az 80 adet sipariş önerilir.': (
        AppColors.onSecondaryContainer,
        FontWeight.w800,
      ),
      '%31 arttı.': (AppColors.error, FontWeight.w800),
      '%22 arttı.': (AppColors.onSecondaryContainer, FontWeight.w800),
    };

    for (final entry in highlights.entries) {
      if (value.contains(entry.key)) {
        final parts = value.split(entry.key);
        return [
          TextSpan(text: parts.first),
          TextSpan(
            text: entry.key,
            style: TextStyle(color: entry.value.$1, fontWeight: entry.value.$2),
          ),
          if (parts.length > 1)
            TextSpan(text: parts.sublist(1).join(entry.key)),
        ];
      }
    }

    return [TextSpan(text: value)];
  }
}
