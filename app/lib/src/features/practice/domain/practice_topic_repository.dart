import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';

abstract interface class PracticeTopicRepository {
  Future<void> create(PracticeTopic topic);

  Future<PracticeTopic?> read(String id);

  Future<List<PracticeTopic>> readAll({bool includeArchived = false});

  Future<void> update(PracticeTopic topic);

  Future<void> archive(String id, {required DateTime updatedAt});
}
