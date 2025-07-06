
import 'package:bloc/bloc.dart';
import 'package:notes_app/cubits/notes/notes_state.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/repositories/notes_repository.dart';
import 'dart:async'; // For StreamSubscription

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _notesRepository;
  StreamSubscription? _notesSubscription;

  NotesCubit(this._notesRepository) : super(NotesInitial());

  Future<void> listenToNotes(String userId) async {
    _notesSubscription?.cancel();
    _notesSubscription = null;

    emit(NotesLoading());
    print('NotesCubit: listenToNotes called for userId: $userId. Emitting NotesLoading.');
    try {
      _notesSubscription = _notesRepository.getNotesStream(userId).listen(
            (List<Note> notes) {
          print('NotesCubit: Received ${notes.length} notes from stream. Emitting NotesLoaded.');
          emit(NotesLoaded(notes));
        },
        onError: (error) {
          print('NotesCubit: Stream error: $error');
          emit(NotesError('Failed to listen to notes: ${error.toString()}'));
        },
      );
    } catch (e) { // <--- Correct catch block for the try above
      print('NotesCubit: Error setting up listener: ${e.toString()}'); // Added .toString() for clarity
      emit(NotesError('Failed to setup notes listener: ${e.toString()}'));
    }
  } // <--- This closes the listenToNotes method correctly

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    print('NotesCubit: Closing subscription and Cubit.');
    return super.close();
  }

  Future<void> addNote(String userId, String title, String content) async {
    try {
      await _notesRepository.addNote(userId, title, content);
      emit(const NotesActionSuccess('Note added successfully!'));
      print('NotesCubit: Note added. Emitting NotesActionSuccess.');
      // The stream listener should handle updating NotesLoaded.
    } catch (e) {
      print('NotesCubit: Failed to add note: ${e.toString()}');
      emit(NotesError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> updateNote(String noteId, String newTitle, String newContent) async {
    try {
      await _notesRepository.updateNote(noteId, newTitle, newContent);
      emit(const NotesActionSuccess('Note updated successfully!'));
      print('NotesCubit: Note updated. Emitting NotesActionSuccess.');
      // The stream listener should handle updating NotesLoaded.
    } catch (e) {
      print('NotesCubit: Failed to update note: ${e.toString()}');
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _notesRepository.deleteNote(noteId);
      emit(const NotesActionSuccess('Note deleted successfully!'));
      print('NotesCubit: Note deleted. Emitting NotesActionSuccess.');
      // The stream listener should handle updating NotesLoaded.
    } catch (e) {
      print('NotesCubit: Failed to delete note: ${e.toString()}');
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }
}