import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/search_provider.dart';
import '../widgets/search_result_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchProvider.notifier).searchNow(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          key: const ValueKey('search-screen-field'),
          controller: _controller,
          autofocus: widget.initialQuery == null,
          style: theme.textTheme.titleMedium,
          cursorColor: cs.primary,
          decoration: InputDecoration(
            hintText: 'Search articles…',
            hintStyle: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            border: InputBorder.none,
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            ref.read(searchProvider.notifier).search(value);
          },
          onSubmitted: (value) {
            ref.read(searchProvider.notifier).searchNow(value);
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                ref.read(searchProvider.notifier).clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (searchState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (searchState.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  searchState.error!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (searchState.query.trim().isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.manage_search_outlined,
                      size: 48,
                      color: cs.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start typing to search the law catalogue.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (searchState.results.isEmpty) {
            return Center(
              child: Text(
                'No results found.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: searchState.results.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            itemBuilder: (context, index) {
              final result = searchState.results[index];
              return SearchResultTile(
                result: result,
                onTap: () => context.push('/article/${result.articleId}'),
              );
            },
          );
        },
      ),
    );
  }
}
