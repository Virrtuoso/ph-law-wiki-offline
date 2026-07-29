import '../entities/search_result.dart';

/// Full-text search over the article catalogue.
abstract class ISearchRepository {
  /// Returns matching [SearchResult]s for the given free-text [query].
  /// An empty or blank query returns an empty list.
  Future<List<SearchResult>> search(String query, {int limit = 50});
}
