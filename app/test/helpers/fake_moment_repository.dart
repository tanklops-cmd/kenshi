import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_repository.dart';

class FakeMomentRepository implements MomentRepository {
  final List<Moment> _moments = [];

  @override
  Future<void> create(Moment moment) async {
    _moments.add(moment);
  }

  @override
  Future<Moment?> read(String id) async {
    for (final moment in _moments) {
      if (moment.id == id) {
        return moment;
      }
    }
    return null;
  }

  @override
  Future<List<Moment>> readForSession(
    String sessionId, {
    bool includeArchived = false,
  }) async {
    final result = _moments.where(
      (moment) =>
          moment.sessionId == sessionId &&
          (includeArchived || !moment.archived),
    );
    return result.toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }

  @override
  Future<void> update(Moment moment) async {
    final index = _moments.indexWhere((item) => item.id == moment.id);
    if (index == -1) {
      throw StateError('Moment ${moment.id} does not exist.');
    }
    _moments[index] = moment;
  }

  @override
  Future<void> archive(String id) async {
    final index = _moments.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Moment $id does not exist.');
    }
    _moments[index] = _moments[index].copyWith(archived: true);
  }

  @override
  Future<List<Moment>> readRecent(int limit) async {
    final sorted = _moments
        .where((moment) => !moment.archived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }
}
