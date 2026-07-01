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
    final shikakeWaza = repository.topicsForCategory(
      LearnCategory.shikakeWaza,
    );
    final semeTopics = repository.topicsForCategory(LearnCategory.seme);
    final maaiTopics = repository.topicsForCategory(LearnCategory.maai);

    expect(shikakeWaza.map((topic) => topic.title), ['Debana-men']);
    expect(semeTopics.map((topic) => topic.title), ['Seme']);
    expect(maaiTopics.map((topic) => topic.title), ['Maai']);
    expect(
      repository.topicById('debana-men')?.category,
      LearnCategory.shikakeWaza,
    );
    expect(repository.topicById('missing'), isNull);
  });
}
