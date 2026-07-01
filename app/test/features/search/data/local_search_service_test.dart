import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/features/learn/data/seeded_learn_repository.dart';
import 'package:kendo_companion/src/features/moment/data/sqlite_moment_repository.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/practice/data/sqlite_practice_topic_repository.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';
import 'package:kendo_companion/src/features/search/data/local_search_service.dart';
import 'package:kendo_companion/src/features/search/domain/search_result.dart';
import 'package:kendo_companion/src/features/session/data/sqlite_session_repository.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_database.dart';

void main() {
  late Database database;
  late LocalSearchService service;
  late SqliteMomentRepository moments;

  setUp(() async {
    database = await openTestDatabase();
    await SqliteSessionRepository(database).create(_session());
    await SqlitePracticeTopicRepository(database).create(_practiceTopic());
    moments = SqliteMomentRepository(database);
    await moments.create(_moment());
    service = LocalSearchService(database, const SeededLearnRepository());
  });

  tearDown(() => database.close());

  test('requires two characters and treats LIKE wildcards literally', () async {
    expect(await service.search(''), isEmpty);
    expect(await service.search('m'), isEmpty);
    expect(await service.search('%_'), isEmpty);
  });

  test(
    'finds Sessions across title, location, type, and review fields',
    () async {
      for (final query in [
        'evening',
        'central dojo',
        'CLUB KEIKO',
        'timing felt',
        'create the opportunity',
        'win centre',
      ]) {
        final results = await service.search(query);
        expect(
          results.where((result) => result.type == SearchResultType.session),
          hasLength(1),
          reason: query,
        );
      }
    },
  );

  test('finds Practice Topics across name, current state, and cues', () async {
    for (final query in ['seme', 'disrupt posture', 'relax the right']) {
      final results = await service.search(query);
      expect(
        results.where((result) => result.type == SearchResultType.practice),
        hasLength(1),
        reason: query,
      );
    }
  });

  test('finds Learn Topics across title, summary, and body', () async {
    for (final query in ['debana', 'pressure used', 'opponent’s movement']) {
      final results = await service.search(query);
      expect(
        results.where((result) => result.type == SearchResultType.learn),
        isNotEmpty,
        reason: query,
      );
    }
  });

  test(
    'finds active Moments by title and note but excludes archived records',
    () async {
      for (final query in ['committed men', 'finished forward']) {
        final results = await service.search(query);
        expect(
          results.where((result) => result.type == SearchResultType.moment),
          hasLength(1),
          reason: query,
        );
      }

      await moments.archive('moment-1');
      expect(await service.search('committed men'), isEmpty);
    },
  );
}

Session _session() {
  return Session(
    id: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    trainingDate: DateTime(2026, 7, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Evening training',
    location: 'Central Dojo',
    freshNotes: 'My timing felt late.',
    reviewNotes: 'I need to create the opportunity.',
    nextFocus: 'Win centre before attacking.',
    updatedAt: DateTime.utc(2026, 7, 1, 10),
  );
}

PracticeTopic _practiceTopic() {
  return PracticeTopic(
    id: 'topic-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    updatedAt: DateTime.utc(2026, 7, 1, 10),
    category: PracticeTopicCategory.fundamentals,
    name: 'Seme',
    currentState: 'Use pressure to disrupt posture.',
    mentalCues: 'Relax the right hand.',
    archived: false,
  );
}

Moment _moment() {
  return Moment(
    id: 'moment-1',
    sessionId: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 11),
    type: MomentType.photo,
    localPath: r'C:\media\men.jpg',
    title: 'Committed men',
    note: 'I finished forward without hesitation.',
    archived: false,
  );
}
