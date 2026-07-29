import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../domain/entities/cross_reference.dart';
import 'repository_providers.dart';

final articleByIdProvider = FutureProvider.family<Article?, String>((
  ref,
  articleId,
) {
  return ref.watch(articleRepositoryProvider).getArticleById(articleId);
});

final articlesForLawProvider = FutureProvider.family<List<Article>, String>((
  ref,
  lawId,
) {
  return ref.watch(articleRepositoryProvider).getArticlesForLaw(lawId);
});

final articlesForNodeProvider = FutureProvider.family<List<Article>, String>((
  ref,
  nodeId,
) {
  return ref.watch(articleRepositoryProvider).getArticlesForNode(nodeId);
});

final crossReferencesFromProvider =
    FutureProvider.family<List<CrossReference>, String>((ref, articleId) {
      return ref
          .watch(articleRepositoryProvider)
          .getCrossReferencesFrom(articleId);
    });
