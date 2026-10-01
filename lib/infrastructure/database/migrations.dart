import 'package:sqflite/sqflite.dart';

import '../../domain/entities/app_metadata.dart';
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
    final backend = await installBestSearchBackend(db);
    await _writeSearchBackend(db, backend);
  }

  /// Chooses the best available search backend without poisoning the
  /// surrounding SQLite transaction.
  ///
  /// Android system SQLite often omits FTS5 (`no such module: fts5`). A failed
  /// `CREATE VIRTUAL TABLE` inside `onCreate`'s transaction can abort the
  /// whole schema create even when the Dart exception is caught. We therefore
  /// probe compile options first, wrap CREATE in a SAVEPOINT, and fall back to
  /// LIKE when neither FTS5 nor FTS4 can be installed.
  static Future<String> installBestSearchBackend(Database db) async {
    if (await _compileOptionEnabled(db, 'ENABLE_FTS5')) {
      final ok = await createFtsObjectsIfSupported(
        db,
        statements: Schema.createFts5Statements,
      );
      if (ok) return AppMetadata.searchBackendFts5;
    }

    if (await _compileOptionEnabled(db, 'ENABLE_FTS4') ||
        await _compileOptionEnabled(db, 'ENABLE_FTS3')) {
      final ok = await createFtsObjectsIfSupported(
        db,
        statements: Schema.createFts4Statements,
      );
      if (ok) return AppMetadata.searchBackendFts4;
    }

    // Last-resort attempt: some builds omit compile-option metadata but still
    // accept FTS4. Wrapped in SAVEPOINT so failure cannot abort onCreate.
    final fts4Ok = await createFtsObjectsIfSupported(
      db,
      statements: Schema.createFts4Statements,
    );
    if (fts4Ok) return AppMetadata.searchBackendFts4;

    return AppMetadata.searchBackendLike;
  }

  /// Creates FTS schema objects when the runtime SQLite build supports them.
  ///
  /// Returns true when FTS objects were created and false when they were
  /// intentionally skipped because the module is unavailable.
  ///
  /// Uses a SAVEPOINT so a missing-module error does not abort the outer
  /// `onCreate` transaction (a known footgun with Android SQLite + sqflite).
  static Future<bool> createFtsObjectsIfSupported(
    Database db, {
    List<String> statements = Schema.createFtsStatements,
  }) async {
    const savepoint = 'fts_install';
    try {
      await db.execute('SAVEPOINT $savepoint');
      for (final statement in statements) {
        await db.execute(statement);
      }
      await db.execute('RELEASE SAVEPOINT $savepoint');
      return true;
    } on DatabaseException catch (e) {
      try {
        await db.execute('ROLLBACK TO SAVEPOINT $savepoint');
        await db.execute('RELEASE SAVEPOINT $savepoint');
      } catch (_) {
        // Best-effort cleanup; outer onCreate may still succeed if core
        // tables were already created before this attempt.
      }
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
    final message = exception.toString().toLowerCase();
    return message.contains('no such module') ||
        (message.contains('fts5') && message.contains('not authorized'));
  }

  /// Non-throwing probe: returns whether a compile option is enabled.
  static Future<bool> _compileOptionEnabled(Database db, String option) async {
    try {
      final rows = await db.rawQuery(
        'SELECT sqlite_compileoption_used(?) AS enabled',
        [option],
      );
      if (rows.isEmpty) return false;
      final value = rows.first['enabled'];
      if (value is int) return value != 0;
      if (value is num) return value != 0;
      return value == true || value == '1';
    } catch (_) {
      return false;
    }
  }

  static Future<void> _writeSearchBackend(
    DatabaseExecutor db,
    String backend,
  ) async {
    await db.insert(
      'app_metadata',
      {
        'key': AppMetadata.keySearchBackend,
        'value': backend,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ensures [AppMetadata.keySearchBackend] is set for databases created
  /// before this metadata existed, without attempting a risky CREATE.
  static Future<String> ensureSearchBackendMetadata(Database db) async {
    final existing = await db.query(
      'app_metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [AppMetadata.keySearchBackend],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['value'] as String;
    }

    final hasFts = await _tableExists(db, 'articles_fts');
    final backend = hasFts
        ? AppMetadata.searchBackendFts5
        : AppMetadata.searchBackendLike;
    await _writeSearchBackend(db, backend);
    return backend;
  }

  static Future<bool> _tableExists(Database db, String name) async {
    final rows = await db.rawQuery(
      '''
      SELECT 1
      FROM sqlite_master
      WHERE type IN ('table', 'view') AND name = ?
      LIMIT 1
      ''',
      [name],
    );
    return rows.isNotEmpty;
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
