import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ph_law_wiki_offline/app.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(ensureFfiInitialized);

  testWidgets('home screen renders the search bar, offline badge and laws', (
    tester,
  ) async {
    final overrides = await buildTestOverrides();

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const PhLawWikiApp(),
      ),
    );
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('home-search-field')),
    );
    await pumpUntilFound(tester, find.textContaining('Civil Code'));

    // App bar title.
    expect(find.text('PH Law Wiki (Offline)'), findsOneWidget);

    // Prominent search entry point.
    expect(find.byKey(const ValueKey('home-search-field')), findsOneWidget);
    expect(
      find.text('Search laws, articles, or keywords…'),
      findsOneWidget,
    );

    // Offline badge is always visible on the home screen.
    expect(find.text('Works offline'), findsOneWidget);

    // Seeded laws should render as quick-access cards.
    expect(find.textContaining('Civil Code'), findsWidgets);
    expect(find.textContaining('Constitution'), findsWidgets);
    expect(find.textContaining('Flag'), findsWidgets);

    // Quick actions to the other main sections.
    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('tapping a law card navigates to the law browse screen', (
    tester,
  ) async {
    final overrides = await buildTestOverrides();

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PhLawWikiApp()),
    );
    await pumpUntilFound(tester, find.textContaining('Civil Code'));

    await tester.tap(find.textContaining('Civil Code').first);
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntilFound(tester, find.textContaining('Civil Code'));
    expect(find.byKey(const ValueKey('home-search-field')), findsNothing);

    // The browse screen shows the hierarchy for the selected law; the
    // law title should now appear again as the browse screen's header.
    expect(find.textContaining('Civil Code'), findsWidgets);
  });
}
