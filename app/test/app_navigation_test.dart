import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';

void main() {
  testWidgets('navigates between all primary destinations', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KendoCompanionApp()));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);

    for (final destination in ['Reflect', 'Practice', 'Learn', 'Prepare']) {
      await tester.tap(find.text(destination).last);
      await tester.pumpAndSettle();

      expect(find.text(destination), findsWidgets);
    }
  });

  testWidgets('uses Material 3', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KendoCompanionApp()));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(materialApp.darkTheme?.useMaterial3, isTrue);
  });
}
