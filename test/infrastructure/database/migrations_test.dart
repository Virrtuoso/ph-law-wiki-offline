import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ph_law_wiki_offline/domain/entities/app_metadata.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/migrations.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/schema.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('createFtsObjectsIfSupported returns false when module is unavailable', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: Schema.schemaVersion,
        onCreate: (db, version) async {
          for (final statement in Schema.createCoreStatements) {
            await db.execute(statement);
          }
        },
      ),
    );

    // Simulate the real Android scenario: the FTS module is absent.
    // Using a made-up module name exercises the same "no such module"
    // error path that fts5 produces on stripped SQLite builds.
    final created = await Migrations.createFtsObjectsIfSupported(
      db,
      statements: const [
        'CREATE VIRTUAL TABLE articles_fts USING fts5_unavailable(body)',
      ],
    );

    expect(created, isFalse);
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'articles'",
    );
    expect(tables, isNotEmpty);
    await db.close();
  });

  test('createFtsObjectsIfSupported rethrows unrelated database errors', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: Schema.schemaVersion,
        onCreate: (db, version) async {
          for (final statement in Schema.createCoreStatements) {
            await db.execute(statement);
          }
        },
      ),
    );

    // A syntax error is unrelated to a missing module and must not be
    // silently swallowed.
    await expectLater(
      Migrations.createFtsObjectsIfSupported(
        db,
        statements: const ['THIS IS NOT VALID SQL'],
      ),
      throwsA(isA<Exception>()),
    );

    await db.close();
  });

  test('onCreate records a search backend and leaves core tables intact', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: Schema.schemaVersion,
        onCreate: Migrations.onCreate,
      ),
    );

    final rows = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: [AppMetadata.keySearchBackend],
    );
    expect(rows, isNotEmpty);
    expect(
      rows.first['value'],
      anyOf(
        AppMetadata.searchBackendFts5,
        AppMetadata.searchBackendFts4,
        AppMetadata.searchBackendLike,
      ),
    );

    final articles = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'articles'",
    );
    expect(articles, isNotEmpty);
    await db.close();
  });
}
