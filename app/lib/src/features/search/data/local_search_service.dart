import 'package:kendo_companion/src/features/learn/domain/learn_repository.dart';
import 'package:kendo_companion/src/features/search/domain/search_result.dart';
import 'package:kendo_companion/src/features/search/domain/search_service.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:sqflite/sqflite.dart';

class LocalSearchService implements SearchService {
  const LocalSearchService(this._database, this._learnRepository);

  final Database _database;
  final LearnRepository _learnRepository;

  @override
  Future<List<SearchResult>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.length < 2) {
      return const [];
    }

    final pattern = '%${_escapeLike(normalized)}%';
    return [
      ...await _searchSessions(normalized, pattern),
      ...await _searchPractice(normalized, pattern),
      ..._searchLearn(normalized),
      ...await _searchMoments(normalized, pattern),
    ];
  }

  Future<List<SearchResult>> _searchSessions(
    String query,
    String pattern,
  ) async {
    final matchingTypes = SessionType.values
        .where((type) => type.label.toLowerCase().contains(query))
        .map((type) => type.name)
        .toList(growable: false);
    final typeClause = matchingTypes.isEmpty
        ? ''
        : ' OR session_type IN (${List.filled(matchingTypes.length, '?').join(', ')})';
    final rows = await _database.rawQuery(
      '''
      SELECT id, title, location, session_type, fresh_notes, review_notes,
             next_focus, training_date
      FROM sessions
      WHERE lower(title) LIKE ? ESCAPE '!'
         OR lower(COALESCE(location, '')) LIKE ? ESCAPE '!'
         OR lower(COALESCE(fresh_notes, '')) LIKE ? ESCAPE '!'
         OR lower(COALESCE(review_notes, '')) LIKE ? ESCAPE '!'
         OR lower(COALESCE(next_focus, '')) LIKE ? ESCAPE '!'
         $typeClause
      ORDER BY training_date DESC, created_at DESC
      LIMIT 50
    ''',
      [pattern, pattern, pattern, pattern, pattern, ...matchingTypes],
    );

    return rows
        .map((row) {
          final sessionType = SessionType.values.byName(
            row['session_type']! as String,
          );
          return SearchResult(
            id: row['id']! as String,
            type: SearchResultType.session,
            title: row['title']! as String,
            preview: _matchingPreview(
              [
                row['location'] as String?,
                row['fresh_notes'] as String?,
                row['review_notes'] as String?,
                row['next_focus'] as String?,
                sessionType.label,
              ],
              query,
              sessionType.label,
            ),
            date: DateTime.parse(row['training_date']! as String),
            detailLabel: sessionType.label,
          );
        })
        .toList(growable: false);
  }

  Future<List<SearchResult>> _searchPractice(
    String query,
    String pattern,
  ) async {
    final rows = await _database.rawQuery(
      '''
      SELECT id, name, category, current_state, mental_cues
      FROM practice_topics
      WHERE archived = 0
        AND (
          lower(name) LIKE ? ESCAPE '!'
          OR lower(current_state) LIKE ? ESCAPE '!'
          OR lower(mental_cues) LIKE ? ESCAPE '!'
        )
      ORDER BY updated_at DESC, name COLLATE NOCASE ASC
      LIMIT 50
    ''',
      [pattern, pattern, pattern],
    );

    return rows
        .map(
          (row) => SearchResult(
            id: row['id']! as String,
            type: SearchResultType.practice,
            title: row['name']! as String,
            preview: _matchingPreview(
              [row['current_state']! as String, row['mental_cues']! as String],
              query,
              'No personal notes yet.',
            ),
          ),
        )
        .toList(growable: false);
  }

  List<SearchResult> _searchLearn(String query) {
    final results = <SearchResult>[];
    for (final category in _learnRepository.categories) {
      for (final topic in _learnRepository.topicsForCategory(category)) {
        if ([
          topic.title,
          topic.summary,
          topic.body,
        ].any((value) => value.toLowerCase().contains(query))) {
          results.add(
            SearchResult(
              id: topic.id,
              type: SearchResultType.learn,
              title: topic.title,
              preview: _matchingPreview(
                [topic.summary, topic.body],
                query,
                topic.summary,
              ),
              detailLabel: category.label,
            ),
          );
        }
      }
    }
    return results;
  }

  Future<List<SearchResult>> _searchMoments(
    String query,
    String pattern,
  ) async {
    final rows = await _database.rawQuery(
      '''
      SELECT id, session_id, title, note, type, created_at
      FROM moments
      WHERE archived = 0
        AND (
          lower(title) LIKE ? ESCAPE '!'
          OR lower(note) LIKE ? ESCAPE '!'
        )
      ORDER BY created_at DESC
      LIMIT 50
    ''',
      [pattern, pattern],
    );

    return rows
        .map((row) {
          final mediaType = row['type']! as String;
          final title = (row['title']! as String).trim();
          return SearchResult(
            id: row['id']! as String,
            parentId: row['session_id']! as String,
            type: SearchResultType.moment,
            title: title.isEmpty ? '${_capitalise(mediaType)} Moment' : title,
            preview: _matchingPreview(
              [row['note']! as String],
              query,
              '${_capitalise(mediaType)} Moment',
            ),
            date: DateTime.fromMillisecondsSinceEpoch(
              row['created_at']! as int,
              isUtc: true,
            ),
            detailLabel: '${_capitalise(mediaType)} Moment',
          );
        })
        .toList(growable: false);
  }

  String _matchingPreview(List<String?> values, String query, String fallback) {
    final match = values.whereType<String>().cast<String?>().firstWhere(
      (value) => value!.toLowerCase().contains(query),
      orElse: () => null,
    );
    final text = (match ?? fallback).replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.length <= 160 ? text : '${text.substring(0, 157)}…';
  }

  String _escapeLike(String value) {
    return value
        .replaceAll('!', '!!')
        .replaceAll('%', '!%')
        .replaceAll('_', '!_');
  }

  String _capitalise(String value) {
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
