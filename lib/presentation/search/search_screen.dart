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
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchProvider.notifier).search(widget.initialQuery!);
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

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const ValueKey('search-screen-field'),
          controller: _controller,
          autofocus: widget.initialQuery == null,
          decoration: const InputDecoration(
            hintText: 'Search articles…',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(searchProvider.notifier).search(value);
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          if (searchState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (searchState.error != null) {
            return Center(child: Text(searchState.error!));
          }
          if (searchState.query.trim().isEmpty) {
            return const Center(
              child: Text('Start typing to search the law catalogue.'),
            );
          }
          if (searchState.results.isEmpty) {
            return const Center(child: Text('No results found.'));
          }
          return ListView.separated(
            itemCount: searchState.results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
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
