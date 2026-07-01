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
    this.sourcePath,
    this.clipStartMs,
    this.clipEndMs,
  });

  final String id;
  final String sessionId;
  final DateTime createdAt;
  final MomentType type;
  final String localPath;
  final String title;
  final String note;
  final bool archived;
  final String? sourcePath;
  final int? clipStartMs;
  final int? clipEndMs;

  Moment copyWith({
    String? id,
    String? sessionId,
    DateTime? createdAt,
    MomentType? type,
    String? localPath,
    String? title,
    String? note,
    Object? archived = _notProvided,
    Object? sourcePath = _notProvided,
    Object? clipStartMs = _notProvided,
    Object? clipEndMs = _notProvided,
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
      sourcePath: identical(sourcePath, _notProvided)
          ? this.sourcePath
          : sourcePath as String?,
      clipStartMs: identical(clipStartMs, _notProvided)
          ? this.clipStartMs
          : clipStartMs as int?,
      clipEndMs: identical(clipEndMs, _notProvided)
          ? this.clipEndMs
          : clipEndMs as int?,
    );
  }
}
