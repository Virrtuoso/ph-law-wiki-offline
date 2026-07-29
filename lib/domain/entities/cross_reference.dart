/// A textual cross-reference from one article to another
/// (e.g. "see Article 40" links Article 39 to Article 40).
class CrossReference {
  final String id;
  final String fromArticleId;
  final String toArticleId;
  final String refText;

  const CrossReference({
    required this.id,
    required this.fromArticleId,
    required this.toArticleId,
    required this.refText,
  });

  @override
  bool operator ==(Object other) => other is CrossReference && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
