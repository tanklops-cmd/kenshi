import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/session/data/sqlite_session_repository.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:kendo_companion/src/features/session/domain/session_repository.dart';
import 'package:uuid/uuid.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SqliteSessionRepository(database);
});

final sessionProvider = FutureProvider.autoDispose.family<Session?, String>((
  ref,
  sessionId,
) {
  return ref.watch(sessionRepositoryProvider).read(sessionId);
});

final sessionsProvider =
    AsyncNotifierProvider<SessionsController, List<Session>>(
      SessionsController.new,
    );

class SessionsController extends AsyncNotifier<List<Session>> {
  static const _uuid = Uuid();

  @override
  Future<List<Session>> build() {
    return ref.watch(sessionRepositoryProvider).readAll();
  }

  Future<Session> createSession({
    required DateTime trainingDate,
    required SessionType sessionType,
    required String title,
    String? location,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title is required.');
    }

    final now = DateTime.now().toUtc();
    final session = Session(
      id: _uuid.v4(),
      createdAt: now,
      trainingDate: DateTime(
        trainingDate.year,
        trainingDate.month,
        trainingDate.day,
      ),
      sessionType: sessionType,
      title: trimmedTitle,
      location: _normaliseOptionalText(location),
      updatedAt: now,
    );
    final repository = ref.read(sessionRepositoryProvider);

    await repository.create(session);
    state = AsyncData(await repository.readAll());
    return session;
  }

  String? _normaliseOptionalText(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }
}
