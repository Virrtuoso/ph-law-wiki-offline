import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/i_bookmark_repository.dart';
import 'repository_providers.dart';

class BookmarkState {
  final List<Bookmark> bookmarks;
  final bool isLoading;

  const BookmarkState({this.bookmarks = const [], this.isLoading = false});

  bool isBookmarked(String articleId) =>
      bookmarks.any((b) => b.articleId == articleId);

  BookmarkState copyWith({List<Bookmark>? bookmarks, bool? isLoading}) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  BookmarkNotifier(this._repository) : super(const BookmarkState()) {
    refresh();
  }

  final IBookmarkRepository _repository;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final bookmarks = await _repository.getAllBookmarks();
    state = state.copyWith(bookmarks: bookmarks, isLoading: false);
  }

  Future<void> toggle(String articleId) async {
    await _repository.toggleBookmark(articleId);
    await refresh();
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, BookmarkState>(
  (ref) {
    return BookmarkNotifier(ref.watch(bookmarkRepositoryProvider));
  },
);
