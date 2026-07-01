import 'package:kendo_companion/src/features/session/domain/session.dart';

abstract final class SessionReviewUpdates {
  static Session freshNotesChanged(
    Session session, {
    required String? freshNotes,
    required DateTime startedAt,
  }) {
    return session.copyWith(
      freshNotes: freshNotes,
      firstCaptureStartedAt: session.firstCaptureStartedAt ?? startedAt,
    );
  }

  static Session freshNotesCompleted(
    Session session, {
    required DateTime completedAt,
  }) {
    return session.copyWith(
      firstCaptureCompletedAt: session.firstCaptureCompletedAt ?? completedAt,
    );
  }

  static Session reviewNotesChanged(
    Session session, {
    required String? reviewNotes,
    required DateTime startedAt,
    required DateTime lastEditedAt,
  }) {
    return session.copyWith(
      reviewNotes: reviewNotes,
      reviewStartedAt: session.reviewStartedAt ?? startedAt,
      reviewLastEditedAt: lastEditedAt,
    );
  }

  static Session nextFocusChanged(
    Session session, {
    required String? nextFocus,
    required DateTime createdAt,
  }) {
    return session.copyWith(
      nextFocus: nextFocus,
      nextFocusCreatedAt: nextFocus == null
          ? session.nextFocusCreatedAt
          : session.nextFocusCreatedAt ?? createdAt,
    );
  }
}
