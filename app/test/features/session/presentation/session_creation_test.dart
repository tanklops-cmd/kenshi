import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';

import '../../../helpers/fake_session_repository.dart';

void main() {
  testWidgets('creates a session from Reflect', (tester) async {
    final repository = FakeSessionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionRepositoryProvider.overrideWithValue(repository)],
        child: const KendoCompanionApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reflect').last);
    await tester.pumpAndSettle();
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Reflect'), findsOneWidget);
    expect(find.text('No sessions yet.'), findsOneWidget);

    await tester.tap(find.text('New Session'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('saveSessionButton')));
    await tester.pump();
    expect(find.text('Training date is required.'), findsOneWidget);
    expect(find.text('Session type is required.'), findsOneWidget);
    expect(find.text('Title is required.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('trainingDateField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sessionTypeField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Club Keiko').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('sessionTitleField')),
      'Evening keiko',
    );
    await tester.enterText(
      find.byKey(const ValueKey('sessionLocationField')),
      'Central Dojo',
    );
    await tester.tap(find.byKey(const ValueKey('saveSessionButton')));
    await tester.pumpAndSettle();

    expect(find.text('Session'), findsOneWidget);
    expect(find.text('Evening keiko'), findsOneWidget);
    expect(find.text('Club Keiko'), findsOneWidget);
    expect(find.text('Central Dojo'), findsOneWidget);
    expect(find.text("What's on your mind?"), findsOneWidget);
    for (final section in [
      'Take another look',
      'Next Focus',
      'Guidance',
      'Moments',
    ]) {
      expect(find.text(section), findsNothing);
    }

    final sessions = await repository.readAll();
    expect(sessions, hasLength(1));
    expect(sessions.single.title, 'Evening keiko');
    expect(sessions.single.location, 'Central Dojo');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Evening keiko'), findsOneWidget);
    expect(find.text('Club Keiko · Central Dojo'), findsOneWidget);
  });
}
