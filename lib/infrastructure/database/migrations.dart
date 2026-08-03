import 'package:sqflite/sqflite.dart';

import 'schema.dart';

/// Handles schema creation and future version upgrades.
///
/// New schema versions should add a numbered `_upgradeToVN` method and
/// invoke it from [onUpgrade] rather than mutating existing methods, so
/// upgrade paths remain reproducible across all installed versions.
class Migrations {
  Migrations._();

  static Future<void> onCreate(Database db, int version) async {
    for (final statement in Schema.createCoreStatements) {
      await db.execute(statement);
    }
    await createFtsObjectsIfSupported(db);
  }

  /// Creates FTS schema objects when the runtime SQLite build supports FTS5.
  ///
  /// Returns true when FTS objects were created and false when they were
  /// intentionally skipped because the module is unavailable.
  static Future<bool> createFtsObjectsIfSupported(
    Database db, {
    List<String> statements = Schema.createFtsStatements,
  }) async {
    try {
      for (final statement in statements) {
        await db.execute(statement);
      }
      return true;
    } on DatabaseException catch (e) {
      if (_isMissingFtsModuleError(e)) {
        return false;
      }
      rethrow;
    }
  }

  static bool _isMissingFtsModuleError(DatabaseException exception) {
    // "no such module: <name>" is the only error class emitted when a
    // CREATE VIRTUAL TABLE statement references a SQLite module that the
    // runtime build does not include (e.g. fts5 on stripped Android
    // SQLite builds).  Any other DatabaseException (syntax error,
    // constraint violation, etc.) is intentionally re-thrown so it is
    // not silently swallowed.
    return exception.toString().toLowerCase().contains('no such module');
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // No prior versions yet. Future migrations go here, e.g.:
    // if (oldVersion < 2) {
    //   await _upgradeToV2(db);
    // }
  }
}
