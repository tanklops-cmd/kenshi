import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/learn/domain/learn_topic.dart';

void main() {
  testWidgets('navigates through Learn categories and topics', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KendoCompanionApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();

    final categoryScroll = find
        .descendant(
          of: find.byKey(const ValueKey('learnCategoryList')),
          matching: find.byType(Scrollable),
        )
        .first;
    for (final category in LearnCategory.values) {
      await tester.scrollUntilVisible(
        find.text(category.label),
        100,
        scrollable: categoryScroll,
      );
      expect(find.text(category.label), findsOneWidget);
    }

    await tester.fling(categoryScroll, const Offset(0, 1000), 1000);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Shikake-waza'),
      100,
      scrollable: categoryScroll,
    );
    await tester.tap(find.text('Shikake-waza'));
    await tester.pumpAndSettle();
    expect(find.text('Debana-men'), findsOneWidget);

    await tester.tap(find.text('Debana-men'));
    await tester.pumpAndSettle();
    expect(find.text('Learn Topic'), findsOneWidget);
    expect(find.text('Debana-men'), findsNWidgets(2));
    expect(
      find.text('A men strike made as the opponent begins to act.'),
      findsOneWidget,
    );
    expect(find.text('Related Practice Topic'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Footwork'),
      -100,
      scrollable: categoryScroll,
    );
    await tester.tap(find.text('Footwork'));
    await tester.pumpAndSettle();
    expect(find.text('No topics in this category yet.'), findsOneWidget);
  });
}
