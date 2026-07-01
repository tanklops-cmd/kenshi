import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/practice/data/sqlite_practice_topic_repository.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic_repository.dart';
import 'package:uuid/uuid.dart';

final practiceTopicRepositoryProvider = Provider<PracticeTopicRepository>((
  ref,
) {
  final database = ref.watch(appDatabaseProvider);
  return SqlitePracticeTopicRepository(database);
});

final practiceTopicProvider = FutureProvider.autoDispose
    .family<PracticeTopic?, String>((ref, topicId) {
      return ref.watch(practiceTopicRepositoryProvider).read(topicId);
    });

final practiceTopicsProvider =
    AsyncNotifierProvider<PracticeTopicsController, List<PracticeTopic>>(
      PracticeTopicsController.new,
    );

class PracticeTopicsController extends AsyncNotifier<List<PracticeTopic>> {
  static const _uuid = Uuid();

  @override
  Future<List<PracticeTopic>> build() {
    return ref.watch(practiceTopicRepositoryProvider).readAll();
  }

  Future<PracticeTopic> createTopic({
    required String name,
    required PracticeTopicCategory category,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name is required.');
    }

    final now = DateTime.now().toUtc();
    final topic = PracticeTopic(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      category: category,
      name: trimmedName,
      currentState: '',
      mentalCues: '',
      archived: false,
    );
    final repository = ref.read(practiceTopicRepositoryProvider);

    await repository.create(topic);
    state = AsyncData(await repository.readAll());
    return topic;
  }

  Future<void> archiveTopic(String id) async {
    final repository = ref.read(practiceTopicRepositoryProvider);
    await repository.archive(id, updatedAt: DateTime.now().toUtc());
    state = AsyncData(await repository.readAll());
  }
}
