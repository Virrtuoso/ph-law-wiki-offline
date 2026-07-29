import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ph_law_wiki_offline/app.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(ensureFfiInitialized);

  testWidgets(
    'searching from the home screen navigates to results and opens an article',
    (tester) async {
      final overrides = await buildTestOverrides();

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PhLawWikiApp()),
      );
      await tester.pumpAndSettle();

      // Enter a query on the home screen and submit it.
      await tester.enterText(
        find.byKey(const ValueKey('home-search-field')),
        'juridical',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // We should now be on the search screen with results.
      expect(find.byKey(const ValueKey('search-screen-field')), findsOneWidget);
      expect(find.textContaining('Art. 37'), findsWidgets);

      // Tapping a result opens the article reader.
      await tester.tap(find.textContaining('Art. 37').first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Juridical Capacity and Capacity to Act'),
        findsWidgets,
      );
      // The disclaimer footer must be present on the reader screen.
      expect(
        find.text('Information only, not legal advice.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('typing directly on the search screen updates results live', (
    tester,
  ) async {
    final overrides = await buildTestOverrides();

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PhLawWikiApp()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('home-search-field')),
      'flag',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.textContaining('Flag and Heraldic'), findsWidgets);

    // Clearing the search field should show the empty-query prompt.
    await tester.enterText(
      find.byKey(const ValueKey('search-screen-field')),
      '',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Start typing to search the law catalogue.'),
      findsOneWidget,
    );
  });
}
