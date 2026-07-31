import '../../domain/entities/note.dart';

/// Maps between `notes` table rows and [Note].
class NoteModel {
  NoteModel._();

  static Note fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as String,
      articleId: map['article_id'] as String,
      noteText: map['note_text'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  static Map<String, Object?> toMap(Note note) {
    return {
      'id': note.id,
      'article_id': note.articleId,
      'note_text': note.noteText,
      'created_at': note.createdAt,
      'updated_at': note.updatedAt,
    };
  }
}
