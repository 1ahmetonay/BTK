import 'package:kobi_ai_asistan/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_sidebar.dart';
import 'shared/widgets/app_topbar.dart';

class KobiAIAsistanApp extends StatelessWidget {
  const KobiAIAsistanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.dashboard,
      onGenerateRoute: (settings) {
        final route = AppRoutes.normalize(settings.name);

        return MaterialPageRoute<void>(
          settings: RouteSettings(name: route),
          builder: (_) => AppShell(initialRoute: route),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({required this.initialRoute, super.key});

  final String initialRoute;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late String _currentRoute;
  final Map<String, Widget> _pageCache = {};

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;

        if (isWide) {
          return _buildWideLayout(constraints);
        }
        return _buildNarrowLayout(constraints);
      },
    );
  }

  /// Geniş ekran (web / tablet): sidebar + geniş içerik alanı
  Widget _buildWideLayout(BoxConstraints constraints) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          // Sabit sidebar
          AppSidebar(
            currentRoute: _currentRoute,
            onRouteSelected: _goTo,
          ),
          // Ana içerik
          Expanded(
            child: Column(
              children: [
                AppTopbar(
                  title: AppRoutes.titleFor(_currentRoute),
                  subtitle: AppRoutes.subtitleFor(_currentRoute),
                  compact: false,
                  showMenuButton: false,
                  onAlertsPressed: () => _goTo(AppRoutes.alerts),
                  onSettingsPressed: () => _goTo(AppRoutes.settings),
                ),
                Expanded(
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Center(
                      child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        reverseDuration: const Duration(milliseconds: 160),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0, 0.01),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<String>(_currentRoute),
                          child: _pageFor(_currentRoute),
                        ),
                      ),
                    ),
                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dar ekran (mobil): bottom nav + drawer sidebar
  Widget _buildNarrowLayout(BoxConstraints constraints) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: Builder(
          builder: (drawerContext) {
            return AppSidebar(
              currentRoute: _currentRoute,
              onRouteSelected: (route) {
                Navigator.of(drawerContext).pop();
                _goTo(route);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _ShellBottomNavigation(
          selectedIndex: _bottomIndexFor(_currentRoute),
          onDestinationSelected: (index) => _goTo(_bottomRoutes[index]),
        ),
      ),
      body: Column(
        children: [
          AppTopbar(
            title: AppRoutes.titleFor(_currentRoute),
            subtitle: AppRoutes.subtitleFor(_currentRoute),
            compact: constraints.maxWidth < 700,
            showMenuButton: true,
            onAlertsPressed: () => _goTo(AppRoutes.alerts),
            onSettingsPressed: () => _goTo(AppRoutes.settings),
          ),
          Expanded(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        reverseDuration: const Duration(milliseconds: 160),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0, 0.01),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<String>(_currentRoute),
                          child: _pageFor(_currentRoute),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _bottomRoutes = [
    AppRoutes.dashboard,
    AppRoutes.documents,
    AppRoutes.chat,
    AppRoutes.finance,
    AppRoutes.stock,
  ];

  int _bottomIndexFor(String route) {
    final index = _bottomRoutes.indexOf(route);
    return index == -1 ? 0 : index;
  }

  Widget _pageFor(String route) {
    return _pageCache.putIfAbsent(
      route,
      () => AppRoutes.pageFor(route, onNavigate: _goTo),
    );
  }

  void _goTo(String route) {
    if (route == _currentRoute) {
      return;
    }

    setState(() {
      _currentRoute = route;
    });
  }
}

class _ShellBottomNavigation extends StatelessWidget {
  const _ShellBottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    _BottomNavItem(
      label: 'Ana Sayfa',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _BottomNavItem(
      label: 'Belgeler',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
    ),
    _BottomNavItem(
      label: 'AI',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
    ),
    _BottomNavItem(
      label: 'Finans',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
    ),
    _BottomNavItem(
      label: 'Stok',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: SizedBox(
              height: 58,
              child: Row(
                children: [
                  for (var index = 0; index < _items.length; index++)
                    Expanded(
                      child: _BottomNavButton(
                        item: _items[index],
                        selected: selectedIndex == index,
                        onTap: () => onDestinationSelected(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.primary
        : AppColors.mutedText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.successLight : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: foreground,
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
