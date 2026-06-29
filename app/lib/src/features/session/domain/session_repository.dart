import 'package:kendo_companion/src/features/session/domain/session.dart';

abstract interface class SessionRepository {
  Future<void> create(Session session);

  Future<Session?> read(String id);

  Future<List<Session>> readAll();

  Future<void> update(Session session);

  Future<void> delete(String id);
}
