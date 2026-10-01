import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/article_providers.dart';
import '../providers/bookmark_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkState = ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarkState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarkState.bookmarks.isEmpty
          ? const Center(child: Text('No bookmarks yet.'))
          : ListView.builder(
              itemCount: bookmarkState.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarkState.bookmarks[index];
                return Consumer(
                  builder: (context, ref, _) {
                    final articleAsync = ref.watch(
                      articleByIdProvider(bookmark.articleId),
                    );
                    return articleAsync.when(
                      data: (article) {
                        if (article == null) return const SizedBox.shrink();
                        return ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: Text(
                            article.title != null
                                ? '${article.articleNumber}: ${article.title}'
                                : article.articleNumber,
                          ),
                          onTap: () =>
                              context.push('/article/${article.id}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Remove bookmark',
                            onPressed: () {
                              ref
                                  .read(bookmarkProvider.notifier)
                                  .toggle(article.id);
                            },
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
    );
  }
}
