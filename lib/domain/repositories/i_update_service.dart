/// Result of an update check.
enum UpdateCheckStatus { upToDate, updateAvailable, error }

class UpdateCheckResult {
  final UpdateCheckStatus status;
  final String? latestVersion;
  final String? downloadUrl;
  final String? checksum;
  final String? message;

  const UpdateCheckResult({
    required this.status,
    this.latestVersion,
    this.downloadUrl,
    this.checksum,
    this.message,
  });
}

/// Result of applying a downloaded dataset update.
class UpdateApplyResult {
  final bool success;
  final String message;

  const UpdateApplyResult({required this.success, required this.message});
}

/// Abstraction over the (currently stubbed) manual dataset-update mechanism.
///
/// See `lib/infrastructure/update/update_service.dart` for the concrete
/// implementation notes and TODOs describing how this would work with a
/// real update package/CDN.
abstract class IUpdateService {
  Future<UpdateCheckResult> checkForUpdates();

  Future<UpdateApplyResult> downloadAndApplyUpdate({
    required String url,
    required String expectedSha256,
  });

  Future<String> getCurrentDatasetVersion();

  Future<DateTime?> getLastUpdatedAt();
}
