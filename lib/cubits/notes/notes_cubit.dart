// lib/cubits/notes/notes_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:notes_app/cubits/notes/notes_state.dart';
import 'package:notes_app/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // <--- NEW: Import for StreamSubscription

class NotesCubit extends Cubit<NotesState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _notesSubscription; // <--- NEW: To manage the subscription

  NotesCubit() : super(NotesInitial());

  // NEW/MODIFIED: Method to listen to notes in real-time
  Future<void> listenToNotes(String userId) async {
    // Cancel any existing subscription to avoid memory leaks or duplicate listeners
    _notesSubscription?.cancel(); // Important to prevent multiple listeners
    _notesSubscription = null; // Clear it

    emit(NotesLoading()); // Indicate that notes are being loaded/listened to
    try {
      _notesSubscription = _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots() // <--- KEY CHANGE: Use snapshots() for real-time
          .listen((querySnapshot) {
        final notes = querySnapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
        emit(NotesLoaded(notes)); // Emit new state with updated notes
      }, onError: (error) {
        emit(NotesError('Failed to listen to notes: ${error.toString()}'));
      });
    } catch (e) {
      emit(NotesError('Failed to setup notes listener: ${e.toString()}'));
    }
  }

  // IMPORTANT: Make sure to cancel the subscription when the Cubit is closed
  @override
  Future<void> close() {
    _notesSubscription?.cancel(); // <--- IMPORTANT: Cancel subscription to prevent memory leaks
    return super.close();
  }

  // --- Existing Methods (addNote, updateNote, deleteNote) remain mostly the same,
  //     but remove the manual state updates as the stream will handle it ---

  Future<void> addNote(String userId, String title, String content) async {
    try {
      final newNoteData = {
        'userId': userId,
        'title': title,
        'content': content,
        'timestamp': Timestamp.now(),
      };
      await _firestore.collection('notes').add(newNoteData);
      // No need to manually update state here, the stream (listenToNotes) will do it!
    } catch (e) {
      emit(NotesError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> updateNote(String noteId, String newTitle, String newContent) async {
    try {
      await _firestore.collection('notes').doc(noteId).update({
        'title': newTitle,
        'content': newContent,
      });
      // No need to manually update state here, the stream will do it!
    } catch (e) {
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      // No need to manually update state here, the stream will do it!
    } catch (e) {
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }
}