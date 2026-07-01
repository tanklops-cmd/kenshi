enum MomentType {
  video('Video'),
  photo('Photo');

  const MomentType(this.label);

  final String label;
}

const _notProvided = Object();

class Moment {
  const Moment({
    required this.id,
    required this.sessionId,
    required this.createdAt,
    required this.type,
    required this.localPath,
    required this.title,
    required this.note,
    required this.archived,
  });

  final String id;
  final String sessionId;
  final DateTime createdAt;
  final MomentType type;
  final String localPath;
  final String title;
  final String note;
  final bool archived;

  Moment copyWith({
    String? id,
    String? sessionId,
    DateTime? createdAt,
    MomentType? type,
    String? localPath,
    String? title,
    String? note,
    Object? archived = _notProvided,
  }) {
    return Moment(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      title: title ?? this.title,
      note: note ?? this.note,
      archived: identical(archived, _notProvided)
          ? this.archived
          : archived! as bool,
    );
  }
}
