/// A user-authored personal note attached to a single article.
class Note {
  final String id;
  final String articleId;
  final String noteText;
  final String createdAt;
  final String updatedAt;

  const Note({
    required this.id,
    required this.articleId,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? articleId,
    String? noteText,
    String? createdAt,
    String? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Note && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
