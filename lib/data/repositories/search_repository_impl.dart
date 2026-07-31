import 'package:sqflite/sqflite.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../infrastructure/database/database_helper.dart';
import '../datasources/search_local_datasource.dart';

class SearchRepositoryImpl implements ISearchRepository {
  SearchRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  @override
  Future<List<SearchResult>> search(String query, {int limit = 50}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final db = await _databaseHelper.database;

    List<Map<String, Object?>> rows;
    try {
      rows = await SearchLocalDataSource.searchFts(db, trimmed, limit);
    } on DatabaseException {
      // FTS5 may be unavailable on some platforms' bundled SQLite; fall
      // back to a plain LIKE scan so search still functions.
      rows = await SearchLocalDataSource.searchLike(db, trimmed, limit);
    }

    return rows.map((row) {
      return SearchResult(
        articleId: row['article_id'] as String,
        lawId: row['law_id'] as String,
        lawTitle: row['law_title'] as String,
        lawCode: row['law_code'] as String,
        articleNumber: row['article_number'] as String,
        articleTitle: row['title'] as String?,
        snippet: (row['snippet'] as String? ?? '').trim(),
      );
    }).toList();
  }
}
