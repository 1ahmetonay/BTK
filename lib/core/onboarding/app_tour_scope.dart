import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/app_colors.dart';

/// Uygulama genelinde tek bir Showcase scope'u kaydeder.
///
/// Bu widget MaterialApp seviyesinde sarmalayıcı olarak kullanılır. Böylece
/// sayfalar sadece hedef widget'ları Showcase ile sarar ve controller üzerinden
/// turu başlatır.
class AppTourScope extends StatefulWidget {
  const AppTourScope({required this.child, super.key});

  static const defaultScope = 'app_tour';

  final Widget child;

  @override
  State<AppTourScope> createState() => _AppTourScopeState();
}

class _AppTourScopeState extends State<AppTourScope> {
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      scope: AppTourScope.defaultScope,
      skipIfTargetNotPresent: true,
      enableAutoScroll: true,
      scrollDuration: const Duration(milliseconds: 360),
      overlayColor: Colors.black,
      overlayOpacity: 0.72,
      blurValue: 0,
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 8,
      ),
      globalTooltipActions: const [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'Geç',
          backgroundColor: AppColors.surfaceHigh,
          textStyle: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Sonraki',
          backgroundColor: AppColors.primary,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
