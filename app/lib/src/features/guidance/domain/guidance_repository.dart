import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';

abstract interface class GuidanceRepository {
  Future<void> create(GuidanceEntry entry);

  Future<GuidanceEntry?> read(String id);

  Future<List<GuidanceEntry>> readForSession(
    String sessionId, {
    bool includeArchived = false,
  });

  Future<List<GuidanceEntry>> readRecent(int limit);

  Future<void> update(GuidanceEntry entry);

  Future<void> archive(String id, {required DateTime updatedAt});
}
