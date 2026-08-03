import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ph_law_wiki_offline/data/repositories/search_repository_impl.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/database_helper.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/schema.dart';
import 'package:ph_law_wiki_offline/infrastructure/seed/seed_data.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;
  late SearchRepositoryImpl repository;

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting(
      testDatabaseName: inMemoryDatabasePath,
    );
    final db = await dbHelper.database;
    await SeedData.seedIfNeeded(db);
    repository = SearchRepositoryImpl(databaseHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('SearchRepositoryImpl (FTS5)', () {
    test('returns an empty list for a blank query', () async {
      final results = await repository.search('   ');
      expect(results, isEmpty);
    });

    test('finds articles by a distinctive keyword in the body', () async {
      final results = await repository.search('juridical');
      expect(results, isNotEmpty);
      expect(
        results.any((r) => r.articleId == 'cc-art-37'),
        isTrue,
        reason: 'Art. 37 mentions "juridical capacity" in its body',
      );
    });

    test('finds articles by a law-specific keyword', () async {
      final flagResults = await repository.search('flag');
      expect(flagResults, isNotEmpty);
      expect(flagResults.any((r) => r.lawCode == 'R.A. 8491'), isTrue);
    });

    test('search results include law title, code and snippet', () async {
      final results = await repository.search('capacity');
      expect(results, isNotEmpty);
      final first = results.first;
      expect(first.lawTitle, isNotEmpty);
      expect(first.lawCode, isNotEmpty);
      expect(first.articleNumber, isNotEmpty);
    });

    test('prefix matching finds partial-word queries', () async {
      final results = await repository.search('juri');
      expect(results.any((r) => r.articleId == 'cc-art-37'), isTrue);
    });

    test('returns no results for a nonsense query', () async {
      final results = await repository.search('zzzznonexistentqueryzzzz');
      expect(results, isEmpty);
    });
  });

  group('SearchRepositoryImpl (fallback without FTS table)', () {
    late DatabaseHelper fallbackDbHelper;
    late SearchRepositoryImpl fallbackRepository;
    late String databasePath;
    Directory? tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'ph_law_wiki_offline_fallback_',
      );
      databasePath = p.join(tempDir!.path, 'fallback.db');

      final db = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: Schema.schemaVersion,
          onCreate: (db, version) async {
            for (final statement in Schema.createCoreStatements) {
              await db.execute(statement);
            }
          },
        ),
      );
      await SeedData.seedIfNeeded(db);
      await db.close();

      fallbackDbHelper = DatabaseHelper.forTesting(testDatabaseName: databasePath);
      fallbackRepository = SearchRepositoryImpl(databaseHelper: fallbackDbHelper);
    });

    tearDown(() async {
      await fallbackDbHelper.close();
      await tempDir?.delete(recursive: true);
    });

    test('initialization succeeds and search still returns results', () async {
      final results = await fallbackRepository.search('juridical');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.articleId == 'cc-art-37'), isTrue);
    });
  });
}
