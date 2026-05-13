import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';

enum DocumentType {
  purchaseInvoice,
  salesInvoice,
  receipt,
  dispatchNote,
  attendance,
}

extension DocumentTypeLabel on DocumentType {
  String get label {
    return switch (this) {
      DocumentType.purchaseInvoice => 'Satın Alma Faturası',
      DocumentType.salesInvoice => 'Satış Faturası',
      DocumentType.receipt => 'Fiş',
      DocumentType.dispatchNote => 'İrsaliye',
      DocumentType.attendance => 'Puantaj',
    };
  }
}

class DocumentAnalysisField {
  const DocumentAnalysisField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class DocumentAnalysisMock {
  const DocumentAnalysisMock({
    required this.type,
    required this.selectedFileName,
    required this.fields,
    required this.confidenceScore,
    required this.statusLabel,
    required this.statusTone,
  });

  final DocumentType type;
  final String selectedFileName;
  final List<DocumentAnalysisField> fields;
  final double confidenceScore;
  final String statusLabel;
  final StatusTone statusTone;
}

class DocumentLineItemMock {
  const DocumentLineItemMock({
    required this.values,
  });

  final List<String> values;
}

class AutomationEffectItem {
  const AutomationEffectItem({
    required this.icon,
    required this.text,
    this.iconColor = AppColors.emerald,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
}

class RecentProcessedDocumentMock {
  const RecentProcessedDocumentMock({
    required this.documentType,
    required this.source,
    required this.value,
    required this.statusLabel,
    required this.statusTone,
  });

  final String documentType;
  final String source;
  final String value;
  final String statusLabel;
  final StatusTone statusTone;
}

class DocumentScenarioMock {
  const DocumentScenarioMock({
    required this.analysis,
    required this.tableTitle,
    required this.tableSubtitle,
    required this.tableHeaders,
    required this.lineItems,
    required this.automationEffects,
  });

  final DocumentAnalysisMock analysis;
  final String tableTitle;
  final String tableSubtitle;
  final List<String> tableHeaders;
  final List<DocumentLineItemMock> lineItems;
  final List<AutomationEffectItem> automationEffects;
}

class DocumentsMockData {
  const DocumentsMockData._();

  static const supportedFormats = 'PDF, JPG, PNG, WebP desteklenir';

  static const recentDocuments = [
    RecentProcessedDocumentMock(
      documentType: 'Satış faturası',
      source: 'Trendyol Siparişleri',
      value: '32.100 TL',
      statusLabel: 'İşlendi',
      statusTone: StatusTone.success,
    ),
    RecentProcessedDocumentMock(
      documentType: 'Puantaj belgesi',
      source: 'Mayıs 2026',
      value: '5 çalışan',
      statusLabel: 'Kontrol bekliyor',
      statusTone: StatusTone.warning,
    ),
    RecentProcessedDocumentMock(
      documentType: 'İrsaliye',
      source: 'Marmara Lojistik',
      value: '72 koli',
      statusLabel: 'İşlendi',
      statusTone: StatusTone.success,
    ),
    RecentProcessedDocumentMock(
      documentType: 'Fiş',
      source: 'Ofis Giderleri',
      value: '1.240 TL',
      statusLabel: 'İşlendi',
      statusTone: StatusTone.success,
    ),
  ];

  static const scenarios = {
    DocumentType.purchaseInvoice: DocumentScenarioMock(
      analysis: DocumentAnalysisMock(
        type: DocumentType.purchaseInvoice,
        selectedFileName: 'aksoy_tedarik_faturasi_mayis_2026.jpg',
        fields: [
          DocumentAnalysisField(label: 'Belge tipi', value: 'Satın Alma Faturası'),
          DocumentAnalysisField(label: 'Satıcı', value: 'Aksoy Tedarik Ltd.'),
          DocumentAnalysisField(label: 'Fatura No', value: 'AKS-2026-0518'),
          DocumentAnalysisField(label: 'Tarih', value: '18 Mayıs 2026'),
          DocumentAnalysisField(label: 'Genel Toplam', value: '18.450 TL'),
          DocumentAnalysisField(label: 'Toplam KDV', value: '3.075 TL'),
        ],
        confidenceScore: 0.94,
        statusLabel: 'İşlenmeye hazır',
        statusTone: StatusTone.success,
      ),
      tableTitle: 'Fatura Kalemleri',
      tableSubtitle: 'Belgeden okunup yapılandırılan ürün satırları',
      tableHeaders: ['Ürün', 'Miktar', 'Birim Fiyat', 'KDV', 'Toplam'],
      lineItems: [
        DocumentLineItemMock(
          values: ['Türk Kahvesi 250g', '50 adet', '120 TL', '%20', '6.000 TL'],
        ),
        DocumentLineItemMock(
          values: ['Filtre Kahve 1kg', '20 adet', '310 TL', '%20', '6.200 TL'],
        ),
        DocumentLineItemMock(
          values: ['Kargo Poşeti Orta Boy', '500 adet', '5,50 TL', '%20', '2.750 TL'],
        ),
        DocumentLineItemMock(
          values: ['Termal Etiket 100x150', '200 adet', '17,50 TL', '%20', '3.500 TL'],
        ),
      ],
      automationEffects: [
        AutomationEffectItem(
          icon: Icons.check_circle_outline,
          text: 'Stoklara 4 ürün için giriş hareketi eklenecek',
        ),
        AutomationEffectItem(
          icon: Icons.auto_awesome_outlined,
          text: 'KDV defterine 3.075 TL indirilecek KDV kaydı düşülecek',
          iconColor: AppColors.primary,
        ),
        AutomationEffectItem(
          icon: Icons.account_balance_wallet_outlined,
          text: 'Nakit akışı 18.450 TL çıkış olarak güncellenecek',
          iconColor: AppColors.rose,
        ),
        AutomationEffectItem(
          icon: Icons.badge_outlined,
          text: 'Aksoy Tedarik Ltd. tedarikçi geçmişine eklenecek',
        ),
        AutomationEffectItem(
          icon: Icons.inventory_2_outlined,
          text: 'Kritik stok seviyesi yeniden hesaplanacak',
          iconColor: AppColors.amber,
        ),
      ],
    ),
    DocumentType.salesInvoice: DocumentScenarioMock(
      analysis: DocumentAnalysisMock(
        type: DocumentType.salesInvoice,
        selectedFileName: 'trendyol_satis_faturasi_mayis_2026.pdf',
        fields: [
          DocumentAnalysisField(label: 'Belge tipi', value: 'Satış Faturası'),
          DocumentAnalysisField(label: 'Müşteri/Kanal', value: 'Trendyol Siparişleri'),
          DocumentAnalysisField(label: 'Fatura No', value: 'TRD-2026-0521'),
          DocumentAnalysisField(label: 'Tarih', value: '21 Mayıs 2026'),
          DocumentAnalysisField(label: 'Genel Toplam', value: '32.100 TL'),
          DocumentAnalysisField(label: 'Toplam KDV', value: '5.350 TL'),
        ],
        confidenceScore: 0.96,
        statusLabel: 'Stok düşümü bekliyor',
        statusTone: StatusTone.warning,
      ),
      tableTitle: 'Satış Kalemleri',
      tableSubtitle: 'Satış kaydına dönüştürülecek ürün satırları',
      tableHeaders: ['Ürün', 'Miktar', 'Birim Fiyat', 'KDV', 'Toplam'],
      lineItems: [
        DocumentLineItemMock(
          values: ['Türk Kahvesi 250g', '120 adet', '165 TL', '%20', '19.800 TL'],
        ),
        DocumentLineItemMock(
          values: ['Filtre Kahve 1kg', '30 adet', '410 TL', '%20', '12.300 TL'],
        ),
      ],
      automationEffects: [
        AutomationEffectItem(
          icon: Icons.inventory_2_outlined,
          text: 'Stoklardan 2 ürün için çıkış hareketi düşülecek',
          iconColor: AppColors.amber,
        ),
        AutomationEffectItem(
          icon: Icons.trending_up_outlined,
          text: 'Gelir tablosuna 32.100 TL satış kaydı eklenecek',
          iconColor: AppColors.emerald,
        ),
        AutomationEffectItem(
          icon: Icons.receipt_long_outlined,
          text: 'Hesaplanan KDV 5.350 TL olarak güncellenecek',
          iconColor: AppColors.primary,
        ),
        AutomationEffectItem(
          icon: Icons.insights_outlined,
          text: 'En kârlı ürün analizi yeniden hesaplanacak',
        ),
        AutomationEffectItem(
          icon: Icons.account_balance_wallet_outlined,
          text: 'Nakit akışı 32.100 TL giriş olarak güncellenecek',
          iconColor: AppColors.emerald,
        ),
      ],
    ),
    DocumentType.receipt: DocumentScenarioMock(
      analysis: DocumentAnalysisMock(
        type: DocumentType.receipt,
        selectedFileName: 'ofis_market_fis_20_mayis_2026.webp',
        fields: [
          DocumentAnalysisField(label: 'Belge tipi', value: 'Fiş'),
          DocumentAnalysisField(label: 'Satıcı', value: 'Ofis Market'),
          DocumentAnalysisField(label: 'Fiş No', value: 'FIS-88421'),
          DocumentAnalysisField(label: 'Tarih', value: '20 Mayıs 2026'),
          DocumentAnalysisField(label: 'Genel Toplam', value: '1.240 TL'),
          DocumentAnalysisField(label: 'Toplam KDV', value: '206 TL'),
        ],
        confidenceScore: 0.91,
        statusLabel: 'Gider kaydı hazır',
        statusTone: StatusTone.info,
      ),
      tableTitle: 'Fiş Kalemleri',
      tableSubtitle: 'Gider kaydına dönüşecek satır detayları',
      tableHeaders: ['Ürün', 'Miktar', 'Birim Fiyat', 'KDV', 'Toplam'],
      lineItems: [
        DocumentLineItemMock(
          values: ['Yazıcı Kağıdı', '5 paket', '120 TL', '%20', '600 TL'],
        ),
        DocumentLineItemMock(
          values: ['Koli Bandı', '10 adet', '38 TL', '%20', '380 TL'],
        ),
        DocumentLineItemMock(
          values: ['Temizlik Malzemesi', '1 set', '260 TL', '%20', '260 TL'],
        ),
      ],
      automationEffects: [
        AutomationEffectItem(
          icon: Icons.payments_outlined,
          text: 'Ofis giderleri kategorisine 1.240 TL gider kaydı eklenecek',
          iconColor: AppColors.rose,
        ),
        AutomationEffectItem(
          icon: Icons.receipt_long_outlined,
          text: 'KDV defterine 206 TL indirilecek KDV eklenecek',
          iconColor: AppColors.primary,
        ),
        AutomationEffectItem(
          icon: Icons.account_balance_wallet_outlined,
          text: 'Nakit akışı küçük gider olarak güncellenecek',
          iconColor: AppColors.amber,
        ),
        AutomationEffectItem(
          icon: Icons.pie_chart_outline,
          text: 'Aylık gider dağılımı yeniden hesaplanacak',
        ),
      ],
    ),
    DocumentType.dispatchNote: DocumentScenarioMock(
      analysis: DocumentAnalysisMock(
        type: DocumentType.dispatchNote,
        selectedFileName: 'marmara_lojistik_irsaliye_19_mayis_2026.png',
        fields: [
          DocumentAnalysisField(label: 'Belge tipi', value: 'İrsaliye'),
          DocumentAnalysisField(label: 'Firma', value: 'Marmara Lojistik'),
          DocumentAnalysisField(label: 'Belge No', value: 'IRS-2026-774'),
          DocumentAnalysisField(label: 'Tarih', value: '19 Mayıs 2026'),
          DocumentAnalysisField(label: 'Genel Toplam', value: '72 koli'),
          DocumentAnalysisField(label: 'Toplam KDV', value: 'Yok'),
        ],
        confidenceScore: 0.89,
        statusLabel: 'Teslimat doğrulama bekliyor',
        statusTone: StatusTone.warning,
      ),
      tableTitle: 'İrsaliye Kalemleri',
      tableSubtitle: 'Teslim alınan ürünler ve kontrol aksiyonları',
      tableHeaders: ['Ürün', 'Miktar', 'Durum', 'Hasar', 'Aksiyon'],
      lineItems: [
        DocumentLineItemMock(
          values: ['Türk Kahvesi 250g', '40 koli', 'Teslim alındı', 'Hasarsız', 'Depoya yönlendirildi'],
        ),
        DocumentLineItemMock(
          values: ['Kargo Poşeti Orta Boy', '20 koli', 'Teslim alındı', 'Hasarsız', 'Sayım bekliyor'],
        ),
        DocumentLineItemMock(
          values: ['Termal Etiket 100x150', '12 koli', 'Teslim alındı', 'Kısmi hasar', 'Kontrol gerekli'],
        ),
      ],
      automationEffects: [
        AutomationEffectItem(
          icon: Icons.checklist_outlined,
          text: 'Teslim alınan ürünler depo kontrol listesine eklenecek',
        ),
        AutomationEffectItem(
          icon: Icons.warning_amber_outlined,
          text: 'Kısmi hasarlı kalem için kontrol uyarısı oluşturulacak',
          iconColor: AppColors.rose,
        ),
        AutomationEffectItem(
          icon: Icons.inventory_outlined,
          text: 'Sayım bekleyen ürünler stok onay kuyruğuna alınacak',
          iconColor: AppColors.amber,
        ),
        AutomationEffectItem(
          icon: Icons.local_shipping_outlined,
          text: 'Lojistik performans kaydı güncellenecek',
          iconColor: AppColors.primary,
        ),
      ],
    ),
    DocumentType.attendance: DocumentScenarioMock(
      analysis: DocumentAnalysisMock(
        type: DocumentType.attendance,
        selectedFileName: 'puantaj_mayis_2026.xlsx_onizleme.png',
        fields: [
          DocumentAnalysisField(label: 'Belge tipi', value: 'Puantaj'),
          DocumentAnalysisField(label: 'Dönem', value: 'Mayıs 2026'),
          DocumentAnalysisField(label: 'Belge No', value: 'PNT-2026-05'),
          DocumentAnalysisField(label: 'Tarih', value: '31 Mayıs 2026'),
          DocumentAnalysisField(label: 'Genel Toplam', value: '5 çalışan'),
          DocumentAnalysisField(label: 'Toplam KDV', value: 'Yok'),
        ],
        confidenceScore: 0.88,
        statusLabel: 'Kontrol bekliyor',
        statusTone: StatusTone.warning,
      ),
      tableTitle: 'Puantaj Satırları',
      tableSubtitle: 'Çalışan bazında gün, mesai ve izin detayları',
      tableHeaders: ['Çalışan', 'Çalışma Günü', 'Mesai', 'İzin', 'Aksiyon'],
      lineItems: [
        DocumentLineItemMock(
          values: ['Ahmet Yılmaz', '22 gün', '8 saat mesai', '1 izin', 'Maaş hesaplanacak'],
        ),
        DocumentLineItemMock(
          values: ['Elif Demir', '21 gün', '4 saat mesai', '2 izin', 'Maaş hesaplanacak'],
        ),
        DocumentLineItemMock(
          values: ['Mehmet Kaya', '24 gün', '12 saat mesai', '0 izin', 'Maaş hesaplanacak'],
        ),
        DocumentLineItemMock(
          values: ['Zeynep Arslan', '20 gün', '0 saat mesai', '3 izin', 'Kontrol gerekli'],
        ),
        DocumentLineItemMock(
          values: ['Burak Çelik', '23 gün', '6 saat mesai', '0 izin', 'Maaş hesaplanacak'],
        ),
      ],
      automationEffects: [
        AutomationEffectItem(
          icon: Icons.groups_2_outlined,
          text: '5 çalışan için puantaj kaydı oluşturulacak',
        ),
        AutomationEffectItem(
          icon: Icons.calculate_outlined,
          text: 'Maaş hesaplama modülü tetiklenecek',
          iconColor: AppColors.primary,
        ),
        AutomationEffectItem(
          icon: Icons.fact_check_outlined,
          text: 'Eksik/izin günleri kontrol listesine eklenecek',
          iconColor: AppColors.amber,
        ),
        AutomationEffectItem(
          icon: Icons.account_balance_wallet_outlined,
          text: 'Mesai giderleri finans modülüne aktarılacak',
          iconColor: AppColors.rose,
        ),
        AutomationEffectItem(
          icon: Icons.notifications_active_outlined,
          text: 'Kontrol gerekli çalışanlar için uyarı üretilecek',
        ),
      ],
    ),
  };

  static DocumentScenarioMock scenarioFor(DocumentType type) {
    return scenarios[type]!;
  }
}
