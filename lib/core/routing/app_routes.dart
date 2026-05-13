import 'package:flutter/material.dart';

import '../../features/alerts/presentation/alerts_page.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/documents/presentation/documents_page.dart';
import '../../features/employees/presentation/employees_page.dart';
import '../../features/finance/presentation/finance_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/stock/presentation/stock_page.dart';

class AppRouteItem {
  const AppRouteItem({
    required this.route,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String route;
  final String title;
  final String subtitle;
  final IconData icon;
}

class AppRoutes {
  const AppRoutes._();

  static const dashboard = '/';
  static const documents = '/documents';
  static const stock = '/stock';
  static const finance = '/finance';
  static const chat = '/chat';
  static const alerts = '/alerts';
  static const employees = '/employees';
  static const settings = '/settings';

  static const items = [
    AppRouteItem(
      route: dashboard,
      title: 'Ana Sayfa',
      subtitle: 'Günlük operasyon özeti',
      icon: Icons.dashboard_outlined,
    ),
    AppRouteItem(
      route: documents,
      title: 'Belge İşleme',
      subtitle: 'Fatura ve evrak akışı',
      icon: Icons.description_outlined,
    ),
    AppRouteItem(
      route: stock,
      title: 'Stok Yönetimi',
      subtitle: 'Ürün, depo ve kritik stok',
      icon: Icons.inventory_2_outlined,
    ),
    AppRouteItem(
      route: finance,
      title: 'Finans',
      subtitle: 'Nakit akışı ve alacak takibi',
      icon: Icons.account_balance_wallet_outlined,
    ),
    AppRouteItem(
      route: chat,
      title: 'AI Asistan',
      subtitle: 'İşletme verileriyle sohbet',
      icon: Icons.auto_awesome_outlined,
    ),
    AppRouteItem(
      route: alerts,
      title: 'Uyarılar',
      subtitle: 'Riskler ve aksiyonlar',
      icon: Icons.notifications_active_outlined,
    ),
    AppRouteItem(
      route: employees,
      title: 'Puantaj / Çalışanlar',
      subtitle: 'Vardiya, izin ve mesai',
      icon: Icons.groups_2_outlined,
    ),
    AppRouteItem(
      route: settings,
      title: 'Ayarlar',
      subtitle: 'Firma ve uygulama tercihleri',
      icon: Icons.settings_outlined,
    ),
  ];

  static String normalize(String? route) {
    if (items.any((item) => item.route == route)) {
      return route!;
    }
    return dashboard;
  }

  static String titleFor(String route) {
    return items.firstWhere((item) => item.route == route).title;
  }

  static String subtitleFor(String route) {
    return items.firstWhere((item) => item.route == route).subtitle;
  }

  static Widget pageFor(
    String route, {
    ValueChanged<String>? onNavigate,
  }) {
    return switch (route) {
      documents => const DocumentsPage(),
      stock => const StockPage(),
      finance => const FinancePage(),
      chat => const ChatPage(),
      alerts => const AlertsPage(),
      employees => const EmployeesPage(),
      settings => const SettingsPage(),
      _ => DashboardPage(onNavigate: onNavigate),
    };
  }
}
