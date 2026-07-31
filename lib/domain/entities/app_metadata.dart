/// A single app-level metadata key/value pair, e.g. dataset version,
/// last-updated timestamp, or first-run seed flag.
class AppMetadata {
  final String key;
  final String value;

  const AppMetadata({required this.key, required this.value});

  static const String keySeeded = 'seeded';
  static const String keyDatasetVersion = 'dataset_version';
  static const String keyLastUpdated = 'last_updated';
}
