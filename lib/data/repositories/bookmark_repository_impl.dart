import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/i_bookmark_repository.dart';
import '../../infrastructure/database/database_helper.dart';
import '../../infrastructure/utils/id_generator.dart';
import '../datasources/bookmark_local_datasource.dart';
import '../models/bookmark_model.dart';

class BookmarkRepositoryImpl implements IBookmarkRepository {
  BookmarkRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  @override
  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await _databaseHelper.database;
    final rows = await BookmarkLocalDataSource.getAllBookmarks(db);
    return rows.map(BookmarkModel.fromMap).toList();
  }

  @override
  Future<Bookmark?> getBookmarkForArticle(String articleId) async {
    final db = await _databaseHelper.database;
    final row = await BookmarkLocalDataSource.getBookmarkForArticle(
      db,
      articleId,
    );
    return row == null ? null : BookmarkModel.fromMap(row);
  }

  @override
  Future<bool> isBookmarked(String articleId) async {
    final bookmark = await getBookmarkForArticle(articleId);
    return bookmark != null;
  }

  @override
  Future<void> addBookmark(String articleId) async {
    final db = await _databaseHelper.database;
    final bookmark = Bookmark(
      id: IdGenerator.newId(),
      articleId: articleId,
      createdAt: DateTime.now().toIso8601String(),
    );
    await BookmarkLocalDataSource.insertBookmark(
      db,
      BookmarkModel.toMap(bookmark),
    );
  }

  @override
  Future<void> removeBookmark(String articleId) async {
    final db = await _databaseHelper.database;
    await BookmarkLocalDataSource.deleteBookmark(db, articleId);
  }

  @override
  Future<void> toggleBookmark(String articleId) async {
    if (await isBookmarked(articleId)) {
      await removeBookmark(articleId);
    } else {
      await addBookmark(articleId);
    }
  }
}
