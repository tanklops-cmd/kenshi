import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/practice/application/practice_topic_providers.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';
import 'package:kendo_companion/src/features/search/application/search_providers.dart';
import 'package:kendo_companion/src/features/search/domain/search_result.dart';
import 'package:kendo_companion/src/features/search/domain/search_service.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

import '../../../helpers/fake_moment_repository.dart';
import '../../../helpers/fake_practice_topic_repository.dart';
import '../../../helpers/fake_session_repository.dart';

void main() {
  testWidgets('opens Search from Today, Practice, and Learn', (tester) async {
    final harness = await _pumpApp(tester);

    for (final destination in ['Today', 'Practice', 'Learn']) {
      if (destination != 'Today') {
        await tester.tap(find.text(destination).last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('openSearchButton')));
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(harness.service.calls, isEmpty);
  });

  testWidgets('debounces input and groups universal results', (tester) async {
    final harness = await _pumpApp(tester);
    await _openSearch(tester);

    await tester.enterText(find.byKey(const ValueKey('searchField')), 'a');
    await tester.pump(const Duration(milliseconds: 400));
    expect(harness.service.calls, isEmpty);
    expect(find.byKey(const ValueKey('searchResultsList')), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('searchField')), 'centre');
    await tester.pump(const Duration(milliseconds: 299));
    expect(harness.service.calls, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(harness.service.calls, ['centre']);
    final resultsScroll = _searchResultsScrollable();
    for (final group in ['Sessions', 'Practice', 'Learn', 'Moments']) {
      await tester.scrollUntilVisible(
        find.text(group),
        120,
        scrollable: resultsScroll,
      );
      expect(find.text(group), findsOneWidget);
    }
  });

  for (final target in const [
    ('Evening training', 'Training Date'),
    ('Seme', 'Current State'),
    ('Debana-men', 'A men strike made as the opponent begins to act.'),
    ('Committed men', 'What does this Moment show?'),
  ]) {
    testWidgets('opens ${target.$1} from its search result', (tester) async {
      await _pumpApp(tester);
      await _openSearch(tester);
      await tester.enterText(
        find.byKey(const ValueKey('searchField')),
        'centre',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(target.$1),
        160,
        scrollable: _searchResultsScrollable(),
      );
      if (tester.getCenter(find.text(target.$1)).dy > 560) {
        await tester.drag(_searchResultsScrollable(), const Offset(0, -80));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(target.$1));
      await tester.pumpAndSettle();

      expect(find.text(target.$2), findsOneWidget);
    });
  }
}

Future<_Harness> _pumpApp(WidgetTester tester) async {
  final sessions = FakeSessionRepository();
  final practice = FakePracticeTopicRepository();
  final moments = FakeMomentRepository();
  final service = _FakeSearchService(_results);
  await sessions.create(_session());
  await practice.create(_practiceTopic());
  await moments.create(_moment());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(sessions),
        practiceTopicRepositoryProvider.overrideWithValue(practice),
        momentRepositoryProvider.overrideWithValue(moments),
        searchServiceProvider.overrideWithValue(service),
      ],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(service);
}

Future<void> _openSearch(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('openSearchButton')));
  await tester.pumpAndSettle();
}

Finder _searchResultsScrollable() {
  return find
      .descendant(
        of: find.byKey(const ValueKey('searchResultsList')),
        matching: find.byType(Scrollable),
      )
      .first;
}

const _results = [
  SearchResult(
    id: 'session-1',
    type: SearchResultType.session,
    title: 'Evening training',
    preview: 'Win centre before attacking.',
  ),
  SearchResult(
    id: 'topic-1',
    type: SearchResultType.practice,
    title: 'Seme',
    preview: 'Win centre first.',
  ),
  SearchResult(
    id: 'debana-men',
    type: SearchResultType.learn,
    title: 'Debana-men',
    preview: 'Strike as the opponent begins to act.',
  ),
  SearchResult(
    id: 'moment-1',
    parentId: 'session-1',
    type: SearchResultType.moment,
    title: 'Committed men',
    preview: 'Finished forward.',
  ),
];

Session _session() {
  return Session(
    id: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    trainingDate: DateTime(2026, 7, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Evening training',
    updatedAt: DateTime.utc(2026, 7, 1, 9),
  );
}

PracticeTopic _practiceTopic() {
  return PracticeTopic(
    id: 'topic-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    updatedAt: DateTime.utc(2026, 7, 1, 9),
    category: PracticeTopicCategory.fundamentals,
    name: 'Seme',
    currentState: '',
    mentalCues: '',
    archived: false,
  );
}

Moment _moment() {
  return Moment(
    id: 'moment-1',
    sessionId: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 10),
    type: MomentType.photo,
    localPath: r'C:\media\men.jpg',
    title: 'Committed men',
    note: '',
    archived: false,
  );
}

class _FakeSearchService implements SearchService {
  _FakeSearchService(this.results);

  final List<SearchResult> results;
  final List<String> calls = [];

  @override
  Future<List<SearchResult>> search(String query) async {
    calls.add(query);
    return results;
  }
}

class _Harness {
  const _Harness(this.service);

  final _FakeSearchService service;
}
