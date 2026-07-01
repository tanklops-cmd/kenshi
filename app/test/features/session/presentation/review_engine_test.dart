import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

import '../../../helpers/fake_session_repository.dart';

void main() {
  testWidgets('autosaves the review workflow and preserves fresh notes', (
    tester,
  ) async {
    final repository = FakeSessionRepository();
    await repository.create(_session());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionRepositoryProvider.overrideWithValue(repository)],
        child: const KendoCompanionApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reflect').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tuesday keiko'));
    await tester.pumpAndSettle();

    final freshNotesField = find.byKey(const ValueKey('freshNotesField'));
    expect(freshNotesField, findsOneWidget);
    expect(tester.widget<TextField>(freshNotesField).autofocus, isTrue);

    await tester.enterText(freshNotesField, 'My timing felt late.');
    await tester.pump(const Duration(milliseconds: 200));
    expect((await repository.read('session-1'))!.freshNotes, isNull);

    await tester.tap(find.text('Training Date'));
    await tester.pumpAndSettle();

    final workspaceScroll = find
        .descendant(
          of: find.byKey(const ValueKey('sessionWorkspaceList')),
          matching: find.byType(Scrollable),
        )
        .first;
    final reviewSection = find.byKey(const ValueKey('reviewNotesSection'));
    await tester.scrollUntilVisible(
      reviewSection,
      160,
      scrollable: workspaceScroll,
    );
    await tester.tap(reviewSection);
    await tester.pumpAndSettle();
    expect(
      (await repository.read('session-1'))!.freshNotes,
      'My timing felt late.',
    );
    final afterFreshCapture = (await repository.read('session-1'))!;
    expect(afterFreshCapture.firstCaptureStartedAt, isNotNull);
    expect(afterFreshCapture.firstCaptureCompletedAt, isNotNull);
    expect(
      afterFreshCapture.firstCaptureCompletedAt!.isBefore(
        afterFreshCapture.firstCaptureStartedAt!,
      ),
      isFalse,
    );
    expect(freshNotesField, findsNothing);
    expect(
      find.byKey(const ValueKey('freshNotesCompletedCard')),
      findsOneWidget,
    );
    expect(find.text('My timing felt late.'), findsWidgets);

    final reviewNotesField = find.byKey(const ValueKey('reviewNotesField'));
    await tester.enterText(
      reviewNotesField,
      'I was reacting instead of initiating.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(
      (await repository.read('session-1'))!.reviewNotes,
      'I was reacting instead of initiating.',
    );
    final afterFirstReview = (await repository.read('session-1'))!;
    expect(afterFirstReview.reviewStartedAt, isNotNull);
    expect(afterFirstReview.reviewLastEditedAt, isNotNull);

    await tester.enterText(
      reviewNotesField,
      'I need to create the opportunity first.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(reviewNotesField).readOnly, isFalse);
    expect(
      (await repository.read('session-1'))!.reviewNotes,
      'I need to create the opportunity first.',
    );
    final afterLaterReview = (await repository.read('session-1'))!;
    expect(afterLaterReview.reviewStartedAt, afterFirstReview.reviewStartedAt);
    expect(
      afterLaterReview.reviewLastEditedAt!.isBefore(
        afterFirstReview.reviewLastEditedAt!,
      ),
      isFalse,
    );

    final nextFocusSection = find.byKey(const ValueKey('nextFocusSection'));
    await tester.scrollUntilVisible(
      nextFocusSection,
      160,
      scrollable: workspaceScroll,
    );
    await tester.tap(nextFocusSection);
    await tester.pumpAndSettle();

    final nextFocusField = find.byKey(const ValueKey('nextFocusField'));
    await tester.enterText(nextFocusField, 'Win centre before attacking.');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(nextFocusField).maxLines, 1);
    expect(
      (await repository.read('session-1'))!.nextFocus,
      'Win centre before attacking.',
    );
    final nextFocusCreatedAt = (await repository.read(
      'session-1',
    ))!.nextFocusCreatedAt;
    expect(nextFocusCreatedAt, isNotNull);

    await tester.enterText(nextFocusField, 'Drive through every strike.');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    final afterNextFocusEdit = (await repository.read('session-1'))!;
    expect(afterNextFocusEdit.nextFocus, 'Drive through every strike.');
    expect(afterNextFocusEdit.nextFocusCreatedAt, nextFocusCreatedAt);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tuesday keiko'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('freshNotesField')), findsNothing);
    expect(
      find.byKey(const ValueKey('freshNotesCompletedCard')),
      findsOneWidget,
    );
    final reopened = (await repository.read('session-1'))!;
    expect(
      reopened.firstCaptureStartedAt,
      afterFreshCapture.firstCaptureStartedAt,
    );
    expect(
      reopened.firstCaptureCompletedAt,
      afterFreshCapture.firstCaptureCompletedAt,
    );
  });
}

Session _session() {
  return Session(
    id: 'session-1',
    createdAt: DateTime.utc(2026, 6, 1, 9),
    trainingDate: DateTime(2026, 6, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Tuesday keiko',
    updatedAt: DateTime.utc(2026, 6, 1, 9),
  );
}
