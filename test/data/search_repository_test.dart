import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ph_law_wiki_offline/data/repositories/search_repository_impl.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/database_helper.dart';
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
}
