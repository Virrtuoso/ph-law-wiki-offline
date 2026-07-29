import 'package:sqflite/sqflite.dart';

/// Raw SQLite queries for the `laws` and `hierarchy_nodes` tables.
class LawLocalDataSource {
  LawLocalDataSource._();

  static Future<List<Map<String, Object?>>> getAllLaws(Database db) {
    return db.query('laws', orderBy: 'title ASC');
  }

  static Future<Map<String, Object?>?> getLawById(Database db, String id) async {
    final rows = await db.query('laws', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, Object?>>> getHierarchyForLaw(
    Database db,
    String lawId,
  ) {
    return db.query(
      'hierarchy_nodes',
      where: 'law_id = ?',
      whereArgs: [lawId],
      orderBy: 'order_index ASC',
    );
  }

  static Future<List<Map<String, Object?>>> getChildNodes(
    Database db,
    String lawId,
    String? parentId,
  ) {
    if (parentId == null) {
      return db.query(
        'hierarchy_nodes',
        where: 'law_id = ? AND parent_id IS NULL',
        whereArgs: [lawId],
        orderBy: 'order_index ASC',
      );
    }
    return db.query(
      'hierarchy_nodes',
      where: 'law_id = ? AND parent_id = ?',
      whereArgs: [lawId, parentId],
      orderBy: 'order_index ASC',
    );
  }
}
