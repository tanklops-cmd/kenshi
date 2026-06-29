enum SessionType {
  clubKeiko('Club Keiko'),
  seminar('Seminar'),
  shiai('Shiai'),
  grading('Grading'),
  homeTraining('Home Training'),
  other('Other');

  const SessionType(this.label);

  final String label;
}

const _notProvided = Object();

class Session {
  const Session({
    required this.id,
    required this.createdAt,
    required this.trainingDate,
    required this.sessionType,
    required this.title,
    required this.updatedAt,
    this.location,
    this.notes,
  });

  final String id;
  final DateTime createdAt;
  final DateTime trainingDate;
  final SessionType sessionType;
  final String title;
  final String? location;
  final String? notes;
  final DateTime updatedAt;

  Session copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? trainingDate,
    SessionType? sessionType,
    String? title,
    Object? location = _notProvided,
    Object? notes = _notProvided,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      trainingDate: trainingDate ?? this.trainingDate,
      sessionType: sessionType ?? this.sessionType,
      title: title ?? this.title,
      location: identical(location, _notProvided)
          ? this.location
          : location as String?,
      notes: identical(notes, _notProvided) ? this.notes : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
