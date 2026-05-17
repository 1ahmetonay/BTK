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
