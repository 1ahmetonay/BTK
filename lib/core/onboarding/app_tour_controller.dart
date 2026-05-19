import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import 'app_tour_scope.dart';
import 'app_tour_service.dart';

final appTourServiceProvider = Provider<AppTourService>((ref) {
  return AppTourService();
});

final appTourControllerProvider = Provider<AppTourController>((ref) {
  return AppTourController(ref.watch(appTourServiceProvider));
});

/// Showcase başlatma ve "ilk kez göster" kontrolünü tek yerde toplar.
class AppTourController {
  AppTourController(this._service);

  final AppTourService _service;

  Future<void> startPageTourIfNeeded({
    required BuildContext context,
    required String tourId,
    required List<GlobalKey> targets,
    Duration delay = const Duration(milliseconds: 450),
    String scope = AppTourScope.defaultScope,
  }) async {
    return _startPageTour(
      context: context,
      tourId: tourId,
      targets: targets,
      delay: delay,
      scope: scope,
      respectCompletedState: true,
    );
  }

  Future<void> startPageTour({
    required BuildContext context,
    required String tourId,
    required List<GlobalKey> targets,
    Duration delay = const Duration(milliseconds: 150),
    String scope = AppTourScope.defaultScope,
  }) async {
    await _service.reset(tourId);
    if (!context.mounted) return;
    return _startPageTour(
      context: context,
      tourId: tourId,
      targets: targets,
      delay: delay,
      scope: scope,
      respectCompletedState: false,
    );
  }

  Future<void> _startPageTour({
    required BuildContext context,
    required String tourId,
    required List<GlobalKey> targets,
    required Duration delay,
    required String scope,
    required bool respectCompletedState,
  }) async {
    if (targets.isEmpty ||
        (respectCompletedState && await _service.isCompleted(tourId))) {
      return;
    }

    await Future<void>.delayed(delay);
    if (!context.mounted) return;

    final visibleTargets = targets
        .where((key) => key.currentContext != null)
        .toList(growable: false);

    if (visibleTargets.isEmpty) {
      return;
    }

    final showcaseView = ShowcaseView.getNamed(scope);
    if (showcaseView.isShowcaseRunning) {
      return;
    }

    var callbackRemoved = false;
    late final VoidCallback onFinish;
    late final OnDismissCallback onDismiss;

    Future<void> completeTour() async {
      if (callbackRemoved) return;
      callbackRemoved = true;
      showcaseView
        ..removeOnFinishCallback(onFinish)
        ..removeOnDismissCallback(onDismiss);
      await _service.markCompleted(tourId);
    }

    onFinish = () => unawaited(completeTour());
    onDismiss = (_) => unawaited(completeTour());

    showcaseView
      ..addOnFinishCallback(onFinish)
      ..addOnDismissCallback(onDismiss)
      ..startShowCase(visibleTargets);
  }

  Future<void> resetTour(String tourId) => _service.reset(tourId);
}
