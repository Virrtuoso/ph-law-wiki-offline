import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/i_note_repository.dart';
import 'repository_providers.dart';

class NoteState {
  final List<Note> notes;
  final bool isLoading;

  const NoteState({this.notes = const [], this.isLoading = false});

  Note? noteFor(String articleId) {
    for (final note in notes) {
      if (note.articleId == articleId) return note;
    }
    return null;
  }

  NoteState copyWith({List<Note>? notes, bool? isLoading}) {
    return NoteState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NoteNotifier extends StateNotifier<NoteState> {
  NoteNotifier(this._repository) : super(const NoteState()) {
    refresh();
  }

  final INoteRepository _repository;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final notes = await _repository.getAllNotes();
    state = state.copyWith(notes: notes, isLoading: false);
  }

  Future<void> saveNote(String articleId, String noteText) async {
    if (noteText.trim().isEmpty) {
      await _repository.deleteNote(articleId);
    } else {
      await _repository.saveNote(articleId, noteText);
    }
    await refresh();
  }

  Future<void> deleteNote(String articleId) async {
    await _repository.deleteNote(articleId);
    await refresh();
  }
}

final noteProvider = StateNotifierProvider<NoteNotifier, NoteState>((ref) {
  return NoteNotifier(ref.watch(noteRepositoryProvider));
});
