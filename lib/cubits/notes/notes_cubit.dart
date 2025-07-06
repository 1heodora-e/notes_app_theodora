// lib/cubits/notes/notes_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:notes_app/cubits/notes/notes_state.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/repositories/notes_repository.dart';
import 'dart:async';

class NotesCubit extends Cubit<NotesState> {

  final NotesRepository _notesRepository;
  StreamSubscription? _notesSubscription;

  // MODIFIED CONSTRUCTOR: Now requires a NotesRepository
  NotesCubit(this._notesRepository) : super(NotesInitial());

  Future<void> listenToNotes(String userId) async {
    _notesSubscription?.cancel();
    _notesSubscription = null;

    emit(NotesLoading());
    try {
      // Use the repository to get the stream
      _notesSubscription = _notesRepository.getNotesStream(userId).listen(
            (notes) {
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
      // Use the repository to add the note
      await _notesRepository.addNote(userId, title, content);
    } catch (e) {
      emit(NotesError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> updateNote(String noteId, String newTitle, String newContent) async {
    try {
      // Use the repository to update the note
      await _notesRepository.updateNote(noteId, newTitle, newContent);
    } catch (e) {
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      // Use the repository to delete the note
      await _notesRepository.deleteNote(noteId);
    } catch (e) {
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }
}