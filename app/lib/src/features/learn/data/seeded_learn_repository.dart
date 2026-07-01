import 'package:kendo_companion/src/features/learn/domain/learn_repository.dart';
import 'package:kendo_companion/src/features/learn/domain/learn_topic.dart';

class SeededLearnRepository implements LearnRepository {
  const SeededLearnRepository();

  static const _topics = [
    LearnTopic(
      id: 'debana-men',
      category: LearnCategory.techniques,
      title: 'Debana-men',
      summary: 'A men strike made as the opponent begins to act.',
      body:
          'Debana-men uses the beginning of the opponent’s movement as an '
          'opportunity. Common teaching points include maintaining pressure, '
          'recognising intent, and striking without hesitation.',
      relatedPracticeTopicName: 'Debana-men',
    ),
    LearnTopic(
      id: 'seme',
      category: LearnCategory.fundamentals,
      title: 'Seme',
      summary: 'Pressure used to create an opportunity before striking.',
      body:
          'Seme combines posture, distance, spirit, and intention. It is often '
          'used to disturb the opponent’s readiness or invite a response that '
          'creates a clear opportunity.',
      relatedPracticeTopicName: 'Seme',
    ),
    LearnTopic(
      id: 'maai',
      category: LearnCategory.fundamentals,
      title: 'Maai',
      summary: 'The relationship of distance and timing between opponents.',
      body:
          'Maai changes as both kendoka move and apply pressure. Understanding '
          'it involves recognising when a target can be reached and when the '
          'opponent can reach you.',
      relatedPracticeTopicName: 'Maai',
    ),
    LearnTopic(
      id: 'kirikaeshi',
      category: LearnCategory.training,
      title: 'Kirikaeshi',
      summary: 'A paired drill combining a central strike and repeated cuts.',
      body:
          'Kirikaeshi is commonly used to practise rhythm, footwork, breathing, '
          'distance, and committed cutting. Exact forms may vary by dojo, so '
          'follow the method taught by your instructor.',
      relatedPracticeTopicName: 'Kirikaeshi',
    ),
    LearnTopic(
      id: 'nihon-kendo-kata',
      category: LearnCategory.kata,
      title: 'Nihon Kendo Kata',
      summary: 'Formal paired kata practised with wooden swords.',
      body:
          'Nihon Kendo Kata develops understanding of distance, timing, posture, '
          'opportunity, and the roles of uchidachi and shidachi. Practice should '
          'follow qualified instruction.',
    ),
    LearnTopic(
      id: 'shinai-care',
      category: LearnCategory.equipment,
      title: 'Shinai care',
      summary: 'Regular inspection helps keep a shinai safe for practice.',
      body:
          'Before training, check the bamboo for splinters or damage and inspect '
          'the leather fittings and string. Do not use a damaged shinai; repair '
          'or replace it before returning to practice.',
    ),
  ];

  @override
  List<LearnCategory> get categories => List.unmodifiable(LearnCategory.values);

  @override
  LearnTopic? topicById(String id) {
    for (final topic in _topics) {
      if (topic.id == id) {
        return topic;
      }
    }
    return null;
  }

  @override
  List<LearnTopic> topicsForCategory(LearnCategory category) {
    return List.unmodifiable(
      _topics.where((topic) => topic.category == category),
    );
  }
}
