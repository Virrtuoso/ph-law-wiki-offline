import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/i_search_repository.dart';
import 'repository_providers.dart';

class SearchState {
  final String query;
  final List<SearchResult> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._repository) : super(const SearchState());

  final ISearchRepository _repository;
  Timer? _debounce;
  int _requestId = 0;

  static const Duration debounceDuration = Duration(milliseconds: 280);

  /// Debounced search used by live `onChanged` typing. Empty/whitespace
  /// queries clear results immediately and never hit the database.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    _debounce?.cancel();
    state = state.copyWith(query: query, clearError: true);

    if (trimmed.isEmpty) {
      state = state.copyWith(results: [], isLoading: false, clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final requestId = ++_requestId;

    _debounce = Timer(debounceDuration, () {
      unawaited(_runSearch(query, trimmed, requestId));
    });
  }

  /// Immediate search (e.g. initialQuery from navigation / submit). Still
  /// cancels any pending debounce and ignores stale responses.
  Future<void> searchNow(String query) async {
    _debounce?.cancel();
    final trimmed = query.trim();
    state = state.copyWith(query: query, clearError: true);
    if (trimmed.isEmpty) {
      state = state.copyWith(results: [], isLoading: false, clearError: true);
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    final requestId = ++_requestId;
    await _runSearch(query, trimmed, requestId);
  }

  Future<void> _runSearch(String query, String trimmed, int requestId) async {
    try {
      // Repository / sqflite already hop off the UI isolate; awaiting here
      // keeps the framework free to paint between keystrokes.
      final results = await _repository.search(trimmed);
      if (!mounted || requestId != _requestId || state.query != query) {
        return;
      }
      state = state.copyWith(
        results: results,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
        results: [],
      );
    }
  }

  void clear() {
    _debounce?.cancel();
    _requestId++;
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier(ref.watch(searchRepositoryProvider));
});
