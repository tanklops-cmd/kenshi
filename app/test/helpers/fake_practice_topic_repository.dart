import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic_repository.dart';

class FakePracticeTopicRepository implements PracticeTopicRepository {
  final List<PracticeTopic> _topics = [];

  @override
  Future<void> create(PracticeTopic topic) async {
    _topics.add(topic);
  }

  @override
  Future<PracticeTopic?> read(String id) async {
    for (final topic in _topics) {
      if (topic.id == id) {
        return topic;
      }
    }
    return null;
  }

  @override
  Future<List<PracticeTopic>> readAll({bool includeArchived = false}) async {
    final topics = _topics
        .where((topic) => includeArchived || !topic.archived)
        .toList(growable: false);
    return [...topics]
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  @override
  Future<void> update(PracticeTopic topic) async {
    final index = _topics.indexWhere((item) => item.id == topic.id);
    if (index == -1) {
      throw StateError('Practice topic ${topic.id} does not exist.');
    }
    _topics[index] = topic;
  }

  @override
  Future<void> archive(String id, {required DateTime updatedAt}) async {
    final topic = await read(id);
    if (topic == null) {
      throw StateError('Practice topic $id does not exist.');
    }
    await update(topic.copyWith(archived: true, updatedAt: updatedAt));
  }
}
