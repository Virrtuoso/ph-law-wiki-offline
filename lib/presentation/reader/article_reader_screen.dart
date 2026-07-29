import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/article.dart';
import '../../domain/entities/cross_reference.dart';
import '../../domain/entities/law.dart';
import '../../domain/usecases/format_citation_usecase.dart';
import '../providers/article_providers.dart';
import '../providers/bookmark_provider.dart';
import '../providers/law_providers.dart';
import '../providers/note_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/disclaimer_footer.dart';

class ArticleReaderScreen extends ConsumerWidget {
  const ArticleReaderScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleByIdProvider(articleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: articleAsync.when(
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Article not found.'));
          }
          return _ArticleBody(article: article);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ArticleBody extends ConsumerWidget {
  const _ArticleBody({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawAsync = ref.watch(lawByIdProvider(article.lawId));
    final settings = ref.watch(settingsProvider);
    final bookmarkState = ref.watch(bookmarkProvider);
    final noteState = ref.watch(noteProvider);
    final crossRefsAsync = ref.watch(crossReferencesFromProvider(article.id));

    final isBookmarked = bookmarkState.isBookmarked(article.id);
    final existingNote = noteState.noteFor(article.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        lawAsync.when(
          data: (law) => law == null
              ? const SizedBox.shrink()
              : _ArticleHeader(article: article, law: law),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              key: const ValueKey('bookmark-toggle-button'),
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
              onPressed: () {
                ref.read(bookmarkProvider.notifier).toggle(article.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Copy citation',
              onPressed: () async {
                final law = lawAsync.valueOrNull;
                if (law == null) return;
                final citation = formatCitation(law: law, article: article);
                await Clipboard.setData(ClipboardData(text: citation));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied: $citation')),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(
                settings.darkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: 'Toggle dark mode',
              onPressed: () {
                ref.read(settingsProvider.notifier).toggleDarkMode();
              },
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.text_fields, size: 18),
            Expanded(
              child: Slider(
                value: settings.fontSize,
                min: kMinFontSize,
                max: kMaxFontSize,
                divisions: ((kMaxFontSize - kMinFontSize) / 1).round(),
                label: settings.fontSize.round().toString(),
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setFontSize(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(
          article.body,
          style: TextStyle(fontSize: settings.fontSize, height: 1.5),
        ),
        const SizedBox(height: 24),
        crossRefsAsync.when(
          data: (refs) {
            if (refs.isEmpty) return const SizedBox.shrink();
            return _CrossReferenceChips(refs: refs);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        _NoteEditor(articleId: article.id, initialText: existingNote?.noteText),
        const Divider(height: 32),
        const DisclaimerFooter(),
      ],
    );
  }
}

class _ArticleHeader extends StatelessWidget {
  const _ArticleHeader({required this.article, required this.law});

  final Article article;
  final Law law;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${law.title} (${law.code})',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${article.articleNumber}${article.title != null ? ': ${article.title}' : ''}',
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _CrossReferenceChips extends ConsumerWidget {
  const _CrossReferenceChips({required this.refs});

  final List<CrossReference> refs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related provisions',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: refs.map<Widget>((r) {
            return ActionChip(
              label: Text(r.refText),
              avatar: const Icon(Icons.link, size: 16),
              onPressed: () {
                context.push('/article/${r.toArticleId}');
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _NoteEditor extends ConsumerStatefulWidget {
  const _NoteEditor({required this.articleId, this.initialText});

  final String articleId;
  final String? initialText;

  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your notes', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('note-editor-field'),
          controller: _controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a personal note about this article…',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            key: const ValueKey('save-note-button'),
            onPressed: () {
              ref
                  .read(noteProvider.notifier)
                  .saveNote(widget.articleId, _controller.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved.')),
              );
            },
            child: const Text('Save note'),
          ),
        ),
      ],
    );
  }
}
