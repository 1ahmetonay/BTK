import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kobi_ai_asistan/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_tour.completed.dashboard_v2': true,
    });
  });

  Future<void> pumpMobileApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ProviderScope(child: KobiAIAsistanApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard renders on app launch', (WidgetTester tester) async {
    await pumpMobileApp(tester);

    expect(find.text('Ana Sayfa'), findsWidgets);
    expect(find.text('AI Sabah Brifingi'), findsOneWidget);
  });

  testWidgets('mobile bottom navigation exposes primary routes', (
    WidgetTester tester,
  ) async {
    await pumpMobileApp(tester);

    expect(find.text('Ana Sayfa'), findsWidgets);
    expect(find.text('Belgeler'), findsOneWidget);
    expect(find.text('Stok'), findsOneWidget);
    expect(find.text('Finans'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.byTooltip('Bildirimler'), findsOneWidget);
    expect(find.byTooltip('Ayarlar'), findsOneWidget);
  });

  testWidgets('bottom navigation opens selected feature page', (
    WidgetTester tester,
  ) async {
    await pumpMobileApp(tester);

    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    expect(find.text('Stok Yönetimi'), findsWidgets);
  });
}
