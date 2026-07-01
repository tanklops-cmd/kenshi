import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/features/guidance/application/guidance_providers.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

/// The three most recent sessions that have a Next Focus entry.
/// Returns an empty list when sessions are still loading.
final currentFocusItemsProvider = Provider<List<String>>((ref) {
  return switch (ref.watch(sessionsProvider)) {
    AsyncData(:final value) => value
        .where((Session s) => _hasText(s.nextFocus))
        .take(3)
        .map((Session s) => s.nextFocus!.trim())
        .toList(),
    _ => [],
  };
});

/// The most recent session that has review or fresh notes.
/// Returns null when sessions are loading or no sessions have notes.
final lastReviewSessionProvider = Provider<Session?>((ref) {
  return switch (ref.watch(sessionsProvider)) {
    AsyncData(:final value) => value
        .where(
          (Session s) => _hasText(s.reviewNotes) || _hasText(s.freshNotes),
        )
        .firstOrNull,
    _ => null,
  };
});

/// The three most recent non-archived guidance entries across all sessions.
final recentGuidanceProvider =
    FutureProvider.autoDispose<List<GuidanceEntry>>((ref) {
      return ref.watch(guidanceRepositoryProvider).readRecent(3);
    });

/// The most recent non-archived moment across all sessions, or null.
final recentMomentProvider = FutureProvider.autoDispose<Moment?>((ref) async {
  final moments = await ref.watch(momentRepositoryProvider).readRecent(1);
  return moments.firstOrNull;
});

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

