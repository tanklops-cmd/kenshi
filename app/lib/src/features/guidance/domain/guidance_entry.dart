const _notProvided = Object();

class GuidanceEntry {
  const GuidanceEntry({
    required this.id,
    required this.sessionId,
    required this.createdAt,
    required this.updatedAt,
    required this.advice,
    required this.archived,
    this.coachName,
    this.context,
  });

  final String id;
  final String sessionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coachName;
  final String advice;
  final String? context;
  final bool archived;

  GuidanceEntry copyWith({
    String? id,
    String? sessionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? coachName = _notProvided,
    String? advice,
    Object? context = _notProvided,
    bool? archived,
  }) {
    return GuidanceEntry(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coachName: identical(coachName, _notProvided)
          ? this.coachName
          : coachName as String?,
      advice: advice ?? this.advice,
      context: identical(context, _notProvided)
          ? this.context
          : context as String?,
      archived: archived ?? this.archived,
    );
  }
}
