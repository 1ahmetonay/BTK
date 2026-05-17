import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/api_service.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.currentRoute,
    required this.onRouteSelected,
    super.key,
  });

  final String currentRoute;
  final ValueChanged<String> onRouteSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.sidebar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandHeader(),
              const SizedBox(height: 26),
              Expanded(
                child: ListView.separated(
                  itemCount: AppRoutes.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = AppRoutes.items[index];
                    final selected = currentRoute == item.route;

                    return _SidebarItem(
                      item: item,
                      selected: selected,
                      onTap: () => onRouteSelected(item.route),
                    );
                  },
                ),
              ),
              const _PlanSummary(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.insights_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                AppStrings.appTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppRouteItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.selected
        ? AppColors.sidebarActive
        : _hovered
            ? const Color(0xFF182230)
            : Colors.transparent;
    final foregroundColor = widget.selected || _hovered
        ? Colors.white
        : const Color(0xFFD0D5DD);
    final iconColor = widget.selected || _hovered
        ? Colors.white
        : const Color(0xFF98A2B3);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      widget.item.icon,
                      key: ValueKey<Color>(iconColor),
                      size: 21,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight:
                            widget.selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      child: Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

class _PlanSummary extends StatefulWidget {
  const _PlanSummary();

  @override
  State<_PlanSummary> createState() => _PlanSummaryState();
}

class _PlanSummaryState extends State<_PlanSummary> {
  bool _connected = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final ok =
          await ApiService.instance.isBackendAvailable();
      if (mounted) setState(() { _connected = ok; _checking = false; });
    } catch (_) {
      if (mounted) setState(() { _connected = false; _checking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _checking
        ? 'Bağlantı kontrol ediliyor…'
        : _connected
            ? 'API Bağlı'
            : 'Demo Veri Modu';
    final subtitle = _checking
        ? 'Backend sunucusu aranıyor.'
        : _connected
            ? 'Tüm veriler backend API üzerinden canlı çekiliyor.'
            : 'Backend kapalı. Ekranlar mock veriyle çalışır.';
    final borderColor = _connected
        ? const Color(0xFF2C694E)
        : const Color(0xFF344054);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF182230),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _connected ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                color: _connected ? const Color(0xFF95D4B3) : const Color(0xFF98A2B3),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
