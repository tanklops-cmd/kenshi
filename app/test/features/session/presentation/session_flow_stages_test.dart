import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

import '../../../helpers/fake_session_repository.dart';

void main() {
  testWidgets('brand-new Session shows only Fresh Notes', (tester) async {
    await _pumpSession(tester, _session());

    final field = find.byKey(const ValueKey('freshNotesField'));
    expect(field, findsOneWidget);
    expect(tester.widget<TextField>(field).autofocus, isTrue);
    expect(find.text('Take another look'), findsNothing);
    expect(find.text('Next Focus'), findsNothing);
    expect(find.text('Guidance'), findsNothing);
    expect(find.text('Moments'), findsNothing);
  });

  testWidgets('Session with Fresh Notes offers review next', (tester) async {
    await _pumpSession(tester, _session(freshNotes: 'Immediate thoughts.'));

    expect(find.byKey(const ValueKey('freshNotesField')), findsNothing);
    expect(
      find.byKey(const ValueKey('freshNotesCompletedCard')),
      findsOneWidget,
    );
    expect(find.text('Immediate thoughts.'), findsOneWidget);
    expect(find.text('Take another look'), findsOneWidget);
    expect(find.text('Next Focus'), findsNothing);
  });

  testWidgets('Session with Review Notes offers Next Focus', (tester) async {
    await _pumpSession(
      tester,
      _session(
        freshNotes: 'Immediate thoughts.',
        reviewNotes: 'Later understanding.',
      ),
    );

    expect(find.text('Immediate thoughts.'), findsOneWidget);
    expect(find.text('Later understanding.'), findsOneWidget);
    expect(find.text('Next Focus'), findsOneWidget);
    expect(find.text('Guidance'), findsNothing);
    expect(find.text('Moments'), findsNothing);
  });

  testWidgets('Session with Next Focus shows the full summary', (tester) async {
    await _pumpSession(
      tester,
      _session(
        freshNotes: 'Immediate thoughts.',
        reviewNotes: 'Later understanding.',
        nextFocus: 'Win centre before attacking.',
      ),
    );

    expect(find.text("What's on your mind?"), findsOneWidget);
    expect(find.text('Take another look'), findsOneWidget);
    expect(find.text('Next Focus'), findsOneWidget);
    expect(find.text('Win centre before attacking.'), findsOneWidget);
    expect(find.text('Guidance'), findsOneWidget);
    final workspaceScroll = find
        .descendant(
          of: find.byKey(const ValueKey('sessionWorkspaceList')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Moments'),
      160,
      scrollable: workspaceScroll,
    );
    expect(find.text('Moments'), findsOneWidget);
    expect(find.text('Coming Soon'), findsNWidgets(2));
  });
}

Future<void> _pumpSession(WidgetTester tester, Session session) async {
  final repository = FakeSessionRepository();
  await repository.create(session);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sessionRepositoryProvider.overrideWithValue(repository)],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Reflect').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(session.title));
  await tester.pumpAndSettle();
}

Session _session({String? freshNotes, String? reviewNotes, String? nextFocus}) {
  return Session(
    id: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    trainingDate: DateTime(2026, 7, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Wednesday keiko',
    freshNotes: freshNotes,
    reviewNotes: reviewNotes,
    nextFocus: nextFocus,
    updatedAt: DateTime.utc(2026, 7, 1, 9),
  );
}
