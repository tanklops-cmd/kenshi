import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/practice/application/practice_topic_providers.dart';

import '../../../helpers/fake_practice_topic_repository.dart';

void main() {
  testWidgets('creates and edits a practice topic', (tester) async {
    final repository = FakePracticeTopicRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          practiceTopicRepositoryProvider.overrideWithValue(repository),
        ],
        child: const KendoCompanionApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    expect(find.text('No practice topics yet.'), findsOneWidget);

    await tester.tap(find.text('New Practice Topic'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('createPracticeTopicButton')));
    await tester.pump();
    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Category is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('practiceTopicNameField')),
      'Debana-men',
    );
    await tester.tap(find.byKey(const ValueKey('practiceTopicCategoryField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shikake-waza').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('createPracticeTopicButton')));
    await tester.pumpAndSettle();

    expect(find.text('Practice Topic'), findsOneWidget);
    expect(find.text('Debana-men'), findsOneWidget);
    expect(find.text('Shikake-waza'), findsOneWidget);
    expect(find.text('Save'), findsNothing);

    final currentStateField = find.byKey(
      const ValueKey('practiceCurrentStateField'),
    );
    await tester.enterText(
      currentStateField,
      'Create the opportunity first.\nDo not wait passively.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Saved just now'), findsOneWidget);

    final mentalCuesField = find.byKey(
      const ValueKey('practiceMentalCuesField'),
    );
    await tester.enterText(
      mentalCuesField,
      'Win centre first.\nCommit forward.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    final topics = await repository.readAll();
    expect(topics, hasLength(1));
    expect(
      topics.single.currentState,
      'Create the opportunity first.\nDo not wait passively.',
    );
    expect(topics.single.mentalCues, 'Win centre first.\nCommit forward.');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Debana-men'), findsOneWidget);
    expect(find.text('Shikake-waza'), findsOneWidget);
    expect(find.text('Create the opportunity first.'), findsOneWidget);
    expect(find.text('Do not wait passively.'), findsNothing);
  });
}
