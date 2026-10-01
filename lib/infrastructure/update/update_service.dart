import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../domain/entities/app_metadata.dart';
import '../../domain/repositories/i_update_service.dart';
import '../database/database_helper.dart';
import '../seed/seed_data.dart';

/// Stub implementation of the manual dataset-update mechanism.
///
/// This app ships fully offline with a bundled/seeded dataset. There is
/// **no** background or automatic network update in this MVP. This class
/// documents and stubs out the pieces that a future release would need to
/// support manually-triggered dataset updates:
///
/// 1. `checkForUpdates()` would call a versioned manifest endpoint (a
///    static JSON file hosted anywhere, e.g. GitHub Releases or a simple
///    CDN bucket) containing the latest `datasetVersion`, a `downloadUrl`
///    for a packaged SQLite/JSON update bundle, and its `sha256` checksum.
///    It would compare that version against the locally stored
///    [AppMetadata.keyDatasetVersion] value.
/// 2. `downloadAndApplyUpdate()` would download the bundle (e.g. via
///    `package:http` or `package:dio`), verify its integrity by computing
///    a SHA-256 digest and comparing it against the manifest's expected
///    checksum (implemented below against arbitrary bytes so the
///    verification logic itself is real and testable), then atomically
///    replace or merge the local database contents inside a transaction,
///    and finally update the stored dataset version/timestamp metadata.
/// 3. Because this is a *reference* app with no user accounts or backend,
///    any real deployment should treat the manifest and bundle as public,
///    read-only, versioned artifacts and should always verify the
///    checksum before touching the local database.
class UpdateService implements IUpdateService {
  UpdateService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  @override
  Future<UpdateCheckResult> checkForUpdates() async {
    // TODO(update-service): Replace with a real HTTP GET to a versioned
    // manifest URL once a hosting location is chosen, e.g.:
    //   final response = await http.get(Uri.parse(manifestUrl));
    //   final manifest = jsonDecode(response.body);
    // For this offline MVP we always report "up to date" against the
    // bundled sample dataset, since no manifest endpoint exists yet.
    final currentVersion = await getCurrentDatasetVersion();
    return UpdateCheckResult(
      status: UpdateCheckStatus.upToDate,
      latestVersion: currentVersion,
      message: 'You have the latest bundled dataset ($currentVersion). '
          'This offline MVP does not yet fetch updates over the network.',
    );
  }

  @override
  Future<UpdateApplyResult> downloadAndApplyUpdate({
    required String url,
    required String expectedSha256,
  }) async {
    // TODO(update-service): Replace this stub download with a real HTTP
    // client call, e.g.:
    //   final response = await http.get(Uri.parse(url));
    //   final bytes = response.bodyBytes;
    // The stub below simulates "downloading" by treating the url as
    // opaque and refusing to proceed, since there is nothing to fetch yet.
    return const UpdateApplyResult(
      success: false,
      message:
          'Manual dataset updates are not yet available in this build. '
          'No update bundle is currently hosted for this app.',
    );
  }

  /// Verifies that [bytes] matches the [expectedSha256] hex digest.
  ///
  /// This is the real, testable piece of the update pipeline: any future
  /// downloaded update bundle MUST pass this check before being applied.
  bool verifyChecksum(Uint8List bytes, String expectedSha256) {
    final digest = sha256.convert(bytes);
    return digest.toString().toLowerCase() ==
        expectedSha256.toLowerCase().trim();
  }

  @override
  Future<String> getCurrentDatasetVersion() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: [AppMetadata.keyDatasetVersion],
      limit: 1,
    );
    if (rows.isEmpty) return SeedData.datasetVersion;
    return rows.first['value'] as String;
  }

  @override
  Future<DateTime?> getLastUpdatedAt() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: [AppMetadata.keyLastUpdated],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['value'] as String);
  }
}

/// Helper retained for documentation/testing purposes: demonstrates how a
/// manifest response would be parsed once a real update endpoint exists.
UpdateCheckResult parseManifestResponse(String jsonBody, String currentVersion) {
  final map = jsonDecode(jsonBody) as Map<String, dynamic>;
  final latestVersion = map['version'] as String;
  if (latestVersion == currentVersion) {
    return UpdateCheckResult(
      status: UpdateCheckStatus.upToDate,
      latestVersion: latestVersion,
    );
  }
  return UpdateCheckResult(
    status: UpdateCheckStatus.updateAvailable,
    latestVersion: latestVersion,
    downloadUrl: map['downloadUrl'] as String?,
    checksum: map['sha256'] as String?,
  );
}
