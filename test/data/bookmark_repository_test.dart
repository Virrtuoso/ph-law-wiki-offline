import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ph_law_wiki_offline/data/repositories/bookmark_repository_impl.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/database_helper.dart';
import 'package:ph_law_wiki_offline/infrastructure/seed/seed_data.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;
  late BookmarkRepositoryImpl repository;

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting(
      testDatabaseName: inMemoryDatabasePath,
    );
    final db = await dbHelper.database;
    await SeedData.seedIfNeeded(db);
    repository = BookmarkRepositoryImpl(databaseHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('BookmarkRepositoryImpl', () {
    test('a fresh article is not bookmarked', () async {
      expect(await repository.isBookmarked('cc-art-37'), isFalse);
    });

    test('addBookmark makes an article appear as bookmarked', () async {
      await repository.addBookmark('cc-art-37');
      expect(await repository.isBookmarked('cc-art-37'), isTrue);

      final all = await repository.getAllBookmarks();
      expect(all.length, 1);
      expect(all.first.articleId, 'cc-art-37');
    });

    test('removeBookmark clears the bookmark', () async {
      await repository.addBookmark('cc-art-37');
      await repository.removeBookmark('cc-art-37');
      expect(await repository.isBookmarked('cc-art-37'), isFalse);
      expect(await repository.getAllBookmarks(), isEmpty);
    });

    test('toggleBookmark adds then removes', () async {
      await repository.toggleBookmark('cc-art-40');
      expect(await repository.isBookmarked('cc-art-40'), isTrue);

      await repository.toggleBookmark('cc-art-40');
      expect(await repository.isBookmarked('cc-art-40'), isFalse);
    });

    test('adding a bookmark twice does not create duplicates', () async {
      await repository.addBookmark('cc-art-37');
      await repository.addBookmark('cc-art-37');
      final all = await repository.getAllBookmarks();
      expect(all.length, 1);
    });

    test('multiple bookmarks are tracked independently', () async {
      await repository.addBookmark('cc-art-37');
      await repository.addBookmark('const-preamble');
      final all = await repository.getAllBookmarks();
      expect(all.length, 2);
      expect(all.map((b) => b.articleId).toSet(), {
        'cc-art-37',
        'const-preamble',
      });
    });
  });
}
