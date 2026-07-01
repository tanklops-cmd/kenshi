import 'package:kendo_companion/src/features/moment/domain/moment.dart';

abstract interface class MomentRepository {
  Future<void> create(Moment moment);

  Future<Moment?> read(String id);

  Future<List<Moment>> readForSession(
    String sessionId, {
    bool includeArchived = false,
  });

  Future<List<Moment>> readRecent(int limit);

  Future<void> update(Moment moment);

  Future<void> archive(String id);
}
