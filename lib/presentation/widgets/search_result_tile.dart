import 'package:flutter/material.dart';

import '../../domain/entities/search_result.dart';

/// A single search-results list tile displaying:
/// "Law Name • Art. X: snippet text".
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.result, this.onTap});

  final SearchResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      key: ValueKey('search-result-${result.articleId}'),
      onTap: onTap,
      leading: const Icon(Icons.article_outlined),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${result.lawTitle} • ',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: result.articleNumber,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      subtitle: Text(
        result.snippet.isNotEmpty
            ? result.snippet
            : (result.articleTitle ?? ''),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
