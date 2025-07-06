// lib/repositories/notes_repository.dart
import 'package:notes_app/models/note.dart';
import 'dart:async';

abstract class NotesRepository {
  Stream<List<Note>> getNotesStream(String userId);
  Future<void> addNote(String userId, String title, String content);
  Future<void> updateNote(String noteId, String newTitle, String newContent);
  Future<void> deleteNote(String noteId);
}