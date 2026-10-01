/// A single app-level metadata key/value pair, e.g. dataset version,
/// last-updated timestamp, or first-run seed flag.
class AppMetadata {
  final String key;
  final String value;

  const AppMetadata({required this.key, required this.value});

  static const String keySeeded = 'seeded';
  static const String keyDatasetVersion = 'dataset_version';
  static const String keyLastUpdated = 'last_updated';

  /// How article search is backed on this install: `fts5`, `fts4`, or `like`.
  static const String keySearchBackend = 'search_backend';

  static const String searchBackendFts5 = 'fts5';
  static const String searchBackendFts4 = 'fts4';
  static const String searchBackendLike = 'like';
}
