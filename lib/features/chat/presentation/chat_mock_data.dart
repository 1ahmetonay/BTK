import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum ChatRole { user, assistant }

class ToolUsageMock {
  const ToolUsageMock(this.name);

  final String name;
}

class AiResponseMock {
  const AiResponseMock({
    required this.message,
    required this.tools,
    required this.steps,
  });

  final String message;
  final List<ToolUsageMock> tools;
  final List<String> steps;
}

class ChatMessageMock {
  const ChatMessageMock({
    required this.id,
    required this.role,
    required this.message,
    required this.timestamp,
    this.tools = const [],
    this.steps = const [],
  });

  final String id;
  final ChatRole role;
  final String message;
  final DateTime timestamp;
  final List<ToolUsageMock> tools;
  final List<String> steps;
}

class SuggestedQuestionMock {
  const SuggestedQuestionMock({
    required this.question,
    required this.icon,
  });

  final String question;
  final IconData icon;
}

class RecentAiAnalysisMock {
  const RecentAiAnalysisMock({
    required this.title,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
}

class ChatMockData {
  const ChatMockData._();

  static const initialAssistantMessage =
      'Merhaba, ben KOBİ AI Asistan. Stok, finans, KDV, puantaj ve tedarik verilerinizi analiz edebilirim. Örneğin ‘Önümüzdeki ay nakit sıkışması yaşar mıyım?’ diye sorabilirsiniz.';

  static const defaultSteps = [
    'Soru yorumlandı',
    'İlgili modül seçildi',
    'Mock veri tarandı',
    'Risk ve öneri üretildi',
  ];

  static const suggestedQuestions = [
    SuggestedQuestionMock(
      question: 'Önümüzdeki ay nakit sıkışması yaşar mıyım?',
      icon: Icons.account_balance_wallet_outlined,
    ),
    SuggestedQuestionMock(
      question: 'Bu ay en kârlı 5 ürün hangileri?',
      icon: Icons.trending_up_outlined,
    ),
    SuggestedQuestionMock(
      question: 'Filtre Kahve 1kg için tedarikçi karşılaştırması yap',
      icon: Icons.compare_arrows_outlined,
    ),
    SuggestedQuestionMock(
      question: 'KDV durumum nedir?',
      icon: Icons.receipt_long_outlined,
    ),
    SuggestedQuestionMock(
      question: 'Kargo poşeti stoğu ne zaman biter?',
      icon: Icons.inventory_2_outlined,
    ),
    SuggestedQuestionMock(
      question: 'Puantajda kontrol gerektiren çalışan var mı?',
      icon: Icons.groups_2_outlined,
    ),
  ];

  static const availableTools = [
    ToolUsageMock('get_stock_levels'),
    ToolUsageMock('get_cash_forecast'),
    ToolUsageMock('get_kdv_summary'),
    ToolUsageMock('compare_suppliers'),
    ToolUsageMock('get_employee_attendance'),
    ToolUsageMock('process_document'),
  ];

  static const recentAnalyses = [
    RecentAiAnalysisMock(
      title: 'Nakit açığı riski tespit edildi',
      icon: Icons.warning_amber_outlined,
      iconColor: AppColors.rose,
    ),
    RecentAiAnalysisMock(
      title: 'Filtre Kahve maliyet artışı analiz edildi',
      icon: Icons.trending_up_outlined,
      iconColor: AppColors.amber,
    ),
    RecentAiAnalysisMock(
      title: 'Kargo poşeti stok bitiş tahmini üretildi',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.primary,
    ),
    RecentAiAnalysisMock(
      title: 'Mayıs KDV özeti hesaplandı',
      icon: Icons.receipt_long_outlined,
      iconColor: AppColors.emerald,
    ),
  ];

  static AiResponseMock responseFor(String question) {
    final normalized = question.toLowerCase();

    if (_containsAny(normalized, ['kdv', 'vergi', 'beyanname'])) {
      return const AiResponseMock(
        message:
            'Mayıs 2026 dönemi için hesaplanan KDV 47.425 TL, indirilecek KDV 35.150 TL, tahmini ödenecek KDV 12.275 TL. Beyanname son tarihi 26 Mayıs 2026. Takip gerekli.',
        tools: [
          ToolUsageMock('get_kdv_summary'),
          ToolUsageMock('get_tax_deadlines'),
        ],
        steps: defaultSteps,
      );
    }

    if (_containsAny(normalized, ['puantaj', 'çalışan', 'mesai', 'izin'])) {
      return const AiResponseMock(
        message:
            'Mayıs 2026 puantajında 5 çalışan işlendi. Zeynep Arslan için 3 izin günü ve kontrol gerekli durumu görünüyor. Mehmet Kaya 12 saat mesai ile en yüksek ek mesaiye sahip.',
        tools: [
          ToolUsageMock('get_employee_attendance'),
          ToolUsageMock('calculate_salary'),
        ],
        steps: defaultSteps,
      );
    }

    if (_containsAny(normalized, ['tedarikçi', 'karşılaştır', 'tedarik'])) {
      return const AiResponseMock(
        message:
            'Filtre Kahve 1kg için üç tedarikçi karşılaştırıldı: Aksoy Tedarik 310 TL / 3 gün, Marmara Gıda 298 TL / 5 gün, Ege Kahve Deposu 322 TL / 2 gün. Acil stok için Ege Kahve Deposu, maliyet optimizasyonu için Marmara Gıda önerilir.',
        tools: [
          ToolUsageMock('compare_suppliers'),
          ToolUsageMock('get_stock_levels'),
        ],
        steps: defaultSteps,
      );
    }

    if (_containsAny(normalized, ['kârlı', 'karlı', 'kar', 'kâr', 'marj'])) {
      return const AiResponseMock(
        message:
            'Bu ay en yüksek kâr marjı Türk Kahvesi 250g ürününde görünüyor. Satış hacmi yüksek ve birim marj korunmuş. Ancak Filtre Kahve 1kg maliyeti son 6 ayda %31 arttığı için net marjı aşağı çekiyor.',
        tools: [
          ToolUsageMock('get_pl_summary'),
          ToolUsageMock('get_product_margin_analysis'),
        ],
        steps: defaultSteps,
      );
    }

    if (_containsAny(normalized, ['stok', 'biter', 'kritik', 'ürün', 'kargo poşeti'])) {
      return const AiResponseMock(
        message:
            'Kargo Poşeti Orta Boy mevcut stok 31 adet, minimum seviye 80. Son 14 günlük tüketim hızına göre yaklaşık 11 gün içinde bitebilir. Minimum stok seviyesinin 80’den 120’ye çıkarılması önerilir.',
        tools: [
          ToolUsageMock('get_stock_levels'),
          ToolUsageMock('get_product_movements'),
        ],
        steps: defaultSteps,
      );
    }

    if (_containsAny(normalized, ['nakit', 'finans', 'para', 'ödeme', 'tahsilat'])) {
      return const AiResponseMock(
        message:
            '30 günlük projeksiyona göre 14 gün sonra 42.000 TL nakit açığı riski görünüyor. Bu riskin ana nedeni Aksoy Tedarik ödemesi ve gecikmiş 3 tahsilat. Önerim: Aksoy Tedarik ödemesini 10 gün ertelemek ve toplam 38.800 TL gecikmiş tahsilat için hatırlatma göndermek.',
        tools: [
          ToolUsageMock('get_cash_forecast'),
          ToolUsageMock('get_overdue_payments'),
        ],
        steps: defaultSteps,
      );
    }

    return const AiResponseMock(
      message:
          'Bu soruyu analiz etmek için stok, finans ve belge kayıtlarını birlikte değerlendirmem gerekir. Demo modunda örnek olarak nakit akışı, kritik stok, KDV, tedarikçi ve puantaj sorularını yanıtlayabiliyorum.',
      tools: [
        ToolUsageMock('get_stock_levels'),
        ToolUsageMock('get_cash_forecast'),
        ToolUsageMock('process_document'),
      ],
      steps: defaultSteps,
    );
  }

  static bool _containsAny(String value, List<String> keywords) {
    return keywords.any(value.contains);
  }
}
