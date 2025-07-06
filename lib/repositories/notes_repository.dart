// lib/repositories/notes_repository.dart
import 'package:notes_app/models/note.dart';
import 'dart:async'; // For Stream

/// Abstract interface for notes operations.
/// This defines what a Notes Repository *should* do,
/// without caring about *how* it does it (e.g., from Firestore, a local database, etc.).
abstract class NotesRepository {
  /// Provides a stream of notes for a given user ID,
  /// updating in real-time when changes occur in the data source.
  Stream<List<Note>> getNotesStream(String userId);

  /// Adds a new note to the data source.
  Future<void> addNote(String userId, String title, String content);

  /// Updates an existing note in the data source.
  Future<void> updateNote(String noteId, String newTitle, String newContent);

  /// Deletes a note from the data source by its ID.
  Future<void> deleteNote(String noteId);
}