import '../entities/bookmark.dart';

/// CRUD access to user bookmarks.
abstract class IBookmarkRepository {
  Future<List<Bookmark>> getAllBookmarks();
  Future<Bookmark?> getBookmarkForArticle(String articleId);
  Future<bool> isBookmarked(String articleId);
  Future<void> addBookmark(String articleId);
  Future<void> removeBookmark(String articleId);
  Future<void> toggleBookmark(String articleId);
}
