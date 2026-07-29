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
    for (final statement in Schema.createStatements) {
      await db.execute(statement);
    }
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
