import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// --- Global API Service Provider ---
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});

// --- Dashboard Data Providers ---
final dashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getDashboardSummary();
});

final morningBriefProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMorningBrief();
});

// --- Stock Data Providers ---
final stockOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getStockOverview();
});

final criticalStockProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getCriticalStock();
});

// --- Finance Data Providers ---
final financePlProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int?>>((ref, params) async {
  final api = ref.watch(apiServiceProvider);
  return api.getPlSummary(ay: params['ay'], yil: params['yil']);
});

final financeCashflowProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getCashflow();
});

// --- HR Data Providers ---
final employeesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getEmployees();
});

// --- Alerts Data Providers ---
final alertsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getAlerts();
});

final unreadAlertsCountProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getUnreadAlertCount();
});

// Refresh destekli alerts (okundu işaretleme sonrası)
final alertsRefreshProvider = StateProvider<int>((ref) => 0);
final alertsLiveProvider = FutureProvider<List<dynamic>>((ref) async {
  ref.watch(alertsRefreshProvider); // refresh tetikleyici
  final api = ref.watch(apiServiceProvider);
  return api.getAlerts();
});

// --- Finance Extended Providers ---
final financeKdvProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getKdvSummary();
});

final financeOverdueProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getOverduePayments();
});

// --- AI Mode Provider ---
/// AI çalışma modu: "balanced", "careful", "proactive"
final aiModeProvider = StateProvider<String>((ref) => 'proactive');

// --- Stock Extended Providers ---
final stockMovementsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getStockMovements();
});

final abcAnalysisProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getAbcAnalysis();
});
