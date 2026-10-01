import '../entities/note.dart';

/// CRUD access to user notes attached to articles.
abstract class INoteRepository {
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteForArticle(String articleId);
  Future<void> saveNote(String articleId, String noteText);
  Future<void> deleteNote(String articleId);
}
