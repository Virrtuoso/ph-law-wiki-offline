import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ph_law_wiki_offline/data/repositories/article_repository_impl.dart';
import 'package:ph_law_wiki_offline/data/repositories/bookmark_repository_impl.dart';
import 'package:ph_law_wiki_offline/data/repositories/law_repository_impl.dart';
import 'package:ph_law_wiki_offline/data/repositories/note_repository_impl.dart';
import 'package:ph_law_wiki_offline/data/repositories/search_repository_impl.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/database_helper.dart';
import 'package:ph_law_wiki_offline/infrastructure/seed/seed_data.dart';
import 'package:ph_law_wiki_offline/presentation/providers/repository_providers.dart';

/// Ensures the sqflite FFI backend is registered exactly once for the
/// widget-test process, so an in-memory SQLite database can be created
/// without a real device/emulator.
void ensureFfiInitialized() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Creates a fresh, seeded in-memory [DatabaseHelper] and the matching
/// Riverpod [Override]s so widget tests can pump the real app/screens
/// against real (but ephemeral) SQLite data, without touching the
/// device-backed singleton `DatabaseHelper.instance` or path_provider.
Future<List<Override>> buildTestOverrides() async {
  final dbHelper = DatabaseHelper.forTesting(
    testDatabaseName: inMemoryDatabasePath,
  );
  final db = await dbHelper.database;
  await SeedData.seedIfNeeded(db);

  return [
    lawRepositoryProvider.overrideWithValue(
      LawRepositoryImpl(databaseHelper: dbHelper),
    ),
    articleRepositoryProvider.overrideWithValue(
      ArticleRepositoryImpl(databaseHelper: dbHelper),
    ),
    searchRepositoryProvider.overrideWithValue(
      SearchRepositoryImpl(databaseHelper: dbHelper),
    ),
    bookmarkRepositoryProvider.overrideWithValue(
      BookmarkRepositoryImpl(databaseHelper: dbHelper),
    ),
    noteRepositoryProvider.overrideWithValue(
      NoteRepositoryImpl(databaseHelper: dbHelper),
    ),
    // The database is already open and seeded above, so the init gate
    // can resolve immediately instead of touching the real singleton.
    appInitProvider.overrideWith((ref) async {}),
  ];
}

/// Pumps frames in fixed steps until [finder] matches at least one widget.
/// Fails with a clear error instead of hanging on unbounded settle calls.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 60,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxPumps; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
  throw TestFailure('Timed out waiting for: ${finder.description}');
}
