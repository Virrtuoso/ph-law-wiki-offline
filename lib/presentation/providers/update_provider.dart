import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/i_update_service.dart';
import 'repository_providers.dart';

class UpdateState {
  final bool isChecking;
  final UpdateCheckResult? lastResult;
  final String datasetVersion;
  final DateTime? lastUpdatedAt;

  const UpdateState({
    this.isChecking = false,
    this.lastResult,
    this.datasetVersion = '—',
    this.lastUpdatedAt,
  });

  UpdateState copyWith({
    bool? isChecking,
    UpdateCheckResult? lastResult,
    String? datasetVersion,
    DateTime? lastUpdatedAt,
  }) {
    return UpdateState(
      isChecking: isChecking ?? this.isChecking,
      lastResult: lastResult ?? this.lastResult,
      datasetVersion: datasetVersion ?? this.datasetVersion,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

class UpdateNotifier extends StateNotifier<UpdateState> {
  UpdateNotifier(this._service) : super(const UpdateState()) {
    _loadCurrentInfo();
  }

  final IUpdateService _service;

  Future<void> _loadCurrentInfo() async {
    final version = await _service.getCurrentDatasetVersion();
    final lastUpdated = await _service.getLastUpdatedAt();
    state = state.copyWith(
      datasetVersion: version,
      lastUpdatedAt: lastUpdated,
    );
  }

  Future<void> checkForUpdates() async {
    state = state.copyWith(isChecking: true);
    final result = await _service.checkForUpdates();
    state = state.copyWith(isChecking: false, lastResult: result);
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((
  ref,
) {
  return UpdateNotifier(ref.watch(updateServiceProvider));
});
