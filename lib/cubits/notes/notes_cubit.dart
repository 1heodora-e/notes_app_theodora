// lib/cubits/notes/notes_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:notes_app/cubits/notes/notes_state.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/repositories/notes_repository.dart';
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
            (notes) {
          emit(NotesLoaded(notes)); // This keeps the list updated
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
      // Emit success, then immediately re-emit the current notes state
      // to ensure the list is displayed correctly after the action.
      emit(const NotesActionSuccess('Note added successfully!')); // <--- NEW LINE
      if (state is NotesLoaded) { // Only re-emit NotesLoaded if we were already in that state
        emit(NotesLoaded((state as NotesLoaded).notes));
      }
    } catch (e) {
      emit(NotesError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> updateNote(String noteId, String newTitle, String newContent) async {
    try {
      await _notesRepository.updateNote(noteId, newTitle, newContent);
      // Emit success, then immediately re-emit the current notes state
      emit(const NotesActionSuccess('Note updated successfully!')); // <--- NEW LINE
      if (state is NotesLoaded) {
        emit(NotesLoaded((state as NotesLoaded).notes));
      }
    } catch (e) {
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _notesRepository.deleteNote(noteId);
      // Emit success, then immediately re-emit the current notes state
      emit(const NotesActionSuccess('Note deleted successfully!')); // <--- NEW LINE
      if (state is NotesLoaded) {
        emit(NotesLoaded((state as NotesLoaded).notes));
      }
    } catch (e) {
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }
}