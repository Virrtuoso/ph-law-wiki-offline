import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ph_law_wiki_offline/app.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(ensureFfiInitialized);

  testWidgets(
    'toggling the bookmark icon on the article reader adds and removes '
    'the article from the bookmarks screen',
    (tester) async {
      final overrides = await buildTestOverrides();

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const PhLawWikiApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate directly via the router by pushing the search screen and
      // opening a known seeded article (Civil Code Art. 37).
      await tester.enterText(
        find.byKey(const ValueKey('home-search-field')),
        'juridical',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Art. 37').first);
      await tester.pumpAndSettle();

      final bookmarkButton = find.byKey(
        const ValueKey('bookmark-toggle-button'),
      );
      expect(bookmarkButton, findsOneWidget);

      // Starts unbookmarked.
      expect(
        tester.widget<IconButton>(bookmarkButton).icon,
        isA<Icon>().having((i) => i.icon, 'icon', Icons.bookmark_border),
      );

      // Tap to bookmark.
      await tester.tap(bookmarkButton);
      await tester.pumpAndSettle();

      expect(
        tester.widget<IconButton>(bookmarkButton).icon,
        isA<Icon>().having((i) => i.icon, 'icon', Icons.bookmark),
      );

      // Navigate to the bookmarks screen and confirm the article is listed.
      final context = tester.element(find.byType(Scaffold).first);
      context.push('/bookmarks');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Juridical Capacity and Capacity to Act'),
        findsWidgets,
      );

      // Go back and toggle the bookmark off again.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(bookmarkButton);
      await tester.pumpAndSettle();

      expect(
        tester.widget<IconButton>(bookmarkButton).icon,
        isA<Icon>().having((i) => i.icon, 'icon', Icons.bookmark_border),
      );
    },
  );
}
