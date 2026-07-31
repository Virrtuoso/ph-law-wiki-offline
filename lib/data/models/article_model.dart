import '../../domain/entities/article.dart';

/// Maps between the `articles` table rows and the [Article] domain entity.
class ArticleModel {
  ArticleModel._();

  static Article fromMap(Map<String, Object?> map) {
    return Article(
      id: map['id'] as String,
      lawId: map['law_id'] as String,
      nodeId: map['node_id'] as String?,
      articleNumber: map['article_number'] as String,
      title: map['title'] as String?,
      body: map['body'] as String,
      effectiveFrom: map['effective_from'] as String?,
      effectiveTo: map['effective_to'] as String?,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  static Map<String, Object?> toMap(Article article) {
    return {
      'id': article.id,
      'law_id': article.lawId,
      'node_id': article.nodeId,
      'article_number': article.articleNumber,
      'title': article.title,
      'body': article.body,
      'effective_from': article.effectiveFrom,
      'effective_to': article.effectiveTo,
      'order_index': article.orderIndex,
    };
  }
}
