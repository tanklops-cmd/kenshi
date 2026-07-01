import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/practice/application/practice_topic_providers.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

import '../../../helpers/fake_practice_topic_repository.dart';
import '../../../helpers/fake_session_repository.dart';

void main() {
  testWidgets('shows current focus and the latest session summary', (
    tester,
  ) async {
    final repository = FakeSessionRepository();
    await repository.create(
      _session(
        id: 'older',
        title: 'Monday Keiko',
        trainingDate: DateTime(2026, 6, 29),
        nextFocus: 'Win centre before attacking.',
        reviewNotes: 'Review should take priority.\nSecond line.\nThird line.',
        freshNotes: 'Fresh notes should not be shown.',
      ),
    );
    await repository.create(
      _session(
        id: 'latest',
        title: 'Wednesday Keiko',
        trainingDate: DateTime(2026, 7, 1),
        freshNotes: 'Stayed relaxed and finished forward.',
      ),
    );

    await _pumpPrepare(tester, repository);

    expect(find.text('Win centre before attacking.'), findsOneWidget);
    expect(find.text('Wednesday Keiko'), findsOneWidget);
    expect(find.text('Stayed relaxed and finished forward.'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);
  });

  testWidgets('opens the Session that supplied the current focus', (
    tester,
  ) async {
    final repository = FakeSessionRepository();
    await repository.create(
      _session(
        id: 'focus-session',
        title: 'Focus Source',
        trainingDate: DateTime(2026, 6, 30),
        nextFocus: 'Relax the right hand.',
      ),
    );

    await _pumpPrepare(tester, repository);
    await tester.tap(find.byKey(const ValueKey('openFocusSessionButton')));
    await tester.pumpAndSettle();

    expect(find.text('Focus Source'), findsOneWidget);
    expect(find.text('Training Date'), findsOneWidget);
  });

  testWidgets('prefers Review Notes in the last Session summary', (
    tester,
  ) async {
    final repository = FakeSessionRepository();
    await repository.create(
      _session(
        id: 'reviewed',
        title: 'Reviewed Session',
        trainingDate: DateTime(2026, 7, 1),
        reviewNotes: 'Later understanding.',
        freshNotes: 'Immediate thoughts.',
      ),
    );

    await _pumpPrepare(tester, repository);

    expect(find.text('Later understanding.'), findsOneWidget);
    expect(find.text('Immediate thoughts.'), findsNothing);
  });

  testWidgets('opens the latest Session from its summary card', (tester) async {
    final repository = FakeSessionRepository();
    await repository.create(
      _session(
        id: 'latest',
        title: 'Latest Session',
        trainingDate: DateTime(2026, 7, 1),
      ),
    );

    await _pumpPrepare(tester, repository);
    await tester.tap(find.byKey(const ValueKey('lastSessionCard')));
    await tester.pumpAndSettle();

    expect(find.text('Latest Session'), findsOneWidget);
    expect(find.text('Training Date'), findsOneWidget);
  });

  testWidgets('shows quiet empty states when there are no Sessions', (
    tester,
  ) async {
    await _pumpPrepare(tester, FakeSessionRepository());

    expect(find.text('No current focus.'), findsOneWidget);
    expect(find.text('No previous session.'), findsOneWidget);
    expect(find.text('No review available.'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('openFocusSessionButton')),
    );
    expect(button.onPressed, isNull);
  });
}

Future<void> _pumpPrepare(
  WidgetTester tester,
  FakeSessionRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        practiceTopicRepositoryProvider.overrideWithValue(
          FakePracticeTopicRepository(),
        ),
        sessionRepositoryProvider.overrideWithValue(repository),
      ],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Prepare').last);
  await tester.pumpAndSettle();
}

Session _session({
  required String id,
  required String title,
  required DateTime trainingDate,
  String? freshNotes,
  String? reviewNotes,
  String? nextFocus,
}) {
  final createdAt = DateTime.utc(2026, 7, 1, 8);
  return Session(
    id: id,
    createdAt: createdAt,
    trainingDate: trainingDate,
    sessionType: SessionType.clubKeiko,
    title: title,
    freshNotes: freshNotes,
    reviewNotes: reviewNotes,
    nextFocus: nextFocus,
    updatedAt: createdAt,
  );
}
