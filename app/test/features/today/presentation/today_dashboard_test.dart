import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/guidance/application/guidance_providers.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/practice/application/practice_topic_providers.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

import '../../../helpers/fake_guidance_repository.dart';
import '../../../helpers/fake_moment_repository.dart';
import '../../../helpers/fake_practice_topic_repository.dart';
import '../../../helpers/fake_session_repository.dart';

void main() {
  testWidgets('shows all empty states when no data exists', (tester) async {
    await _pumpToday(tester);

    expect(find.byKey(const ValueKey('todayDashboard')), findsOneWidget);
    expect(
      find.text('Add a Next Focus to a session to see it here.'),
      findsOneWidget,
    );
    expect(
      find.text('Guidance from your sessions will appear here.'),
      findsOneWidget,
    );
    expect(
      find.text('Your most memorable training moment will appear here.'),
      findsOneWidget,
    );
    expect(
      find.text('Your last session review will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('shows quick action buttons', (tester) async {
    await _pumpToday(tester);

    expect(find.byKey(const ValueKey('quickNewSession')), findsOneWidget);
    expect(find.byKey(const ValueKey('quickPractice')), findsOneWidget);
    expect(find.byKey(const ValueKey('quickSearch')), findsOneWidget);
  });

  testWidgets('shows current focus items from sessions', (tester) async {
    final sessions = FakeSessionRepository();
    await sessions.create(
      _session(
        id: 's1',
        title: 'Monday Keiko',
        trainingDate: DateTime(2026, 7, 1),
        nextFocus: 'Win centre before attacking.',
      ),
    );
    await sessions.create(
      _session(
        id: 's2',
        title: 'Wednesday Keiko',
        trainingDate: DateTime(2026, 6, 29),
        nextFocus: 'Relax the right hand.',
      ),
    );

    await _pumpToday(tester, sessions: sessions);

    expect(find.text('Win centre before attacking.'), findsOneWidget);
    expect(find.text('Relax the right hand.'), findsOneWidget);
  });

  testWidgets('shows at most three focus items', (tester) async {
    final sessions = FakeSessionRepository();
    for (var i = 1; i <= 5; i++) {
      await sessions.create(
        _session(
          id: 's$i',
          title: 'Session $i',
          trainingDate: DateTime(2026, 7, i),
          nextFocus: 'Focus item $i',
        ),
      );
    }

    await _pumpToday(tester, sessions: sessions);

    // Only the 3 most recent sessions have their focus shown.
    expect(find.text('Focus item 5'), findsOneWidget);
    expect(find.text('Focus item 4'), findsOneWidget);
    expect(find.text('Focus item 3'), findsOneWidget);
    expect(find.text('Focus item 2'), findsNothing);
    expect(find.text('Focus item 1'), findsNothing);
  });

  testWidgets('checklist toggles focus item checked state', (tester) async {
    final sessions = FakeSessionRepository();
    await sessions.create(
      _session(
        id: 's1',
        title: 'Monday Keiko',
        trainingDate: DateTime(2026, 7, 1),
        nextFocus: 'Win centre.',
      ),
    );

    await _pumpToday(tester, sessions: sessions);

    final item = find.byKey(const ValueKey('focusItem_0'));
    expect(item, findsOneWidget);

    // Initial state — unchecked icon.
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    await tester.tap(item);
    await tester.pumpAndSettle();

    // After tap — checked icon.
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);

    // Tap again — unchecked.
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
  });

  testWidgets('shows recent guidance cards', (tester) async {
    final guidance = FakeGuidanceRepository();
    await guidance.create(
      _guidance(id: 'g1', sessionId: 's1', advice: 'Keep the left hand low.'),
    );
    await guidance.create(
      _guidance(
        id: 'g2',
        sessionId: 's1',
        advice: 'Win centre before striking.',
        coachName: 'Sensei',
      ),
    );

    await _pumpToday(tester, guidance: guidance);

    expect(find.text('Keep the left hand low.'), findsOneWidget);
    expect(find.text('Win centre before striking.'), findsOneWidget);
    expect(find.text('Sensei'), findsOneWidget);
  });

  testWidgets('tapping guidance card opens its session', (tester) async {
    final sessions = FakeSessionRepository();
    await sessions.create(
      _session(
        id: 'session-abc',
        title: 'Source Session',
        trainingDate: DateTime(2026, 7, 1),
      ),
    );
    final guidance = FakeGuidanceRepository();
    await guidance.create(
      _guidance(
        id: 'g1',
        sessionId: 'session-abc',
        advice: 'Strike with kiai.',
      ),
    );

    await _pumpToday(tester, sessions: sessions, guidance: guidance);

    await tester.tap(find.byKey(const ValueKey('guidanceCard_g1')));
    await tester.pumpAndSettle();

    expect(find.text('Source Session'), findsOneWidget);
  });

  testWidgets('shows most recent moment', (tester) async {
    final moments = FakeMomentRepository();
    await moments.create(
      _moment(
        id: 'm1',
        sessionId: 's1',
        title: 'Committed men strike',
        createdAt: DateTime.utc(2026, 6, 28),
      ),
    );
    await moments.create(
      _moment(
        id: 'm2',
        sessionId: 's1',
        title: 'Good zanshin',
        createdAt: DateTime.utc(2026, 7, 1),
      ),
    );

    await _pumpToday(tester, moments: moments);

    // Only the most recent moment is shown.
    expect(find.text('Good zanshin'), findsOneWidget);
    expect(find.text('Committed men strike'), findsNothing);
  });

  testWidgets('tapping moment card opens the moment', (tester) async {
    final sessions = FakeSessionRepository();
    await sessions.create(
      _session(
        id: 'session-xyz',
        title: 'Session For Moment',
        trainingDate: DateTime(2026, 7, 1),
      ),
    );
    final moments = FakeMomentRepository();
    await moments.create(
      _moment(
        id: 'moment-abc',
        sessionId: 'session-xyz',
        title: 'Perfect debana-men',
        createdAt: DateTime.utc(2026, 7, 1),
      ),
    );

    await _pumpToday(tester, sessions: sessions, moments: moments);

    await tester.tap(find.byKey(const ValueKey('recentMomentCard')));
    await tester.pumpAndSettle();

    expect(find.text('Moment'), findsOneWidget);
  });

  testWidgets('shows last review session', (tester) async {
    final sessions = FakeSessionRepository();
    await sessions.create(
      _session(
        id: 'reviewed',
        title: 'Wednesday Evening',
        trainingDate: DateTime(2026, 7, 1),
        reviewNotes: 'Stayed focused throughout.',
      ),
    );

    await _pumpToday(tester, sessions: sessions);

    expect(find.text('Wednesday Evening'), findsOneWidget);
    expect(find.text('Stayed focused throughout.'), findsOneWidget);
  });

  testWidgets('prefers review notes over fresh notes in last review',
      (tester) async {
    final sessions = FakeSessionRepository();
    await sessions.create(
      _session(
        id: 'reviewed',
        title: 'Monday Keiko',
        trainingDate: DateTime(2026, 7, 1),
        freshNotes: 'Immediate thoughts.',
        reviewNotes: 'Deeper reflection.',
      ),
    );

    await _pumpToday(tester, sessions: sessions);

    expect(find.text('Deeper reflection.'), findsOneWidget);
    expect(find.text('Immediate thoughts.'), findsNothing);
  });

  testWidgets('tapping last review card opens the session', (tester) async {
    final sessions = FakeSessionRepository();
    await sessions.create(
      _session(
        id: 'review-session',
        title: 'Review Target',
        trainingDate: DateTime(2026, 7, 1),
        freshNotes: 'Some notes.',
      ),
    );

    await _pumpToday(tester, sessions: sessions);

    await tester.tap(find.byKey(const ValueKey('lastReviewCard')));
    await tester.pumpAndSettle();

    expect(find.text('Review Target'), findsOneWidget);
    expect(find.text('Session'), findsOneWidget);
  });

  testWidgets('quick action New Session navigates to new session form',
      (tester) async {
    await _pumpToday(tester);

    await tester.tap(find.byKey(const ValueKey('quickNewSession')));
    await tester.pumpAndSettle();

    expect(find.text('New Session'), findsOneWidget);
    expect(find.byKey(const ValueKey('saveSessionButton')), findsOneWidget);
  });

  testWidgets('quick action Search navigates to search screen', (tester) async {
    await _pumpToday(tester);

    await tester.tap(find.byKey(const ValueKey('quickSearch')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('searchField')), findsOneWidget);
  });
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Future<void> _pumpToday(
  WidgetTester tester, {
  FakeSessionRepository? sessions,
  FakeGuidanceRepository? guidance,
  FakeMomentRepository? moments,
}) async {
  sessions ??= FakeSessionRepository();
  guidance ??= FakeGuidanceRepository();
  moments ??= FakeMomentRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(sessions),
        guidanceRepositoryProvider.overrideWithValue(guidance),
        momentRepositoryProvider.overrideWithValue(moments),
        practiceTopicRepositoryProvider.overrideWithValue(
          FakePracticeTopicRepository(),
        ),
      ],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
  // Start on Today tab (index 0, default).
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

GuidanceEntry _guidance({
  required String id,
  required String sessionId,
  required String advice,
  String? coachName,
}) {
  final now = DateTime.utc(2026, 7, 1, 10);
  return GuidanceEntry(
    id: id,
    sessionId: sessionId,
    createdAt: now,
    updatedAt: now,
    advice: advice,
    coachName: coachName,
    archived: false,
  );
}

Moment _moment({
  required String id,
  required String sessionId,
  required String title,
  required DateTime createdAt,
}) {
  return Moment(
    id: id,
    sessionId: sessionId,
    createdAt: createdAt,
    type: MomentType.photo,
    localPath: '/fake/path/$id.jpg',
    title: title,
    note: '',
    archived: false,
  );
}
