import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/guidance/application/guidance_providers.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

import '../../../helpers/fake_guidance_repository.dart';
import '../../../helpers/fake_moment_repository.dart';
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
    await _scrollTo(tester, find.text('Guidance'));
    expect(find.text('Guidance'), findsOneWidget);
    expect(find.text('Add Guidance'), findsOneWidget);
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
    await _scrollTo(tester, find.text('Next Focus'));
    expect(find.text('Guidance'), findsOneWidget);
    expect(find.text('Next Focus'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Guidance')).dy,
      lessThan(tester.getTopLeft(find.text('Next Focus')).dy),
    );
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
    await _scrollTo(tester, find.text('Next Focus'));
    expect(find.text('Next Focus'), findsOneWidget);
    expect(find.text('Win centre before attacking.'), findsOneWidget);
    expect(find.text('Guidance'), findsOneWidget);
    await _scrollTo(tester, find.text('Moments'));
    expect(find.text('Moments'), findsOneWidget);
    expect(find.text('No Moments yet.'), findsOneWidget);
    expect(find.text('Add Moment'), findsOneWidget);
  });
}

Future<void> _pumpSession(WidgetTester tester, Session session) async {
  final repository = FakeSessionRepository();
  await repository.create(session);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(repository),
        guidanceRepositoryProvider.overrideWithValue(FakeGuidanceRepository()),
        momentRepositoryProvider.overrideWithValue(FakeMomentRepository()),
      ],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Reflect').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(session.title));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  final workspaceScroll = find
      .descendant(
        of: find.byKey(const ValueKey('sessionWorkspaceList')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(target, 160, scrollable: workspaceScroll);
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
