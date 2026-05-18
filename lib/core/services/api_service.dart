/// KOBİ AI Asistan — API Service
/// Backend ile tüm HTTP iletişimini yönetir.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Backend URL — akıllı platform algılama
  static String get _baseUrl {
    // 1. dart-define ile override edilebilir (en yüksek öncelik)
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // 2. Web: tarayıcının mevcut origin'ini kullan (same-origin, CORS sorunu yok)
    //    Eğer aynı sunucudan serve ediliyorsa (flutter build web → backend static)
    //    boş baseUrl = relative path kullanır
    if (kIsWeb) {
      // Debug modda (flutter run -d chrome): localhost:8000'e bağlan
      if (kDebugMode) return 'http://localhost:8000';
      // Release modda: aynı sunucudan serve edildiği için boş = same origin
      return '';
    }

    // 3. Android emülatör: 10.0.2.2 = host makinenin localhost'u
    // Gerçek cihazda: flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000
    return 'http://10.0.2.2:8000';
  }

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ─── Dashboard ─────────────────────────────────────────────────────

  /// Ana sayfa özet verileri
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _dio.get('/api/v1/dashboard/summary');
    return response.data as Map<String, dynamic>;
  }

  /// Sabah brifingi
  Future<Map<String, dynamic>> getMorningBrief() async {
    final response = await _dio.get('/api/v1/dashboard/morning-brief');
    return response.data as Map<String, dynamic>;
  }

  // ─── Stok ──────────────────────────────────────────────────────────

  /// Stok genel durumu
  Future<Map<String, dynamic>> getStockOverview() async {
    final response = await _dio.get('/api/v1/stock/overview');
    return response.data as Map<String, dynamic>;
  }

  /// Kritik stok ürünleri
  Future<List<dynamic>> getCriticalStock() async {
    final response = await _dio.get('/api/v1/stock/critical');
    return response.data as List<dynamic>;
  }

  /// Son stok hareketleri
  Future<List<dynamic>> getStockMovements({int limit = 20}) async {
    final response = await _dio.get(
      '/api/v1/stock/movements',
      queryParameters: {'limit': limit},
    );
    return response.data as List<dynamic>;
  }

  /// ABC stok analizi
  Future<Map<String, dynamic>> getAbcAnalysis() async {
    final response = await _dio.get('/api/v1/stock/abc-analysis');
    return response.data as Map<String, dynamic>;
  }

  /// Ürün detaylı analiz
  Future<Map<String, dynamic>> getProductAnalysis(String sku) async {
    final response = await _dio.get('/api/v1/stock/$sku/analysis');
    return response.data as Map<String, dynamic>;
  }

  /// Tedarikçi karşılaştırma
  Future<Map<String, dynamic>> getSupplierComparison(String sku) async {
    final response = await _dio.get('/api/v1/stock/$sku/suppliers');
    return response.data as Map<String, dynamic>;
  }

  // ─── Finans ────────────────────────────────────────────────────────

  /// Gelir-gider özeti
  Future<Map<String, dynamic>> getPlSummary({int? ay, int? yil}) async {
    final params = <String, dynamic>{};
    if (ay != null) params['ay'] = ay;
    if (yil != null) params['yil'] = yil;
    final response = await _dio.get(
      '/api/v1/finance/pl',
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Nakit akışı
  Future<Map<String, dynamic>> getCashflow({int gun = 30}) async {
    final response = await _dio.get(
      '/api/v1/finance/cashflow',
      queryParameters: {'gun': gun},
    );
    return response.data as Map<String, dynamic>;
  }

  /// KDV özeti
  Future<Map<String, dynamic>> getKdvSummary({int? ay, int? yil}) async {
    final params = <String, dynamic>{};
    if (ay != null) params['ay'] = ay;
    if (yil != null) params['yil'] = yil;
    final response = await _dio.get(
      '/api/v1/finance/kdv',
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Gecikmiş ödemeler
  Future<List<dynamic>> getOverduePayments() async {
    final response = await _dio.get('/api/v1/finance/overdue');
    return response.data as List<dynamic>;
  }

  /// Son faturalar
  Future<List<dynamic>> getRecentInvoices({int limit = 10}) async {
    final response = await _dio.get(
      '/api/v1/finance/invoices',
      queryParameters: {'limit': limit},
    );
    return response.data as List<dynamic>;
  }

  // ─── Belge İşleme ─────────────────────────────────────────────────

  /// Fatura/belge yükle ve işle
  Future<Map<String, dynamic>> processDocument(List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _dio.post('/api/v1/document/process', data: formData);
    return response.data as Map<String, dynamic>;
  }

  /// Demo modda belge işle (dosya yüklemeden)
  Future<Map<String, dynamic>> processDocumentDemo() async {
    final response = await _dio.post('/api/v1/document/process-demo');
    return response.data as Map<String, dynamic>;
  }

  // ─── Chat (AI Asistan) ─────────────────────────────────────────────

  /// AI asistana soru sor (ChatResult modeli ile)
  Future<ChatResult> sendChat({
    required String message,
    String? conversationId,
    String? aiMode,
  }) async {
    final body = {
      'message': message,
      if (conversationId != null) 'conversation_id': conversationId,
      if (aiMode != null) 'ai_mode': aiMode,
    };
    final res = await _dio.post('/api/v1/chat', data: body);
    return ChatResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// Konuşmayı sıfırla
  Future<void> resetConversation(String conversationId) async {
    await _dio.delete('/api/v1/chat/$conversationId');
  }

  /// AI önerileri
  Future<Map<String, dynamic>> getAiSuggestions() async {
    final response = await _dio.get('/api/v1/chat/suggestions');
    return response.data as Map<String, dynamic>;
  }

  // ─── İK / Puantaj ─────────────────────────────────────────────────

  /// Puantaj belgesi yükle ve işle
  Future<Map<String, dynamic>> processTimesheet(List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _dio.post('/api/v1/hr/timesheet/process', data: formData);
    return response.data as Map<String, dynamic>;
  }

  /// Demo modda puantaj işle
  Future<Map<String, dynamic>> processTimesheetDemo() async {
    final response = await _dio.post('/api/v1/hr/timesheet/process-demo');
    return response.data as Map<String, dynamic>;
  }

  /// Çalışan listesi
  Future<List<dynamic>> getEmployees() async {
    final response = await _dio.get('/api/v1/hr/employees');
    return response.data as List<dynamic>;
  }

  /// Maaş bordrosu
  Future<Map<String, dynamic>> getPayroll({int? ay, int? yil}) async {
    final params = <String, dynamic>{};
    if (ay != null) params['ay'] = ay;
    if (yil != null) params['yil'] = yil;
    final response = await _dio.get(
      '/api/v1/hr/payroll',
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  // ─── Uyarılar ──────────────────────────────────────────────────────

  /// Tüm uyarılar
  Future<List<dynamic>> getAlerts({String? oncelik, bool okunmamis = false}) async {
    final params = <String, dynamic>{'okunmamis': okunmamis};
    if (oncelik != null) params['oncelik'] = oncelik;
    final response = await _dio.get(
      '/api/v1/alerts',
      queryParameters: params,
    );
    return response.data as List<dynamic>;
  }

  /// Okunmamış uyarı sayısı
  Future<int> getUnreadAlertCount() async {
    final response = await _dio.get('/api/v1/alerts/count');
    return (response.data as Map<String, dynamic>)['count'] as int;
  }

  /// Uyarıyı okundu işaretle
  Future<void> markAlertAsRead(int alertId) async {
    await _dio.put('/api/v1/alerts/$alertId/read');
  }

  /// Uyarı aksiyonu alındı
  Future<void> markAlertActionTaken(int alertId) async {
    await _dio.put('/api/v1/alerts/$alertId/action');
  }

  // ─── Sağlık Kontrolü ──────────────────────────────────────────────

  /// Backend bağlantı kontrolü
  Future<bool> isBackendAvailable() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── E-Fatura ─────────────────────────────────────────────────────

  /// E-Fatura üret (UBL-TR XML + QR + PDF)
  Future<Map<String, dynamic>> generateEfatura(Map<String, dynamic> invoiceData) async {
    final response = await _dio.post('/api/v1/invoice/generate', data: invoiceData);
    return response.data as Map<String, dynamic>;
  }

  /// Demo e-fatura üret
  Future<Map<String, dynamic>> generateDemoEfatura() async {
    final response = await _dio.post('/api/v1/invoice/generate-demo');
    return response.data as Map<String, dynamic>;
  }

  // ─── Gelişmiş Stok Analizi ────────────────────────────────────────

  /// Ürün mevsimsellik analizi
  Future<Map<String, dynamic>> getSeasonalityPattern(String sku) async {
    final response = await _dio.get('/api/v1/stock/$sku/seasonality');
    return response.data as Map<String, dynamic>;
  }

  /// What-If fiyat simülasyonu
  Future<Map<String, dynamic>> simulatePriceChange(String sku, double changePct) async {
    final response = await _dio.post(
      '/api/v1/stock/$sku/simulate',
      data: {'price_change_pct': changePct},
    );
    return response.data as Map<String, dynamic>;
  }
}

// ─── Chat Yanıt Modeli ──────────────────────────────────────────────

class ChatResult {
  final String response;
  final String conversationId;
  final List<String> toolsUsed;
  final List<Map<String, dynamic>> thinkingSteps;

  ChatResult({
    required this.response,
    required this.conversationId,
    required this.toolsUsed,
    required this.thinkingSteps,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) => ChatResult(
        response: json['response'] as String? ?? '',
        conversationId: json['conversation_id'] as String? ?? '',
        toolsUsed:
            (json['tools_used'] as List?)?.map((e) => e.toString()).toList() ??
                [],
        thinkingSteps: (json['thinking_steps'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [],
      );
}
