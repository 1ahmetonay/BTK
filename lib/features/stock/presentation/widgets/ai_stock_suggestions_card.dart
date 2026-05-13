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
            Icon(Icons.smart_toy_outlined, color: Color(0xFF2C694E), size: 20),
            SizedBox(width: 8),
            Text(
              'AI STOK ÖNERİLERİ',
              style: TextStyle(
                color: Color(0xFF002045),
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
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF95D4B3), width: 3)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF191C1D),
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
        const Color(0xFF0E5138),
        FontWeight.w800,
      ),
      '%31 arttı.': (const Color(0xFFBA1A1A), FontWeight.w800),
      '%22 arttı.': (const Color(0xFF0E5138), FontWeight.w800),
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
