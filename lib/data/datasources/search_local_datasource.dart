import 'package:sqflite/sqflite.dart';

/// Executes full-text search queries against the `articles_fts` virtual
/// table, joined with `laws` and `articles` for display purposes.
///
/// Falls back to a `LIKE`-based scan if FTS5 is unavailable on the current
/// platform's bundled SQLite build (a known limitation on some older
/// Android system images) so search still works, just less efficiently.
class SearchLocalDataSource {
  SearchLocalDataSource._();

  static const _joinAndSelect = '''
    SELECT
      articles.id AS article_id,
      articles.law_id AS law_id,
      articles.article_number AS article_number,
      articles.title AS title,
      laws.title AS law_title,
      laws.code AS law_code,
  ''';

  /// Converts a free-text query into an FTS5 MATCH expression that
  /// prefix-matches every whitespace-separated token, e.g.
  /// `civil personality` -> `"civil"* "personality"*`.
  static String buildMatchQuery(String query) {
    final tokens = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => t.replaceAll('"', ''));
    return tokens.map((t) => '"$t"*').join(' ');
  }

  static Future<List<Map<String, Object?>>> searchFts(
    Database db,
    String query,
    int limit,
  ) async {
    final matchQuery = buildMatchQuery(query);
    if (matchQuery.isEmpty) return [];

    return db.rawQuery(
      '''
      $_joinAndSelect
        snippet(articles_fts, 4, '', '', '…', 12) AS snippet
      FROM articles_fts
      JOIN articles ON articles.id = articles_fts.article_id
      JOIN laws ON laws.id = articles.law_id
      WHERE articles_fts MATCH ?
      ORDER BY rank
      LIMIT ?
      ''',
      [matchQuery, limit],
    );
  }

  static Future<bool> hasFtsTable(Database db) async {
    final rows = await db.rawQuery(
      '''
      SELECT 1
      FROM sqlite_master
      WHERE type = 'table' AND name = 'articles_fts'
      LIMIT 1
      ''',
    );
    return rows.isNotEmpty;
  }

  /// Simple substring fallback used when FTS5 is not available.
  static Future<List<Map<String, Object?>>> searchLike(
    Database db,
    String query,
    int limit,
  ) async {
    final like = '%$query%';
    return db.rawQuery(
      '''
      $_joinAndSelect
        substr(articles.body, 1, 140) AS snippet
      FROM articles
      JOIN laws ON laws.id = articles.law_id
      WHERE articles.body LIKE ?
         OR articles.title LIKE ?
         OR articles.article_number LIKE ?
      ORDER BY articles.order_index ASC
      LIMIT ?
      ''',
      [like, like, like, limit],
    );
  }
}
