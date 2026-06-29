import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:kendo_companion/src/features/session/domain/session_repository.dart';

class FakeSessionRepository implements SessionRepository {
  final List<Session> _sessions = [];

  @override
  Future<void> create(Session session) async {
    _sessions.add(session);
  }

  @override
  Future<Session?> read(String id) async {
    for (final session in _sessions) {
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  Future<List<Session>> readAll() async {
    return [..._sessions]..sort((left, right) {
      final dateComparison = right.trainingDate.compareTo(left.trainingDate);
      return dateComparison != 0
          ? dateComparison
          : right.createdAt.compareTo(left.createdAt);
    });
  }

  @override
  Future<void> update(Session session) async {
    final index = _sessions.indexWhere((item) => item.id == session.id);
    if (index == -1) {
      throw StateError('Session ${session.id} does not exist.');
    }
    _sessions[index] = session;
  }

  @override
  Future<void> delete(String id) async {
    _sessions.removeWhere((session) => session.id == id);
  }
}
