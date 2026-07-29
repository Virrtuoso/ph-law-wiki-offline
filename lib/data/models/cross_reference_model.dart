import '../../domain/entities/cross_reference.dart';

/// Maps between `cross_references` table rows and [CrossReference].
class CrossReferenceModel {
  CrossReferenceModel._();

  static CrossReference fromMap(Map<String, Object?> map) {
    return CrossReference(
      id: map['id'] as String,
      fromArticleId: map['from_article_id'] as String,
      toArticleId: map['to_article_id'] as String,
      refText: map['ref_text'] as String,
    );
  }

  static Map<String, Object?> toMap(CrossReference ref) {
    return {
      'id': ref.id,
      'from_article_id': ref.fromArticleId,
      'to_article_id': ref.toArticleId,
      'ref_text': ref.refText,
    };
  }
}
