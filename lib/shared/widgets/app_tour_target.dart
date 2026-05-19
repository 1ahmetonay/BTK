import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../core/constants/app_colors.dart';
import '../../core/onboarding/app_tour_scope.dart';

/// Bir tur adımının hedefini ve metnini tanımlar.
class AppTourStep {
  const AppTourStep({
    required this.key,
    required this.title,
    required this.description,
    this.tooltipPosition,
    this.targetPadding = const EdgeInsets.all(6),
    this.targetBorderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  final GlobalKey key;
  final String title;
  final String description;
  final TooltipPosition? tooltipPosition;
  final EdgeInsets targetPadding;
  final BorderRadius targetBorderRadius;
}

/// Hedef widget'ı Showcase ile saran reusable yapı.
///
/// Yeni bir sayfada kullanım:
/// 1. Sayfada GlobalKey'leri oluştur.
/// 2. Vurgulanacak widget'ı AppTourTarget ile sar.
/// 3. AppTourController.startPageTourIfNeeded(...) içine key listesini ver.
class AppTourTarget extends StatelessWidget {
  const AppTourTarget({required this.step, required this.child, super.key});

  final AppTourStep step;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: step.key,
      scope: AppTourScope.defaultScope,
      title: step.title,
      description: step.description,
      tooltipPosition: step.tooltipPosition,
      targetPadding: step.targetPadding,
      targetBorderRadius: step.targetBorderRadius,
      tooltipBorderRadius: BorderRadius.circular(10),
      tooltipBackgroundColor: Colors.white,
      targetShapeBorder: RoundedRectangleBorder(
        borderRadius: step.targetBorderRadius,
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
      descTextStyle: const TextStyle(
        color: AppColors.mutedText,
        fontSize: 13,
        height: 1.4,
      ),
      tooltipPadding: const EdgeInsets.all(14),
      child: child,
    );
  }
}
