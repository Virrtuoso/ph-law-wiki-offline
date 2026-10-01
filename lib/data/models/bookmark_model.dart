import '../../domain/entities/bookmark.dart';

/// Maps between `bookmarks` table rows and [Bookmark].
class BookmarkModel {
  BookmarkModel._();

  static Bookmark fromMap(Map<String, Object?> map) {
    return Bookmark(
      id: map['id'] as String,
      articleId: map['article_id'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  static Map<String, Object?> toMap(Bookmark bookmark) {
    return {
      'id': bookmark.id,
      'article_id': bookmark.articleId,
      'created_at': bookmark.createdAt,
    };
  }
}
