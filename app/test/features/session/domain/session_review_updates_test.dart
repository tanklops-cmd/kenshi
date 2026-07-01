import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:kendo_companion/src/features/session/domain/session_review_updates.dart';

void main() {
  test('fresh capture timestamps are set only once', () {
    final startedAt = DateTime.utc(2026, 7, 1, 9);
    final completedAt = DateTime.utc(2026, 7, 1, 9, 5);
    var session = SessionReviewUpdates.freshNotesChanged(
      _session(),
      freshNotes: 'First thought',
      startedAt: startedAt,
    );
    session = SessionReviewUpdates.freshNotesChanged(
      session,
      freshNotes: 'Updated before completion',
      startedAt: DateTime.utc(2026, 7, 1, 9, 2),
    );
    session = SessionReviewUpdates.freshNotesCompleted(
      session,
      completedAt: completedAt,
    );
    session = SessionReviewUpdates.freshNotesCompleted(
      session,
      completedAt: DateTime.utc(2026, 7, 1, 10),
    );

    expect(session.firstCaptureStartedAt, startedAt);
    expect(session.firstCaptureCompletedAt, completedAt);
  });

  test('review start is preserved while last edit advances', () {
    final startedAt = DateTime.utc(2026, 7, 2, 8);
    final firstEditAt = DateTime.utc(2026, 7, 2, 8, 5);
    final laterEditAt = DateTime.utc(2026, 7, 3, 7, 30);
    var session = SessionReviewUpdates.reviewNotesChanged(
      _session(),
      reviewNotes: 'First review',
      startedAt: startedAt,
      lastEditedAt: firstEditAt,
    );
    session = SessionReviewUpdates.reviewNotesChanged(
      session,
      reviewNotes: 'Developed understanding',
      startedAt: DateTime.utc(2026, 7, 3, 7),
      lastEditedAt: laterEditAt,
    );

    expect(session.reviewStartedAt, startedAt);
    expect(session.reviewLastEditedAt, laterEditAt);
  });

  test('next focus creation time is preserved across edits', () {
    final createdAt = DateTime.utc(2026, 7, 2, 8);
    var session = SessionReviewUpdates.nextFocusChanged(
      _session(),
      nextFocus: 'Win centre.',
      createdAt: createdAt,
    );
    session = SessionReviewUpdates.nextFocusChanged(
      session,
      nextFocus: 'Win centre before attacking.',
      createdAt: DateTime.utc(2026, 7, 3, 8),
    );

    expect(session.nextFocusCreatedAt, createdAt);
  });
}

Session _session() {
  return Session(
    id: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1),
    trainingDate: DateTime(2026, 7, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Tuesday keiko',
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}
