import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ph_law_wiki_offline/data/repositories/article_repository_impl.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/database_helper.dart';
import 'package:ph_law_wiki_offline/infrastructure/seed/seed_data.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;
  late ArticleRepositoryImpl repository;

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting(
      testDatabaseName: inMemoryDatabasePath,
    );
    final db = await dbHelper.database;
    await SeedData.seedIfNeeded(db);
    repository = ArticleRepositoryImpl(databaseHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('ArticleRepositoryImpl', () {
    test('getArticleById returns the matching article', () async {
      final article = await repository.getArticleById('cc-art-37');
      expect(article, isNotNull);
      expect(article!.articleNumber, 'Art. 37');
      expect(article.title, 'Juridical Capacity and Capacity to Act');
      expect(article.lawId, 'civil-code-ra386');
    });

    test('getArticleById returns null for an unknown id', () async {
      final article = await repository.getArticleById('does-not-exist');
      expect(article, isNull);
    });

    test('getArticlesForLaw returns all articles ordered by order_index', () async {
      final articles = await repository.getArticlesForLaw('civil-code-ra386');
      expect(articles.length, 11); // Articles 37-47
      expect(articles.first.articleNumber, 'Art. 37');
      expect(articles.last.articleNumber, 'Art. 47');
    });

    test('getArticlesForNode returns only articles under that node', () async {
      final articles = await repository.getArticlesForNode(
        'cc-book1-title1-ch1',
      );
      expect(articles.length, 11);
      expect(articles.every((a) => a.nodeId == 'cc-book1-title1-ch1'), isTrue);
    });

    test('getCrossReferencesFrom returns outgoing references', () async {
      final refs = await repository.getCrossReferencesFrom('cc-art-40');
      expect(refs, isNotEmpty);
      expect(refs.first.toArticleId, 'cc-art-41');
    });

    test('getCrossReferencesTo returns incoming references', () async {
      final refs = await repository.getCrossReferencesTo('cc-art-41');
      expect(refs, isNotEmpty);
      expect(refs.first.fromArticleId, 'cc-art-40');
    });
  });
}
