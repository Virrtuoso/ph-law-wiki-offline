import '../../data/repositories/article_repository_impl.dart';
import '../../data/repositories/bookmark_repository_impl.dart';
import '../../data/repositories/law_repository_impl.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../../domain/repositories/i_bookmark_repository.dart';
import '../../domain/repositories/i_law_repository.dart';
import '../../domain/repositories/i_note_repository.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../domain/repositories/i_update_service.dart';
import '../database/database_helper.dart';
import '../update/update_service.dart';

/// Wires the concrete (SQLite-backed) repository implementations to their
/// domain interfaces, bound to the shared app-wide [DatabaseHelper]
/// singleton. Riverpod providers read from this locator so widgets never
/// depend on the concrete `data`/`infrastructure` implementations
/// directly, only on the `domain` interfaces.
class RepositoryLocator {
  RepositoryLocator._();

  static final ILawRepository lawRepository = LawRepositoryImpl(
    databaseHelper: DatabaseHelper.instance,
  );

  static final IArticleRepository articleRepository = ArticleRepositoryImpl(
    databaseHelper: DatabaseHelper.instance,
  );

  static final ISearchRepository searchRepository = SearchRepositoryImpl(
    databaseHelper: DatabaseHelper.instance,
  );

  static final IBookmarkRepository bookmarkRepository = BookmarkRepositoryImpl(
    databaseHelper: DatabaseHelper.instance,
  );

  static final INoteRepository noteRepository = NoteRepositoryImpl(
    databaseHelper: DatabaseHelper.instance,
  );

  static final IUpdateService updateService = UpdateService(
    databaseHelper: DatabaseHelper.instance,
  );
}
