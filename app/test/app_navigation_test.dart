import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';

import 'helpers/fake_session_repository.dart';

void main() {
  testWidgets('navigates between all primary destinations', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Today'), findsWidgets);

    for (final destination in ['Reflect', 'Practice', 'Learn', 'Prepare']) {
      await tester.tap(find.text(destination).last);
      await tester.pumpAndSettle();

      expect(find.text(destination), findsWidgets);
    }
  });

  testWidgets('uses Material 3', (tester) async {
    await _pumpApp(tester);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(materialApp.darkTheme?.useMaterial3, isTrue);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
      ],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
}
