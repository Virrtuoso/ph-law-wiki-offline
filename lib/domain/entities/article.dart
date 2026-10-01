/// A single article/section of text within a law.
class Article {
  final String id;
  final String lawId;
  final String? nodeId;
  final String articleNumber;
  final String? title;
  final String body;
  final String? effectiveFrom;
  final String? effectiveTo;
  final int orderIndex;

  const Article({
    required this.id,
    required this.lawId,
    this.nodeId,
    required this.articleNumber,
    this.title,
    required this.body,
    this.effectiveFrom,
    this.effectiveTo,
    this.orderIndex = 0,
  });

  /// A short citation label, e.g. "Art. 37" or "Sec. 4".
  String get shortCitation => articleNumber;

  Article copyWith({
    String? id,
    String? lawId,
    String? nodeId,
    String? articleNumber,
    String? title,
    String? body,
    String? effectiveFrom,
    String? effectiveTo,
    int? orderIndex,
  }) {
    return Article(
      id: id ?? this.id,
      lawId: lawId ?? this.lawId,
      nodeId: nodeId ?? this.nodeId,
      articleNumber: articleNumber ?? this.articleNumber,
      title: title ?? this.title,
      body: body ?? this.body,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) => other is Article && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Article($articleNumber: $title)';
}
