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
    this.freshNotes,
    this.reviewNotes,
    this.nextFocus,
    this.firstCaptureStartedAt,
    this.firstCaptureCompletedAt,
    this.reviewStartedAt,
    this.reviewLastEditedAt,
    this.nextFocusCreatedAt,
  });

  final String id;
  final DateTime createdAt;
  final DateTime trainingDate;
  final SessionType sessionType;
  final String title;
  final String? location;
  final String? notes;
  final String? freshNotes;
  final String? reviewNotes;
  final String? nextFocus;
  final DateTime? firstCaptureStartedAt;
  final DateTime? firstCaptureCompletedAt;
  final DateTime? reviewStartedAt;
  final DateTime? reviewLastEditedAt;
  final DateTime? nextFocusCreatedAt;
  final DateTime updatedAt;

  Session copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? trainingDate,
    SessionType? sessionType,
    String? title,
    Object? location = _notProvided,
    Object? notes = _notProvided,
    Object? freshNotes = _notProvided,
    Object? reviewNotes = _notProvided,
    Object? nextFocus = _notProvided,
    Object? firstCaptureStartedAt = _notProvided,
    Object? firstCaptureCompletedAt = _notProvided,
    Object? reviewStartedAt = _notProvided,
    Object? reviewLastEditedAt = _notProvided,
    Object? nextFocusCreatedAt = _notProvided,
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
      freshNotes: identical(freshNotes, _notProvided)
          ? this.freshNotes
          : freshNotes as String?,
      reviewNotes: identical(reviewNotes, _notProvided)
          ? this.reviewNotes
          : reviewNotes as String?,
      nextFocus: identical(nextFocus, _notProvided)
          ? this.nextFocus
          : nextFocus as String?,
      firstCaptureStartedAt: identical(firstCaptureStartedAt, _notProvided)
          ? this.firstCaptureStartedAt
          : firstCaptureStartedAt as DateTime?,
      firstCaptureCompletedAt: identical(firstCaptureCompletedAt, _notProvided)
          ? this.firstCaptureCompletedAt
          : firstCaptureCompletedAt as DateTime?,
      reviewStartedAt: identical(reviewStartedAt, _notProvided)
          ? this.reviewStartedAt
          : reviewStartedAt as DateTime?,
      reviewLastEditedAt: identical(reviewLastEditedAt, _notProvided)
          ? this.reviewLastEditedAt
          : reviewLastEditedAt as DateTime?,
      nextFocusCreatedAt: identical(nextFocusCreatedAt, _notProvided)
          ? this.nextFocusCreatedAt
          : nextFocusCreatedAt as DateTime?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
