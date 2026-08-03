import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

    final created = await Migrations.createFtsObjectsIfSupported(
      db,
      statements: const [
        'CREATE VIRTUAL TABLE articles_fts USING fts_not_available(body)',
      ],
    );

    expect(created, isFalse);
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'articles'",
    );
    expect(tables, isNotEmpty);
    await db.close();
  });
}
