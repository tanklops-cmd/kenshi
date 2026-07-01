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
  testWidgets('adds, edits, and archives Guidance with autosave', (
    tester,
  ) async {
    final guidance = FakeGuidanceRepository();
    await _pumpSession(tester, guidance);

    expect(find.text('No Guidance yet.'), findsOneWidget);
    expect(find.text('Take another look'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('addGuidanceButton')));
    await tester.pumpAndSettle();

    expect(find.text('Add Guidance'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('guidanceCoachField')),
      'Sensei',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(await guidance.readForSession('session-1'), isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey('guidanceAdviceField')),
      'Keep the left hand centred.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('guidanceContextField')),
      'After kirikaeshi.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    var stored = (await guidance.readForSession('session-1')).single;
    expect(stored.coachName, 'Sensei');
    expect(stored.advice, 'Keep the left hand centred.');
    expect(stored.context, 'After kirikaeshi.');
    expect(find.textContaining('Created'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Keep the left hand centred.'), findsOneWidget);
    await tester.tap(find.text('Keep the left hand centred.'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('guidanceAdviceField')),
      'Keep the left hand centred through the strike.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    stored = (await guidance.readForSession('session-1')).single;
    expect(stored.advice, 'Keep the left hand centred through the strike.');

    final detailScroll = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('archiveGuidanceButton')),
      160,
      scrollable: detailScroll,
    );
    await tester.tap(find.byKey(const ValueKey('archiveGuidanceButton')));
    await tester.pumpAndSettle();

    expect(await guidance.readForSession('session-1'), isEmpty);
    expect(find.text('No Guidance yet.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}

Future<void> _pumpSession(
  WidgetTester tester,
  FakeGuidanceRepository guidance,
) async {
  final sessions = FakeSessionRepository();
  await sessions.create(
    Session(
      id: 'session-1',
      createdAt: DateTime.utc(2026, 7, 1, 9),
      trainingDate: DateTime(2026, 7, 1),
      sessionType: SessionType.clubKeiko,
      title: 'Wednesday keiko',
      freshNotes: 'Immediate thoughts.',
      reviewNotes: 'Later understanding.',
      updatedAt: DateTime.utc(2026, 7, 1, 9),
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(sessions),
        guidanceRepositoryProvider.overrideWithValue(guidance),
        momentRepositoryProvider.overrideWithValue(FakeMomentRepository()),
      ],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Reflect').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Wednesday keiko'));
  await tester.pumpAndSettle();
  final workspaceScroll = find
      .descendant(
        of: find.byKey(const ValueKey('sessionWorkspaceList')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('addGuidanceButton')),
    160,
    scrollable: workspaceScroll,
  );
  await tester.drag(workspaceScroll, const Offset(0, -80));
  await tester.pumpAndSettle();
}
