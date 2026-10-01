import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';
import 'schema.dart';

/// Singleton wrapper around the app's single SQLite database.
///
/// In production this opens (or creates) a database file under the
/// platform's application documents directory. In tests, the global
/// `databaseFactory` (from `package:sqflite/sqflite.dart`) can be swapped
/// for `databaseFactoryFfi` (from `sqflite_common_ffi`) *before* the first
/// call to [database], and an explicit [testDatabaseName] of
/// `inMemoryDatabasePath` can be supplied to run fully in-memory.
class DatabaseHelper {
  DatabaseHelper._internal({String? testDatabaseName})
    : _testDatabaseName = testDatabaseName;

  static DatabaseHelper? _instance;

  /// The shared singleton instance used throughout the app.
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Creates a fresh, isolated instance intended for tests. This does not
  /// affect [instance].
  factory DatabaseHelper.forTesting({String? testDatabaseName}) {
    return DatabaseHelper._internal(testDatabaseName: testDatabaseName);
  }

  final String? _testDatabaseName;
  Database? _database;

  static const String _dbFileName = 'ph_law_wiki_offline.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final String path;
    if (_testDatabaseName != null) {
      path = _testDatabaseName;
    } else {
      final dbDir = await getDatabasesPath();
      path = p.join(dbDir, _dbFileName);
    }

    return openDatabase(
      path,
      version: Schema.schemaVersion,
      onCreate: Migrations.onCreate,
      onUpgrade: Migrations.onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Closes the underlying database connection and clears the cached
  /// instance so the next access re-opens it. Primarily useful for tests.
  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }
}
