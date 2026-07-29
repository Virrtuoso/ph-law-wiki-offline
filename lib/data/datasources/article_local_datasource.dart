import 'package:sqflite/sqflite.dart';

/// Raw SQLite queries for the `articles` and `cross_references` tables.
class ArticleLocalDataSource {
  ArticleLocalDataSource._();

  static Future<Map<String, Object?>?> getArticleById(
    Database db,
    String id,
  ) async {
    final rows = await db.query(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, Object?>>> getArticlesForLaw(
    Database db,
    String lawId,
  ) {
    return db.query(
      'articles',
      where: 'law_id = ?',
      whereArgs: [lawId],
      orderBy: 'order_index ASC',
    );
  }

  static Future<List<Map<String, Object?>>> getArticlesForNode(
    Database db,
    String nodeId,
  ) {
    return db.query(
      'articles',
      where: 'node_id = ?',
      whereArgs: [nodeId],
      orderBy: 'order_index ASC',
    );
  }

  static Future<List<Map<String, Object?>>> getCrossReferencesFrom(
    Database db,
    String articleId,
  ) {
    return db.query(
      'cross_references',
      where: 'from_article_id = ?',
      whereArgs: [articleId],
    );
  }

  static Future<List<Map<String, Object?>>> getCrossReferencesTo(
    Database db,
    String articleId,
  ) {
    return db.query(
      'cross_references',
      where: 'to_article_id = ?',
      whereArgs: [articleId],
    );
  }
}
