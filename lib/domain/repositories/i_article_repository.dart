import '../entities/article.dart';
import '../entities/cross_reference.dart';

/// Read-only access to individual articles and their cross-references.
abstract class IArticleRepository {
  Future<Article?> getArticleById(String id);
  Future<List<Article>> getArticlesForLaw(String lawId);
  Future<List<Article>> getArticlesForNode(String nodeId);
  Future<List<CrossReference>> getCrossReferencesFrom(String articleId);
  Future<List<CrossReference>> getCrossReferencesTo(String articleId);
}
