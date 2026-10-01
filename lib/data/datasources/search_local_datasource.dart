import 'package:sqflite/sqflite.dart';

import '../../domain/entities/app_metadata.dart';
import '../../infrastructure/database/migrations.dart';

/// Executes full-text search queries against the `articles_fts` virtual
/// table, joined with `laws` and `articles` for display purposes.
///
/// Falls back to a `LIKE`-based scan if FTS5/FTS4 is unavailable on the
/// current platform's bundled SQLite build (a known limitation on many
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

  /// Converts a free-text query into an FTS MATCH expression that
  /// prefix-matches every whitespace-separated token, e.g.
  /// `civil personality` -> `"civil"* "personality"*`.
  static String buildMatchQuery(String query) {
    final tokens = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => t.replaceAll('"', ''))
        .where((t) => t.isNotEmpty);
    return tokens.map((t) => '"$t"*').join(' ');
  }

  /// Escapes `\`, `%`, and `_` so user input cannot widen a LIKE pattern.
  static String escapeLikePattern(String raw) {
    return raw
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  static Future<String> resolveSearchBackend(Database db) {
    return Migrations.ensureSearchBackendMetadata(db);
  }

  static Future<List<Map<String, Object?>>> searchFts(
    Database db,
    String query,
    int limit, {
    bool useRank = true,
  }) async {
    final matchQuery = buildMatchQuery(query);
    if (matchQuery.isEmpty) return [];

    final orderBy = useRank ? 'ORDER BY rank' : 'ORDER BY articles.order_index ASC';

    return db.rawQuery(
      '''
      $_joinAndSelect
        substr(articles.body, 1, 140) AS snippet
      FROM articles_fts
      JOIN articles ON articles.id = articles_fts.article_id
      JOIN laws ON laws.id = articles.law_id
      WHERE articles_fts MATCH ?
      $orderBy
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
      WHERE type IN ('table', 'view') AND name = 'articles_fts'
      LIMIT 1
      ''',
    );
    return rows.isNotEmpty;
  }

  /// Simple substring fallback used when FTS is not available.
  static Future<List<Map<String, Object?>>> searchLike(
    Database db,
    String query,
    int limit,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final like = '%${escapeLikePattern(trimmed)}%';
    return db.rawQuery(
      '''
      $_joinAndSelect
        substr(articles.body, 1, 140) AS snippet
      FROM articles
      JOIN laws ON laws.id = articles.law_id
      WHERE articles.body LIKE ? ESCAPE '\\'
         OR articles.title LIKE ? ESCAPE '\\'
         OR articles.article_number LIKE ? ESCAPE '\\'
         OR laws.title LIKE ? ESCAPE '\\'
         OR laws.code LIKE ? ESCAPE '\\'
      ORDER BY articles.order_index ASC
      LIMIT ?
      ''',
      [like, like, like, like, like, limit],
    );
  }

  /// Runs the appropriate search strategy for [backend].
  static Future<List<Map<String, Object?>>> searchWithBackend(
    Database db,
    String backend,
    String query,
    int limit,
  ) async {
    switch (backend) {
      case AppMetadata.searchBackendFts5:
        return searchFts(db, query, limit, useRank: true);
      case AppMetadata.searchBackendFts4:
        return searchFts(db, query, limit, useRank: false);
      case AppMetadata.searchBackendLike:
      default:
        return searchLike(db, query, limit);
    }
  }
}
