import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/features/learn/data/seeded_learn_repository.dart';
import 'package:kendo_companion/src/features/learn/domain/learn_topic.dart';

void main() {
  const repository = SeededLearnRepository();

  test('provides all Learn categories', () {
    expect(repository.categories, LearnCategory.values);
  });

  test('provides the six initial seed topics', () {
    final topics = LearnCategory.values
        .expand(repository.topicsForCategory)
        .toList(growable: false);

    expect(topics, hasLength(6));
    expect(topics.map((topic) => topic.title).toSet(), {
      'Debana-men',
      'Seme',
      'Maai',
      'Kirikaeshi',
      'Nihon Kendo Kata',
      'Shinai care',
    });
  });

  test('filters by category and reads topics by id', () {
    final fundamentals = repository.topicsForCategory(
      LearnCategory.fundamentals,
    );

    expect(fundamentals.map((topic) => topic.title), ['Seme', 'Maai']);
    expect(
      repository.topicById('debana-men')?.category,
      LearnCategory.techniques,
    );
    expect(repository.topicById('missing'), isNull);
  });
}
