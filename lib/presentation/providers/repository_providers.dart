import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/i_article_repository.dart';
import '../../domain/repositories/i_bookmark_repository.dart';
import '../../domain/repositories/i_law_repository.dart';
import '../../domain/repositories/i_note_repository.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../domain/repositories/i_update_service.dart';
import '../../infrastructure/database/database_helper.dart';
import '../../infrastructure/repositories/repository_locator.dart';
import '../../infrastructure/seed/seed_data.dart';

/// Exposes the domain repository interfaces to the widget tree.
///
/// Widgets and other providers should depend only on these interfaces
/// (never on `RepositoryLocator` or the concrete `*Impl` classes
/// directly), and tests can override any of these providers with fakes
/// via `ProviderScope(overrides: [...])`.
final lawRepositoryProvider = Provider<ILawRepository>((ref) {
  return RepositoryLocator.lawRepository;
});

final articleRepositoryProvider = Provider<IArticleRepository>((ref) {
  return RepositoryLocator.articleRepository;
});

final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  return RepositoryLocator.searchRepository;
});

final bookmarkRepositoryProvider = Provider<IBookmarkRepository>((ref) {
  return RepositoryLocator.bookmarkRepository;
});

final noteRepositoryProvider = Provider<INoteRepository>((ref) {
  return RepositoryLocator.noteRepository;
});

final updateServiceProvider = Provider<IUpdateService>((ref) {
  return RepositoryLocator.updateService;
});

/// Ensures the database is open and seeded with sample data before the
/// rest of the app renders. Watched from a splash/loading gate in
/// `app.dart`.
final appInitProvider = FutureProvider<void>((ref) async {
  final db = await DatabaseHelper.instance.database;
  await SeedData.seedIfNeeded(db);
});
