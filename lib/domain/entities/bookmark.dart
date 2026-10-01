/// A user-created bookmark pointing at a single article.
class Bookmark {
  final String id;
  final String articleId;
  final String createdAt;

  const Bookmark({
    required this.id,
    required this.articleId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) => other is Bookmark && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
