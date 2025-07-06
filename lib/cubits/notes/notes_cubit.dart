// lib/cubits/notes/notes_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:notes_app/cubits/notes/notes_state.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/repositories/notes_repository.dart'; // IMPORTANT: Ensure this import is correct
import 'dart:async';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _notesRepository;
  StreamSubscription? _notesSubscription;

  NotesCubit(this._notesRepository) : super(NotesInitial());

  Future<void> listenToNotes(String userId) async {
    _notesSubscription?.cancel();
    _notesSubscription = null;

    emit(NotesLoading());
    try {
      _notesSubscription = _notesRepository.getNotesStream(userId).listen(
            (List<Note> notes) {
          emit(NotesLoaded(notes));
        },
        onError: (error) {
          emit(NotesError('Failed to listen to notes: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(NotesError('Failed to setup notes listener: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }

  Future<void> addNote(String userId, String title, String content) async {
    try {
      await _notesRepository.addNote(userId, title, content);
      emit(const NotesActionSuccess('Note added successfully!'));
    } catch (e) {
      emit(NotesError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> updateNote(String noteId, String newTitle, String newContent) async {
    try {
      await _notesRepository.updateNote(noteId, newTitle, newContent);
      emit(const NotesActionSuccess('Note updated successfully!'));
    } catch (e) {
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _notesRepository.deleteNote(noteId);
      emit(const NotesActionSuccess('Note deleted successfully!'));
    } catch (e) {
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }
}