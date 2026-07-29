/// A single full-text search hit, joining an [Article] with its
/// parent [Law] name and a highlighted text snippet.
class SearchResult {
  final String articleId;
  final String lawId;
  final String lawTitle;
  final String lawCode;
  final String articleNumber;
  final String? articleTitle;
  final String snippet;

  const SearchResult({
    required this.articleId,
    required this.lawId,
    required this.lawTitle,
    required this.lawCode,
    required this.articleNumber,
    this.articleTitle,
    required this.snippet,
  });

  /// Display label used in the search results list:
  /// "Law Name • Art. X: snippet text".
  String get displayLabel => '$lawTitle • $articleNumber: $snippet';

  @override
  bool operator ==(Object other) =>
      other is SearchResult && other.articleId == articleId;

  @override
  int get hashCode => articleId.hashCode;
}
