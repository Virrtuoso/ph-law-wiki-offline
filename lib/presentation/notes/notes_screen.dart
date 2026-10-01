import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/article_providers.dart';
import '../providers/note_provider.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteState = ref.watch(noteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: noteState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : noteState.notes.isEmpty
          ? const Center(child: Text('No notes yet.'))
          : ListView.builder(
              itemCount: noteState.notes.length,
              itemBuilder: (context, index) {
                final note = noteState.notes[index];
                return Consumer(
                  builder: (context, ref, _) {
                    final articleAsync = ref.watch(
                      articleByIdProvider(note.articleId),
                    );
                    return articleAsync.when(
                      data: (article) {
                        if (article == null) return const SizedBox.shrink();
                        return ListTile(
                          leading: const Icon(Icons.note_outlined),
                          title: Text(
                            article.title != null
                                ? '${article.articleNumber}: ${article.title}'
                                : article.articleNumber,
                          ),
                          subtitle: Text(
                            note.noteText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () =>
                              context.push('/article/${article.id}'),
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
