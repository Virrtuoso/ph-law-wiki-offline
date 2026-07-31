import 'dart:math';

/// Generates simple, sufficiently-unique local identifiers without
/// depending on an external UUID package. Not cryptographically secure;
/// suitable for local-only primary keys (bookmarks, notes).
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random.secure();

  static String newId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomPart = _random.nextInt(0x7fffffff).toRadixString(16);
    return '$timestamp-$randomPart';
  }
}
