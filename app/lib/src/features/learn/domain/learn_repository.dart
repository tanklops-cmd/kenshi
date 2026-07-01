import 'package:kendo_companion/src/features/learn/domain/learn_topic.dart';

abstract interface class LearnRepository {
  List<LearnCategory> get categories;

  List<LearnTopic> topicsForCategory(LearnCategory category);

  LearnTopic? topicById(String id);
}
